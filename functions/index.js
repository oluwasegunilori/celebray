const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const OpenAI = require("openai");
const {
  buildSystemPrompt,
  eventTypeSkill,
  relationshipSkill,
  closenessSkill,
  toneLine,
  religionSkill,
  lengthSkill,
} = require("./prompt/load_skills");
const { assessTouchUpInstructions } = require("./prompt/content_policy");

admin.initializeApp();

const openAiKey = defineSecret("OPENAI_API_KEY");
const ANONYMOUS_DAILY_LIMIT = 10;
const AUTHENTICATED_DAILY_LIMIT = 20;
const MODEL = "gpt-4o-mini";

function setCors(res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
}

async function verifyAuth(req) {
  const authHeader = req.headers.authorization || "";
  if (!authHeader.startsWith("Bearer ")) {
    const error = new Error("Sign in required.");
    error.code = "unauthorized";
    throw error;
  }

  const token = authHeader.slice(7);
  const decoded = await admin.auth().verifyIdToken(token);
  const isAnonymous = decoded.firebase?.sign_in_provider === "anonymous";

  return {
    uid: decoded.uid,
    isAnonymous,
  };
}

function dailyLimitForUser(isAnonymous) {
  return isAnonymous ? ANONYMOUS_DAILY_LIMIT : AUTHENTICATED_DAILY_LIMIT;
}

async function consumeRateLimit(uid, limit) {
  const db = admin.firestore();
  const today = new Date().toISOString().slice(0, 10);
  const ref = db.collection("aiUsage").doc(uid).collection("days").doc(today);

  await db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    const count = doc.exists ? doc.data().count || 0 : 0;
    if (count >= limit) {
      const error = new Error("Daily AI limit reached.");
      error.code = "rate_limited";
      error.limit = limit;
      throw error;
    }
    tx.set(
      ref,
      {
        count: count + 1,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
}

function eventPayload(body) {
  return {
    name: body.name || "",
    type: body.type || "",
    relationship: body.relationship || "",
    sex: body.sex || "",
    closeness: body.closeness ?? 5,
    memories: Array.isArray(body.memories) ? body.memories : [],
    tone: body.tone || "warm",
    faithContext: body.faithContext || "",
  };
}

function buildGeneratePrompt(event) {
  const memoryText =
    event.memories.length > 0
      ? `Shared memories: ${event.memories.join("; ")}.`
      : "No shared memories provided — do not invent any.";

  return `
Write exactly 3 distinct messages for this celebration.

Person: ${event.name}
Event type: ${event.type}
Relationship: ${event.relationship}
Sex (for pronouns if needed): ${event.sex}
Closeness (1-10): ${event.closeness}
${memoryText}

${eventTypeSkill(event.type)}
${relationshipSkill(event.relationship)}
${closenessSkill(event.closeness)}
${toneLine(event.tone)}
${religionSkill(event.faithContext)}
${lengthSkill(event.tone, event.faithContext)}
`.trim();
}

function buildTouchUpPrompt(event, currentMessage, instructions) {
  const memoryText =
    event.memories.length > 0
      ? `Shared memories: ${event.memories.join("; ")}.`
      : "No shared memories provided — do not invent any.";

  return `
Revise this celebration message based on the user's notes.

Person: ${event.name}
Event type: ${event.type}
Relationship: ${event.relationship}
${memoryText}

${eventTypeSkill(event.type)}
${relationshipSkill(event.relationship)}
${closenessSkill(event.closeness)}
${religionSkill(event.faithContext)}
${lengthSkill(event.tone, event.faithContext)}

Current message:
"${currentMessage}"

User notes:
"${instructions || "Polish the message while keeping the same meaning."}"

Write exactly 3 revised versions.
`.trim();
}

async function callOpenAi(openai, prompt) {
  const completion = await openai.chat.completions.create({
    model: MODEL,
    temperature: 0.9,
    response_format: { type: "json_object" },
    messages: [
      {
        role: "system",
        content: buildSystemPrompt(),
      },
      { role: "user", content: prompt },
    ],
  });

  const content = completion.choices[0]?.message?.content;
  if (!content) {
    const error = new Error("Empty AI response.");
    error.code = "ai_error";
    throw error;
  }

  let parsed;
  try {
    parsed = JSON.parse(content);
  } catch (_) {
    const error = new Error("Invalid AI response.");
    error.code = "ai_error";
    throw error;
  }

  if (parsed.refused === true) {
    const error = new Error(
      "This request can't be processed. Celebray only helps write celebration messages.",
    );
    error.code = "content_refused";
    throw error;
  }

  const messages = Array.isArray(parsed.messages)
    ? parsed.messages.map((m) => String(m).trim()).filter(Boolean)
    : [];

  if (messages.length === 0) {
    const error = new Error("No messages returned.");
    error.code = "ai_error";
    throw error;
  }

  return messages.slice(0, 3);
}

function handleError(res, error) {
  const code = error.code || "internal";
  if (code === "unauthorized") {
    res.status(401).json({ error: code, message: error.message });
    return;
  }
  if (code === "rate_limited") {
    res.status(429).json({
      error: code,
      message: error.message,
      limit: error.limit ?? AUTHENTICATED_DAILY_LIMIT,
    });
    return;
  }
  if (code === "content_refused") {
    res.status(422).json({ error: code, message: error.message });
    return;
  }
  if (code === "ai_error") {
    res.status(502).json({ error: code, message: error.message });
    return;
  }

  console.error(error);
  res.status(500).json({ error: "internal", message: "Something went wrong." });
}

const functionOptions = {
  region: "us-central1",
  cors: true,
  secrets: [openAiKey],
  timeoutSeconds: 60,
  memory: "256MiB",
};

exports.generateMessages = onRequest(functionOptions, async (req, res) => {
  setCors(res);
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }
  if (req.method !== "POST") {
    res.status(405).json({ error: "method_not_allowed" });
    return;
  }

  try {
    const user = await verifyAuth(req);
    const limit = dailyLimitForUser(user.isAnonymous);
    await consumeRateLimit(user.uid, limit);

    const event = eventPayload(req.body || {});
    if (!event.name.trim() || !event.type.trim()) {
      res.status(400).json({ error: "invalid_request", message: "Missing event details." });
      return;
    }

    const openai = new OpenAI({ apiKey: openAiKey.value() });
    const messages = await callOpenAi(openai, buildGeneratePrompt(event));

    res.json({
      messages,
      source: "ai",
      limit,
      isAnonymous: user.isAnonymous,
    });
  } catch (error) {
    handleError(res, error);
  }
});

exports.touchUpMessage = onRequest(functionOptions, async (req, res) => {
  setCors(res);
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }
  if (req.method !== "POST") {
    res.status(405).json({ error: "method_not_allowed" });
    return;
  }

  try {
    const user = await verifyAuth(req);

    const body = req.body || {};
    const event = eventPayload(body);
    const currentMessage = String(body.currentMessage || "").trim();
    const instructions = String(body.instructions || "").trim();

    if (!currentMessage) {
      res.status(400).json({ error: "invalid_request", message: "Missing current message." });
      return;
    }

    const policy = assessTouchUpInstructions(instructions);
    if (!policy.allowed) {
      res.status(422).json({
        error: "content_refused",
        message: policy.message,
      });
      return;
    }

    await consumeRateLimit(user.uid, dailyLimitForUser(user.isAnonymous));

    const openai = new OpenAI({ apiKey: openAiKey.value() });
    const messages = await callOpenAi(
      openai,
      buildTouchUpPrompt(event, currentMessage, instructions),
    );

    const limit = dailyLimitForUser(user.isAnonymous);
    res.json({
      messages,
      source: "ai",
      limit,
      isAnonymous: user.isAnonymous,
    });
  } catch (error) {
    handleError(res, error);
  }
});
