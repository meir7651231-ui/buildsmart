// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT-SYSTEM V5 — רישום-התצוגה של המודולים (קובץ-consts טהור).
//
// המפה key→(אימוג׳י·שם·תיאור) שהאשף מרנדר: 13 מפתחות-גל-1 — אותו סט-סגור של
// org_gates/המטריצה/החבילות (הבדיקה נועלת שוויון-סטים מדויק, אפס-סחיפה).
// core (catalog·orders) איננו כאן בכוונה — הוא לא-כביה ולכן לא-מוצג-ככפתור.
//
// 'manager' נעול-באשף (kWizardLockedModules): מנהל שמכבה את לוח-המנהל מוחק
// את דלת-הכניסה של עצמו (השורה נעלמת מהבוחר — מוכח במטריצה) — נעילה-עצמית
// אסורה מה-UI; הקונפיג עצמו עדיין יודע false (ייבוא-JSON חיצוני באחריות).
// ─────────────────────────────────────────────────────────────────────────────

/// כרטיס-תצוגה של מודול באשף. immutable כולו.
class OrgModuleInfo {
  const OrgModuleInfo(this.key, this.emoji, this.label, this.descHe);

  /// מפתח-המודול (רישום-גל-1 — org_gates).
  final String key;

  /// אימוג׳י-השורה.
  final String emoji;

  /// השם העברי המוצג.
  final String label;

  /// שורת-הסבר קצרה — מה נעלם כשמכבים.
  final String descHe;
}

/// 13 מודולי-גל-1 בסדר-הרישום הקנוני (= סדר-התצוגה באשף).
const List<OrgModuleInfo> kOrgModules = [
  OrgModuleInfo('chat', '💬', 'שיחות', 'צ׳אט ארגוני — הסגמנט בעדכונים ותאי-הבורדים'),
  OrgModuleInfo('manager', '👔', 'לוח מנהל', 'לוח-הבקרה של מנהל המערכת'),
  OrgModuleInfo('supplier', '🏪', 'לוח ספק', 'פורטל חנות-הספק בבוחר-התפקידים'),
  OrgModuleInfo('courier', '🛵', 'לוח שליח', 'משלוחים, איסופים ופורטל-השליח'),
  OrgModuleInfo('worker', '🦺', 'לוח עובד', 'משימות-שטח ודיווחי-העובד'),
  OrgModuleInfo('finance', '💰', 'כספים', 'מרכז-הפיננסים והפעולה-המהירה בחנות'),
  OrgModuleInfo('rewards', '🎮', 'מועדון', 'מטבעות, אתגרים והטבות'),
  OrgModuleInfo('site', '🏗️', 'אתר ופרויקטים', 'פרויקטים, מלאי-אתר ומשימות-הבית'),
  OrgModuleInfo('compat', '🔩', 'תכנון חיבורים', 'מנוע תאימות-ההברגות (צנרת)'),
  OrgModuleInfo('ai', '🤖', 'עוזר חכם', 'מרכז-ה-AI ושורת-הכלים בלוח'),
  OrgModuleInfo('dive', '🎯', 'מסלולי עומק', 'מסלולי-גילוי ומשחקים בקטלוג'),
  OrgModuleInfo('search', '🔍', 'חיפוש-על', 'החיפוש הגלובלי והמאתר'),
  OrgModuleInfo('intel', '📊', 'מודיעין שוק', 'טאב-המודיעין בלוח-המנהל'),
];

/// מפתחות שהאשף מסרב לכבות (נעילה-עצמית). הקונפיג יודע יותר — ה-UI מגן.
const Set<String> kWizardLockedModules = {'manager'};

// ─────────────────────────────────────────────────────────────────────────────
// GIANT slice-1 — האשף = הסטודיו: תצוגת-מודול לקבלן + מיפוי מסך→מודול.
//
// 'contractor' הוא ה-app-הבסיסי (HomeShell) — אין לו שער-פרסונה ב-org_gates
// ('contractor is deliberately absent — the user's own app is never gated'),
// ולכן הוא **לא** נכנס ל-kOrgModules (הסט-הסגור של 13 השערים; הבדיקה נועלת אותו).
// הוא כן מקבל **סקציית-תצוגה** באשף (👷 לוח קבלן) שמקבצת את אלמנטי-לוח-הקבלן —
// "הפרסונה הראשית חסרה סקציה, זה החור שהבעלים תפס". kWizardModules = קבלן-ראשון
// ואז 13 המודולים; זו רשימת-התצוגה של האקורדיון (14), לא סט-השערים.
// ─────────────────────────────────────────────────────────────────────────────

/// מודול-התצוגה של הקבלן — ה-app-הבסיסי. אין שער-פרסונה (לא ב-kOrgModules);
/// זו סקציית-רכיבים בלבד באשף.
const OrgModuleInfo kContractorModule = OrgModuleInfo(
  'contractor',
  '👷',
  'לוח קבלן',
  'מסך הבית של הקבלן — מסלולי עבודה, כלים וסל הקנייה',
);

/// רשימת-התצוגה של האשף (14): 👷 קבלן ראשון, ואז 13 מודולי-גל-1. **לא** סט-השערים
/// (זה kOrgModules, 13) — רק סדר-התצוגה של אקורדיון-הרכיבים בסגנון-Maor.
const List<OrgModuleInfo> kWizardModules = [kContractorModule, ...kOrgModules];

/// מסך→מפתח-מודול: משייך כל `screen` של הרג׳יסטרי לאחד מ-14 מפתחות-התצוגה, כדי
/// לקבץ את ~896 האלמנטים לסקציות-Maor. דטרמיניסטי, כיסוי-מלא (fallback='manager'
/// לשלד/מערכת). מסכי-הקבלן מפורשים (הדירקטיבה); השאר לפי מילות-מפתח בשם-המסך.
/// הבדיקה נועלת: כל אלמנט ברג׳יסטרי נופל למפתח שקיים ב-kWizardModules.
String moduleForScreen(String screen) {
  if (_kContractorScreens.contains(screen)) return 'contractor';
  final s = screen.toLowerCase();
  if (s.contains('worker')) return 'worker';
  if (s.contains('courier')) return 'courier';
  if (s.contains('store') || s.contains('supplier') || s == 'shop') {
    return 'supplier';
  }
  if (s.contains('manager') ||
      s.contains('role_') ||
      s.contains('persona') ||
      s.contains('audit') ||
      s.contains('regression') ||
      s.contains('authoring') ||
      s.contains('schema_editor') ||
      s.contains('category_tree') ||
      s.contains('business_summary') ||
      s.contains('docs_readiness')) {
    return 'manager';
  }
  if (s.contains('intel')) return 'intel';
  if (s.contains('chat') || s.contains('notif')) return 'chat';
  if (s.contains('finance') || s.contains('budget') || s.contains('credit')) {
    return 'finance';
  }
  if (s.contains('reward')) return 'rewards';
  if (s.contains('ai_') ||
      s.contains('copilot') ||
      s.contains('spec_') ||
      s.contains('quote_') ||
      s == 'ai') {
    return 'ai';
  }
  if (s.contains('connection') ||
      s.contains('accessory') ||
      s.contains('adapter') ||
      s.contains('paired') ||
      s.contains('alt_explain') ||
      s.contains('trade_') ||
      s.contains('install') ||
      s.contains('rule_studio') ||
      s.contains('rule_editor')) {
    return 'compat';
  }
  if (s.contains('search') ||
      s.contains('finder') ||
      s.contains('barcode') ||
      s.contains('scanner') ||
      s.contains('camera') ||
      s.contains('webcam') ||
      s.contains('photo') ||
      s.contains('lens')) {
    return 'search';
  }
  if (s.contains('catalog') ||
      s.contains('lipskey') ||
      s.contains('departments') ||
      s.contains('product_sheet')) {
    return 'dive';
  }
  if (s.contains('site') ||
      s.contains('project') ||
      s.contains('task') ||
      s.contains('stock') ||
      s.contains('defects')) {
    return 'site';
  }
  return 'manager'; // שלד/מערכת (welcome/login/onboarding/studio/…) — בית סביר
}

/// מסכי-לוח-הקבלן (הדירקטיבה) — מקובצים תחת מודול-התצוגה 'contractor'.
const Set<String> _kContractorScreens = {
  'home',
  'smart_home_screen',
  'smart_project_screen',
  'contractor_tools_sheets',
  'contractor_hr_sheet',
  'contractor_attendance_sheet',
  'contractor_material_requests_sheet',
  'home_content_reorder',
  'describe_to_cart_screen',
  'cart',
};
