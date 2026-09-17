// 🤖 AUTO-EMITTED by gen-max — orgBlockError משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.

export function orgBlockError_ORIG(dateIso){
  const br = blockReason(dateOf(dateIso), 'org');
  if (!br) return null;
  return br === 'שבת' ? 'לא ניתן לקבוע אירוע ארגוני בשבת' : 'לא ניתן לקבוע אירוע ארגוני ב' + br;
}

export function orgBlockError(step, s, opt = {}) {
  const base = orgBlockError_ORIG(step, s);
  if (opt.strict !== true) return base;         // ← default: החזק לא נשבר
  if (base !== null) return base;                // המקורי כבר פסל — כבד אותו

  return null;
}
