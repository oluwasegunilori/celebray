const REFUSAL_MESSAGE =
  "This request can't be processed. Celebray only helps write celebration messages.";

const BLOCKED_PATTERNS = [
  /\b(porn|xxx|nude|nudes|naked|hentai|onlyfans|blowjob|handjob|orgasm|dick pic|send nudes)\b/i,
  /\b(fuck you|racist|nazi|white power|kill yourself|kys|gas the|lynch)\b/i,
  /\b(nigg|fagg|chink|spic|kike|wetback|retard)\b/i,
  /\b(rape|molest|pedoph|paedoph)\b/i,
];

const OFF_TOPIC_PATTERNS = [
  /\bignore (all )?(previous|prior|above) instructions\b/i,
  /\b(you are now|act as|pretend to be) (a )?(?!friend|partner|writer)/i,
  /\b(write|generate) (me )?(code|python|javascript|sql|essay|homework)\b/i,
  /\bwhat is the capital of\b/i,
  /\btell me a joke about\b/i,
];

function assessTouchUpInstructions(instructions) {
  const text = String(instructions || "").trim();
  if (!text) {
    return { allowed: true };
  }

  for (const pattern of BLOCKED_PATTERNS) {
    if (pattern.test(text)) {
      return { allowed: false, message: REFUSAL_MESSAGE };
    }
  }

  for (const pattern of OFF_TOPIC_PATTERNS) {
    if (pattern.test(text)) {
      return { allowed: false, message: REFUSAL_MESSAGE };
    }
  }

  return { allowed: true };
}

module.exports = {
  REFUSAL_MESSAGE,
  assessTouchUpInstructions,
};
