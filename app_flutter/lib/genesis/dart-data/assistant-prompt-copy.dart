// 🗄️ דאטה · נוסח-ה-prompt לסיווג-כוונה (BuildSmart) — 15 מקטעי-קופי עבריים קבועים.
// **זו דאטה (נוסח/קופי), לא מנוע.** מוזרקת ל-assistantIntentPrompt כשקע-required `copy`.
// מקור-הנוסח: buildsmart/.../logic/assistant_intent.dart:124-169 (verbatim, ביט-זהה).
// המנוע=הרכבת-ה-buffer בלבד (סדר/חלון/לולאות); הנוסח כאן. תרגום/ניסוח-מחדש = עריכה כאן.
// ⚠️ צימוד-פרוטוקול: מקטעי ה-opt* נושאים את שמות-הפעולות ('answer'/'findProduct'/…) שחייבים
//    להתאים ל-actionFromString. שינוי-נוסח מותר; שינוי-שם-פעולה שובר את הפענוח שבצד-השני.
// הכרעת-בעלים "אפס-דאטה במנוע": מחרוזות-קופי ⇒ יוצאות מהאטום.

const Map<String, String> kAssistantIntentPromptCopyHe = {
  'historyHeader': 'השיחה עד כה:',
  'roleUser': 'משתמש',
  'roleAsst': 'עוזר',
  'userWrotePre': 'המשתמש כתב: "',
  'userWroteSuf': '".',
  'chooseLine': 'בחר פעולה אחת מהרשימה הסגורה והחזר שורת-JSON אחת בלבד:',
  'optAnswer': '- "answer": ענה ישירות. שים את התשובה ב-say, key="".',
  'optFindProduct':
      '- "findProduct": המשתמש מחפש מוצר. key = קטגוריה אחת מרשימת הקטגוריות למטה בדיוק (שורה אחת).',
  'optSummarize': '- "summarizeOrders": המשתמש שואל על ההזמנות/הרכש שלו.',
  'optBudget': '- "checkBudget": המשתמש שואל על התקציב / כמה נשאר.',
  'optAddToCart':
      '- "addToCart": המשתמש מבקש להוסיף ערכה לסל. key = מפתח-ערכה אחד מרשימת הערכות למטה בדיוק (החלק שלפני ה-=).',
  'catsHeader': 'קטגוריות זמינות ל-findProduct:',
  'recipesHeader': 'ערכות זמינות ל-addToCart (מפתח=שם):',
  'formatLine':
      'החזר אך ורק שורת-JSON אחת בפורמט: {"action":"...","key":"...","say":"..."}',
  'fallbackLine': 'אם אף קטגוריה/ערכה לא מתאימה — השתמש ב-answer.',
};
