// 🤖 AUTO-EMITTED by gen-max — isRtlLang משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.

export function isRtlLang_ORIG(lang){
  return lang !== 'en';
}

export function isRtlLang(step, s, opt = {}) {
  const base = isRtlLang_ORIG(step, s);
  if (opt.strict !== true) return base;         // ← default: החזק לא נשבר
  if (base !== null) return base;                // המקורי כבר פסל — כבד אותו

  return null;
}
