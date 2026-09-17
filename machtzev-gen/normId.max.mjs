// 🤖 AUTO-EMITTED by gen-max — normId משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.

export "use strict";
function normId_ORIG(s) {
    const d = (s || '').replace(/\D/g, '');
    if (!d || /^0+$/.test(d))
        return '';
    // מציין-מקום נדרים מרופד: "000000020"/"000000065" — עוברים את /^0+$/ אך אינם ת"ז.
    // אם אחרי הסרת אפסים-מובילים נשארות <4 ספרות-משמעותיות ⇒ לא מפתח.
    if (d.replace(/^0+/, '').length < 4)
        return '';
    return d.length >= 5 ? d : '';
}


export function normId(step, s, opt = {}) {
  const base = normId_ORIG(step, s);
  if (opt.strict !== true) return base;         // ← default: החזק לא נשבר
  if (base !== null) return base;                // המקורי כבר פסל — כבד אותו

  return null;
}
