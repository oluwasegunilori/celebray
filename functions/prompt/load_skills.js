const fs = require("fs");
const path = require("path");

let cachedSkills = null;

function loadSkillsMarkdown() {
  if (cachedSkills) return cachedSkills;

  const skillsPath = path.join(__dirname, "skills.md");
  cachedSkills = fs.readFileSync(skillsPath, "utf8").trim();
  return cachedSkills;
}

function buildSystemPrompt() {
  return `${loadSkillsMarkdown()}

Output format: respond with valid JSON only.
- Normal response: {"messages":["message one","message two","message three"]}
- Refusal (inappropriate or off-topic touch-up notes): {"refused": true}`;
}

function eventTypeSkill(type) {
  const lower = String(type || "").toLowerCase();

  if (lower.includes("memorial")) {
    return "EVENT SKILL: Memorial — gentle, honoring tone. No humor. No 'happy'.";
  }
  if (lower.includes("anniversary") || lower.includes("wedding") || lower.includes("engagement")) {
    return "EVENT SKILL: Relationship milestone — celebrate the bond or journey together.";
  }
  if (lower.includes("graduation") || lower.includes("promotion") || lower.includes("retirement") || lower.includes("launch") || lower.includes("work anniversary")) {
    return "EVENT SKILL: Achievement milestone — pride, encouragement, respect.";
  }
  if (lower.includes("baby") || lower.includes("shower")) {
    return "EVENT SKILL: New life / family joy — warm, celebratory, family-friendly.";
  }
  if (lower.includes("sobriety")) {
    return "EVENT SKILL: Sobriety milestone — proud and respectful; never glib.";
  }
  if (lower.includes("birthday")) {
    return "EVENT SKILL: Birthday — celebratory and personal.";
  }

  return `EVENT SKILL: ${type} — match the spirit of this celebration appropriately.`;
}

function relationshipSkill(relationship) {
  const lower = String(relationship || "").toLowerCase();
  const professional = ["boss", "client", "colleague", "teacher", "coach", "mentor"];

  if (professional.some((r) => lower.includes(r))) {
    return "RELATIONSHIP SKILL: Professional relationship — warm but appropriate; no slang or oversharing.";
  }
  if (lower.includes("best friend") || lower.includes("partner") || lower.includes("boyfriend") || lower.includes("girlfriend") || lower.includes("fianc") || lower.includes("husband") || lower.includes("wife")) {
    return "RELATIONSHIP SKILL: Close personal bond — personal, natural, can be casual if tone allows.";
  }
  if (lower.includes("mother") || lower.includes("father") || lower.includes("grand") || lower.includes("aunt") || lower.includes("uncle") || lower.includes("parent")) {
    return "RELATIONSHIP SKILL: Family — loving, respectful, family-appropriate.";
  }

  return `RELATIONSHIP SKILL: ${relationship} — write as someone who knows them in this role.`;
}

function closenessSkill(closeness) {
  const score = Number(closeness) || 5;
  if (score <= 3) return "CLOSENESS: 1–3 — polite and safe, not overly intimate.";
  if (score <= 6) return "CLOSENESS: 4–6 — friendly and warm.";
  return "CLOSENESS: 7–10 — personal and heartfelt.";
}

function toneLine(tone) {
  switch (tone) {
    case "funny":
      return "REQUESTED TONE: funny — light, playful, kind humor.";
    case "formal":
      return "REQUESTED TONE: formal — polished and respectful.";
    case "prayerful":
      return "REQUESTED TONE: prayerful — reverent blessings, gratitude, optional short sacred text; up to 480 characters if needed.";
    default:
      return "REQUESTED TONE: warm — sincere and heartfelt.";
  }
}

function religionSkill(faithContext) {
  const faith = String(faithContext || "").trim();
  if (!faith || faith.toLowerCase() === "none") {
    return "FAITH CONTEXT: none — keep messages secular unless prayerful tone explicitly asks for general spiritual warmth without specific tradition.";
  }

  const lower = faith.toLowerCase();

  if (lower.includes("christian")) {
    return "FAITH CONTEXT: Christianity — blessings, grace, optional short Bible verse with book/chapter reference; accurate quotes only.";
  }
  if (lower.includes("islam") || lower.includes("muslim")) {
    return "FAITH CONTEXT: Islam — barakah, dua, gratitude to Allah; optional short Quran reference or authentic dua; respectful tone.";
  }
  if (lower.includes("jew")) {
    return "FAITH CONTEXT: Judaism — mazel tov, blessings, optional short Psalms or Torah reference; accurate quotes only.";
  }
  if (lower.includes("hindu")) {
    return "FAITH CONTEXT: Hinduism — respectful blessings for joy, prosperity, and well-being; avoid stereotypes.";
  }
  if (lower.includes("buddh")) {
    return "FAITH CONTEXT: Buddhism — peace, compassion, mindfulness; gentle and non-preachy.";
  }

  return `FAITH CONTEXT: ${faith} — honor this tradition respectfully; prefer accurate short quotes or paraphrased blessings.`;
}

function lengthSkill(tone, faithContext) {
  const faith = String(faithContext || "").trim();
  const hasFaith = faith && faith.toLowerCase() !== "none";
  if (tone === "prayerful" || hasFaith) {
    return "LENGTH: up to 480 characters per message when a short sacred quote or blessing is included; otherwise under 320.";
  }
  return "LENGTH: under 320 characters per message.";
}

module.exports = {
  buildSystemPrompt,
  eventTypeSkill,
  relationshipSkill,
  closenessSkill,
  toneLine,
  religionSkill,
  lengthSkill,
};
