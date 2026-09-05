// 🗄️ דאטה · תוויות-הסבר לכשל-חיבור (connection-fail messages) — 18 תבניות/תוויות עבריות.
// **זו דאטה (תוויות-לקוח), לא מנוע.** מוזרקת ל-connectionFailReason כשקע-required `labels`.
// מקור-הנוסח: buildsmart/.../logic/install_engine.dart:523-592 (verbatim, ביט-זהה).
// המנוע בונה את ההודעה מטוקנים מוזרקים: `{0}`/`{1}` מוחלפים בערכים (גדלים/חומרים/תוויות-מין).
// שינוי-נוסח / תרגום = עריכת-שורה כאן. אפס-נגיעה בקסקדת-ההחלטה (connection_fail_reason.dart).
// הכרעת-בעלים "אפס-דאטה במנוע": מחרוזות-תוויות ⇒ יוצאות מהאטום.

const Map<String, String> kConnectionFailLabelsHe = {
  // — ענף-מאומת (VerifiedView) —
  'sizeDiffDn': 'גודל שונה: DN{0} ↔ DN{1}',
  'pexDiff': 'גודל PEX שונה: {0} ↔ {1}',
  'copperDiff': 'גודל נחושת שונה: DN{0} ↔ DN{1}',
  'bothMaleVerified': 'שני קצוות זכר {0}" — אין חיבור',
  'bothFemaleVerified': 'שני קצוות נקבה {0}" — אין חיבור',
  'threadSizeDiff': 'גודל תבריג שונה: {0}" ↔ {1}"',
  'materialAdapter': 'נדרש מתאם מעבר: {0} ↔ {1}',
  // — משותף / ענף name-inference —
  'noCommon': 'אין נקודת חיבור משותפת',
  'sizeUnknown': 'גודל חיבור לא ידוע',
  'sizeDiff': 'גודל שונה: {0} ↔ {1}',
  'genderUnknown': 'מין חיבור לא ידוע',
  'bothEnds': 'שני קצוות {0} — אין חיבור',
  'methodDiff': 'שיטה שונה: {0} ↔ {1}',
  // — תוויות-אטום (מין / שיטה) —
  'genderMale': 'זכר',
  'genderFemale': 'נקבה',
  'methodThread': 'תבריג',
  'methodGlue': 'הדבקה',
  'methodElse': 'אלקטרו',
};
