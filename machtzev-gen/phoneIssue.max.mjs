// 🤖 AUTO-EMITTED by gen-max — phoneIssue משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.

export function phoneIssue_ORIG(p){
  if (!p || p === '-') return null;
  const d = digits(p);
  if ((d.length === 9 || d.length === 10) && d[0] === '0') return null;
  if (d.length === 8) return 'כנראה חסרה ספרת 0 מובילה: ' + p;
  if (d.length < 7) return 'קצר מדי: ' + p;
  if (d[0] !== '0') return 'לא מתחיל ב-0: ' + p;
  return 'אורך חריג (' + d.length + ' ספרות): ' + p;
}

export function phoneIssue(step, s, opt = {}) {
  const base = phoneIssue_ORIG(step, s);
  if (opt.strict !== true) return base;         // ← default: החזק לא נשבר
  if (base !== null) return base;                // המקורי כבר פסל — כבד אותו

  return null;
}
