const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const OpenAI = require("openai");

admin.initializeApp();

const openAiKey = defineSecret("OPENAI_API_KEY");
const DAILY_LIMIT = 20;
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
  return admin.auth().verifyIdToken(token);
}

async function consumeRateLimit(uid) {
  const db = admin.firestore();
  const today = new Date().toISOString().slice(0, 10);
  const ref = db.collection("aiUsage").doc(uid).collection("days").doc(today);

  await db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    const count = doc.exists ? doc.data().count || 0 : 0;
    if (count >= DAILY_LIMIT) {
      const error = new Error("Daily AI limit reached.");
      error.code = "rate_limited";
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
  };
}

function buildGeneratePrompt(event) {
  const memoryText =
    event.memories.length > 0
      ? `Shared memories: ${event.memories.join("; ")}.`
      : "No shared memories provided.";

  return `
Write exactly 3 distinct ${event.tone} celebration messages for this person.

Person: ${event.name}
Event type: ${event.type}
Relationship: ${event.relationship}
Closeness (1-10): ${event.closeness}
${memoryText}

Rules:
- Each message under 280 characters.
- Sound personal and human, not generic.
- Match the ${event.tone} tone (${toneDescription(event.tone)}).
- Use emojis sparingly (0-2 per message).
- Do not mention Celebray or being an AI.
- Return JSON only: {"messages":["...","...","..."]}
`.trim();
}

function buildTouchUpPrompt(event, currentMessage, instructions) {
  const memoryText =
    event.memories.length > 0
      ? `Shared memories: ${event.memories.join("; ")}.`
      : "No shared memories provided.";

  return `
Revise this celebration message based on the user's notes.

Person: ${event.name}
Event type: ${event.type}
Relationship: ${event.relationship}
${memoryText}

Current message:
"${currentMessage}"

User notes:
"${instructions || "Polish the message while keeping the same meaning."}"

Write exactly 3 revised versions.
Rules:
- Each message under 280 characters.
- Follow the user's notes when possible.
- Do not mention Celebray or being an AI.
- Return JSON only: {"messages":["...","...","..."]}
`.trim();
}

function toneDescription(tone) {
  switch (tone) {
    case "funny":
      return "light, playful, warm humor";
    case "formal":
      return "polished, respectful, professional";
    default:
      return "heartfelt, warm, sincere";
  }
}

async function callOpenAi(openai, prompt) {
  const completion = await openai.chat.completions.create({
    model: MODEL,
    temperature: 0.9,
    response_format: { type: "json_object" },
    messages: [
      {
        role: "system",
        content:
          "You write short, shareable celebration messages for birthdays and milestones. Always respond with valid JSON.",
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
      limit: DAILY_LIMIT,
    });
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
    await consumeRateLimit(user.uid);

    const event = eventPayload(req.body || {});
    if (!event.name.trim() || !event.type.trim()) {
      res.status(400).json({ error: "invalid_request", message: "Missing event details." });
      return;
    }

    const openai = new OpenAI({ apiKey: openAiKey.value() });
    const messages = await callOpenAi(openai, buildGeneratePrompt(event));

    res.json({ messages, source: "ai", remainingHint: DAILY_LIMIT });
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
    await consumeRateLimit(user.uid);

    const body = req.body || {};
    const event = eventPayload(body);
    const currentMessage = String(body.currentMessage || "").trim();
    const instructions = String(body.instructions || "").trim();

    if (!currentMessage) {
      res.status(400).json({ error: "invalid_request", message: "Missing current message." });
      return;
    }

    const openai = new OpenAI({ apiKey: openAiKey.value() });
    const messages = await callOpenAi(
      openai,
      buildTouchUpPrompt(event, currentMessage, instructions),
    );

    res.json({ messages, source: "ai", remainingHint: DAILY_LIMIT });
  } catch (error) {
    handleError(res, error);
  }
});
