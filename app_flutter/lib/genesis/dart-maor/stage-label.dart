// חוט · stage-label — תווית שלב-טיפול מותאמת-ארגון (מודול העין). חוזה: stage-label.contract.md
// המרה מ-JS (new/atoms/stage-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן termOf הוזרק כשקע (חוק-1 — אפס import של אטום אחר; dart-core בלבד).
// טבלת-הנפילה STAGE_FALLBACK הוטבעה כקבוע-פרטי (נתון, לא שכן) — כמו במקור.
// קצה: מפתח-שלב לא-מוכר ⇒ ב-JS ‏STAGE_FALLBACK[stage] הוא undefined; ב-Dart ‏Map[k]
// חסר ⇒ null — ייצוג-ה-Dart של undefined בשקע-dynamic. אין ערכי-null מפורשים בטבלה,
// לכן null ⇔ מפתח-חסר בדיוק (חוק-2 לא נשבר — אין הבחנה אבודה).

/// ברירות מחדל ניטרליות לתוויות השלבים (ניתנות לשינוי-שם באשף).

/// stageLabel(cfg, stage, termOf) — כמו ב-JS: המפתח מורכב 'ayin.stage.'+stage,
/// וכל הכרעת-המונח אצל שקע-termOf(cfg, key, fallback).
dynamic stageLabel(dynamic cfg, dynamic stage, dynamic termOf, {required Map<String, dynamic> stageFallback}) {
  return termOf(cfg, 'ayin.stage.' + (stage as String), stageFallback[stage]);
}
