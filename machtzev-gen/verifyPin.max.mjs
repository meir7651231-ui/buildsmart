// 🤖 AUTO-EMITTED by gen-max — verifyPin משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.

export async function verifyPin_ORIG(pin, hash){
  if (!hash) return false;
  if (hash.startsWith('v2:')) {
    const [, saltHex, digest] = hash.split(':');
    if (!saltHex || !digest) return false;
    return (await pbkdf2Pin(pin, saltHex)) === digest;
  }
  return (await legacyHashPin(pin)) === hash;
}

export function verifyPin(step, s, opt = {}) {
  const base = verifyPin_ORIG(step, s);
  if (opt.strict !== true) return base;         // ← default: החזק לא נשבר
  if (base !== null) return base;                // המקורי כבר פסל — כבד אותו

  return null;
}
