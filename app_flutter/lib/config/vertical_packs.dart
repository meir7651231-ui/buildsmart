// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT-SYSTEM V4 — חבילות-ורטיקל (הכותרת של התוכנית).
//
// חבילה = פרוסת-זהות מוכנה-מראש: terms+modules של ורטיקל אחד. האשף (V5) מציג
// את הרשימה, המנהל בוחר — ו-applyVerticalPack נותן נקודת-פתיחה דטרמיניסטית:
// ה-terms+modules של החבילה מחליפים **במלואם** את אלה שבקונפיג (לא merge —
// כדי ששתי הפעלות של אותה חבילה יתנו תמיד את אותה תוצאה, בלי שאריות), ושאר
// הקונפיג (slug · orgName · theme · features) נשמר כפי-שהוא — לפי V4.3.
//
// תוכן החבילות = **נקודות-פתיחה בלבד** (V4.2 — החלטת-בעלים): הרשימה עצמה היא
// רשימת-הדוגמה של התוכנית; הפרוסות כאן מינימליות-ומגנות — כיבוי מודול רק
// כשהוא עובדת-דומיין (מנוע-החיבורים compat הוא הברגות-צנרת: לחשמל/כלים/קרמיקה
// הוא משקל-מת), והמילון ריק (מונחים = כיוונון-בעלים באשף). הכל הפיך: החלת
// חבילה אחרת — או חבילת-הבסיס — מאפסת את הפרוסה.
//
// דיסציפלינה: קבצי-consts טהורים בלבד (אפס Flutter/Riverpod) — כמו org_config.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart' show OrgConfig;

/// פרוסת-זהות של ורטיקל: מה שהאשף מחיל בלחיצה. immutable כולו.
class VerticalPack {
  const VerticalPack({
    required this.id,
    required this.emoji,
    required this.label,
    this.terms = const {},
    this.modules = const {},
  });

  /// מזהה יציב (לטיני, לא-מוצג) — נשמר עם הקונפיג ומזוהה בבדיקות.
  final String id;

  /// אימוג׳י-הכרטיס באשף.
  final String emoji;

  /// השם העברי המוצג.
  final String label;

  /// מילון-המונחים של הוורטיקל (מפתחות מרישום-V3 בלבד; ריק = אוצר-המילים הקיים).
  final Map<String, String> terms;

  /// מפת-המודולים של הוורטיקל (רק false מכבה; ריק = הכל-דלוק; core לא-נגיע).
  final Map<String, bool> modules;
}

/// רשימת-החבילות — הסדר = סדר-התצוגה באשף; הראשונה היא ברירת-המחדל
/// (העולם הנוכחי של האפליקציה: ספק חומרי בניין, הכל-דלוק, אפס-מונחים).
const List<VerticalPack> kVerticalPacks = [
  VerticalPack(
    id: 'building_supplier',
    emoji: '🧱',
    label: 'ספק חומרי בניין',
    // חבילת-הזהות: terms/modules ריקים ⇒ בדיוק האפליקציה של היום.
  ),
  VerticalPack(
    id: 'plumbing',
    emoji: '🚿',
    label: 'אינסטלציה',
    // compat נשאר דלוק בכוונה — מנוע-החיבורים (BSP) הוא הלחם של הוורטיקל.
    modules: {'dive': false, 'intel': false},
  ),
  VerticalPack(
    id: 'electric',
    emoji: '⚡',
    label: 'חשמל',
    modules: {'compat': false, 'dive': false, 'intel': false},
  ),
  VerticalPack(
    id: 'tools',
    emoji: '🔧',
    label: 'כלים וחומרה',
    modules: {'compat': false},
  ),
  VerticalPack(
    id: 'ceramics',
    emoji: '⬜',
    label: 'קרמיקה ואריחים',
    modules: {'compat': false, 'dive': false},
  ),
  VerticalPack(
    id: 'contractor',
    emoji: '🏗️',
    label: 'קבלן כללי',
    // העולם המלא — חברה שפונה לקבלנים רוצה את כל המנועים.
  ),
];

/// איתור חבילה לפי מזהה — לאשף ולשחזור-config שנשמר. לא-נמצא ⇒ null (טוטאלי).
VerticalPack? verticalPackById(String id) {
  for (final p in kVerticalPacks) {
    if (p.id == id) return p;
  }
  return null;
}

/// V4.3 — החלת חבילה: terms+modules מוחלפים **במלואם** (נקודת-פתיחה
/// דטרמיניסטית — הפעלה-כפולה ≡ הפעלה-אחת, אפס-שאריות מהחבילה הקודמת);
/// slug · orgName · theme · features נשמרים כפי-שהם. הפיך בהחלת חבילה אחרת.
OrgConfig applyVerticalPack(OrgConfig cfg, VerticalPack pack) => OrgConfig(
      slug: cfg.slug,
      orgName: cfg.orgName,
      theme: cfg.theme,
      features: cfg.features,
      modules: pack.modules,
      terms: pack.terms,
    );
