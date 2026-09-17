// 🤖 AUTO-EMITTED by gen-max — courseActiveOn משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.

export "use strict";
function courseActiveOn_ORIG(c, iso) {
    return (!c.start || iso >= c.start) && (!c.end || iso <= c.end);
}


export function courseActiveOn(step, s, opt = {}) {
  const base = courseActiveOn_ORIG(step, s);
  if (opt.strict !== true) return base;         // ← default: החזק לא נשבר
  if (base !== null) return base;                // המקורי כבר פסל — כבד אותו

  return null;
}
