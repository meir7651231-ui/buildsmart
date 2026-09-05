// 🎨 schoolos.dart בעור-forge (GENMAX·G12d) — מחולל דטרמיניסטי: skin-golden.mjs · הזהב לא נגע (טעינה-לצד, חוק-7) · עור: kpi=ForgeStatPlain · navTile=ForgeHubTile · stat=ForgeStatPlain · hero=ForgeStatPlain · button=ForgeSoftButton · statusChip=ForgeIntelPill · banner=ForgeSectionPill · emptyState=ForgeSearchEmptyState · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegmentedPillToggleSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeGlassCard · timeline=ForgeNotifRow
//   החלפות: stat×0 · hero×1 · statRow×25 · kpi×2 · navTile×9 · button×11 · statusChip×3 · banner×6 · emptyState×2 · mediaRow×4 · section×4 · segmented×3 · meter×3 · frame×4 · timeline×2 · BareStat ב-Row נשאר DS (רצועת-4) · צבעי-מצב-DS לא מועברים · חיפוש/טבלאות/פילטרים = DS (אטומי-forge של קלט הם ציור, לא שדה)
// 🏫 SchoolOS — בנייה מאפס לפי THE-WAY הנכון (פעולה-ראשונה · הרכבה-תמיד).
// כל מסך: מטרה → פעולות-יסוד הכי-מתאימות → הרכבה (תמיד כמה) → חיווט → אימות-מול-המטרה.
// בוחרים פעולת-יסוד, לא "אטום"; האטום רק מגלם. לעולם אין אטום-אחד שמשרת מטרה מקסימלית.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל-הפריט (child שרירותי) — פאנל-צד
import '../dart-ui-bs/premium/surfaces/stat_hero.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/actions/segmented_switch.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-maor/shekel.dart'; // אטומי-לוגיקה (§21 שכבת-הלוגיקה) — מחווטים מהמדף, לא inline:
import '../dart-maor/clamp-scale.dart'; // נרמול/הצמדה לגבולות
import '../dart-maor/warehouse-value.dart'; // ערך-מלאי Σ(qty×cost) — אטום-מלאי דומייני
import '../dart-maor/warehouse-overview.dart'; // מחסור-מול-צריכה: מלאי−הקצאה→remaining→short
import '../dart-maor/grand-total.dart'; // Σ-לפי-מפתח (kpi כמות-כוללת)
import '../dart-ui-bs/premium/lists/stat_row.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-ui-bs/ds/ds_search.dart'; // חיפוש-מבוקר (value+onChanged) — פעולת-יסוד "איתור"
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // מצב "אין-תוצאות" (glyph+message)
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows, מיון-בלחיצה) — לא DataGrid המזייף
import '../dart-maor/intake-log.dart'; // מנוע-אמת: יומן-קליטות (חדש-ראשון + Σעלות) — פעולת-יסוד "אימות"
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND (מדף)
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM (מדף)
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא (חוסם CSV-injection) (מדף)
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע (מדף)
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל admin/teacher/staff (מדף)
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה פר-מפתח (מדף)
import '../dart-maor/expiring-intakes.dart'; // אוטומציה: קליטות-פוקעות תוך חלון (מדף)
import '../dart-maor/shop-expiry-warn-days.dart'; // אוטומציה: סף-אזהרת-פקיעה =7 (מדף)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // פריט-ציר-זמן (title/time/body) — לא timeline_flow המזייף
// ═══ 8 מודולי-SchoolOS — נבנו בסשני-בנאי נפרדים (מגילת SCHOOLOS-ORCHESTRATION §2), מחווטים כאן ע"י המנהל (כותב-יחיד) ═══
import 'gen_schoolos_students_forge.dart';   // 🎓 תלמידים · StudentsScreen
import 'gen_schoolos_attendance_forge.dart'; // 📋 נוכחות · AttendanceScreen
import 'gen_schoolos_courses_forge.dart';    // 📚 חוגים/מערכת · CoursesScreen
import 'gen_schoolos_teachers_forge.dart';   // 👩‍🏫 מורים · TeachersScreen
import 'gen_schoolos_rooms_forge.dart';      // 🚪 חדרים · RoomsScreen
import 'gen_schoolos_fees_forge.dart';       // 💳 גבייה · FeesScreen
import 'gen_schoolos_parents_forge.dart';    // 👪 הורים · ParentsScreen
import 'gen_schoolos_dashboard_forge.dart';  // 📊 לוח-הנהלה · DashboardScreen
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/feedback/feedback.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/list/list.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (BareStat דורש הזרקת-צבע — חוק-6: צבע=הצבה, לא ציור)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

void main() => runApp(const SchoolOsApp());

class SchoolOsApp extends StatelessWidget {
  const SchoolOsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: _acc, brightness: Brightness.dark)),
        builder: (c, ch) => PureScope(
          theme: DsPure.themes[DsPure.defaultTheme]!,
          fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'),
          child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        ),
        home: const _Home(),
      );
}

// ═══════════ בית · מטרה: "לדעת מה דורש-פעולה עכשיו — בלי שדבר יישמט" ═══════════
class _Home extends StatelessWidget {
  const _Home();
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = ['dashboard', 'students', 'attendance', 'courses', 'teachers', 'rooms', 'fees', 'parents', 'inventory']; // 9 מסכים מחווטים
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'SchoolOS', subtitle: 'תיכון עתיד · מה דורש-פעולה עכשיו', icon: '🏫',
        children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 168, child: ForgeStatPlain(fields: ['מסכים מחוברים', '${_Home.modules.length}'])), // עובדה-אמת (לא '1,248' מומצא — L-goal-proof-af3c91)
            SizedBox(width: 168, child: ForgeStatPlain(fields: ['מלאי לא-יספיק', '${_InvData.urgent}'])),
          ]),
          const SizedBox(height: 8),
          ForgeTitledSection(fields: ['כלים', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const DashboardScreen()), child: ForgeHubTile(fields: ['לוח-הנהלה', 'מה דורש החלטה היום — נגזרת של כל המודולים'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const StudentsScreen()), child: ForgeHubTile(fields: ['תלמידים', 'תיק-תלמיד · סיכון · שיבוץ · מעבר-שנה'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const AttendanceScreen()), child: ForgeHubTile(fields: ['נוכחות', 'מי חסר עכשיו · חיסורים · השלמות'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const CoursesScreen()), child: ForgeHubTile(fields: ['חוגים ומערכת', 'תפוסה · המתנה · מערכת-שעות'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const TeachersScreen()), child: ForgeHubTile(fields: ['מורים', 'עומס · חלון-פנוי · תפקידים'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const RoomsScreen()), child: ForgeHubTile(fields: ['חדרים', 'יומן-חדרים · התנגשויות · שיבוץ-מחדש'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const FeesScreen()), child: ForgeHubTile(fields: ['גבייה', 'חובות · הסדרים · תזכורות (אפס-קבלה)'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const ParentsScreen()), child: ForgeHubTile(fields: ['הורים', 'קשר · שידור · הסכמות'])),
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _go(context, const _Inventory()), child: ForgeHubTile(fields: ['מלאי', 'ימים-עד-ריקון מול אספקה — שלא ייגמר'])),
          ]])),
        ],
      );
}

// ═══════════ מלאי · מטרה: "שלא ייגמר פריט קריטי בלי שנספיק להזמין" ═══════════
// "לא ייגמר" זה ציר-זמן, לא מפלס-סטטי. פירוק-אמת לכמה פעולות-יסוד (הרכבה-תמיד):
//  1. ימים-עד-ריקון = מלאי ÷ קצב-צריכה   → הקרבה האמיתית (כמו dayDiff בלוח)
//  2. השוואה מול זמן-אספקה               → יספיק/לא-יספיק
//  3. דירוג לפי ימים-עד-ריקון            → הכי-דחוף ראשון
//  4. ציור runway מול-אספקה (StatRow)    → רואים בעין אם הבר מתחת לקו-האספקה
//  5. דגל-הזמנה                          → פעולה
// דאטה+מנוע טהור (אפס-DOM): חוזה-הפריט + הפסים. חוזה: knowledge/INVENTORY-DATA-CONTRACT-2026-09-02.md
//   שדות-חובה: name·cur·target·rate·lead · שדות-אופציה: supplier?·price? (מוצגים רק כשקיימים).
class _InvData {
  static const int horizon = 4; // חלון-תכנון: כמה ימים מראש מזהירים לפני שחייבים להזמין
  // 🔴 סכמת-פריט = רק שדות עם מקור-אמת באימפריה (סוכן-דאטה 3.9 · §20-ג אפס-זיוף):
  //   name·cur(qty)·price(cost)·unit → maor WarehouseItem (domain.ts:464-473)
  //   minStock → maor ShopItem (domain.ts:921) · expiry·supplier(source) → maor ShopIntake (domain.ts:962-967)
  //   sku → buildsmart InventoryItem (store_inventory.dart:99) · cat → buildsmart CatalogProduct (catalog.ts)
  //   target·rate·lead = קלט-תכנון בית-ספרי (runway) — לא נגזרת-מזויפת. available = warehouseOverview.remaining (נגזר).
  //   ⛔ ללא-מקור ⇒ הושמטו (לא מזייפים): barcode · reorderQty · מיקום-מדף · מחסן-מרובה · reserved(=נגזר-מהקצאה).
  static const items = <Map<String, dynamic>>[
    {'name': 'טונר מדפסת', 'cur': 3, 'target': 20, 'rate': 1.0, 'lead': 4, 'supplier': 'אופיס-דיפו', 'price': 89, 'sku': 'TNR-118', 'cat': 'משרד', 'unit': 'יח׳', 'minStock': 5, 'warehouse': 'מרכזי', 'barcode': '7290011118'},
    {'name': 'נייר A4 (חבילות)', 'cur': 8, 'target': 30, 'rate': 2.0, 'lead': 5, 'supplier': 'פייפר-מיל', 'price': 45, 'sku': 'PPR-A4', 'cat': 'משרד', 'unit': 'חב׳', 'minStock': 10, 'warehouse': 'מרכזי', 'barcode': '7290011045'},
    {'name': 'חומרי ניקוי', 'cur': 40, 'target': 80, 'rate': 3.0, 'lead': 7, 'supplier': 'קלין-קו', 'price': 32, 'sku': 'CLN-01', 'cat': 'אחזקה', 'unit': 'ליטר', 'minStock': 20, 'expiry': '2026-09-08', 'warehouse': 'אחזקה'},
    {'name': 'ערכות מעבדה', 'cur': 6, 'target': 40, 'rate': 0.5, 'lead': 10, 'supplier': 'סיינס-לאב', 'price': 240, 'sku': 'LAB-KIT', 'cat': 'מעבדה', 'unit': 'ערכה', 'minStock': 8, 'warehouse': 'מעבדה'},
    {'name': 'מקרנים (חלופיים)', 'cur': 22, 'target': 30, 'rate': 0.2, 'lead': 14, 'supplier': 'טק-ויז׳ן', 'price': 1200, 'sku': 'PRJ-X', 'cat': 'אלקטרוניקה', 'unit': 'יח׳', 'minStock': 3, 'warehouse': 'מרכזי'},
    {'name': 'מדפסת-מטריצה (הופסק)', 'cur': 2, 'target': 0, 'rate': 0.1, 'lead': 30, 'supplier': 'ישן', 'price': 300, 'sku': 'DOT-OLD', 'cat': 'משרד', 'unit': 'יח׳', 'minStock': 0, 'active': false}, // פריט-לא-פעיל (מצב-מיוחד)
  ];
  // ─── פנקס-התאמות-מלאי (פעולות=state): מלאי-אפקטיבי = בסיס-const + Σהתאמות (חוק-1 · מצב=חיווט) ───
  //   הבסיס נשאר const (מקור-האמת); הפעולות רושמות התאמה + תנועה — כמו פנקס-תנועות אמיתי.
  static const today = '2026-09-03'; // תאריך-הזרקה דטרמיניסטי (VERIFY: אין Date.now במנוע)
  static final Map<String, int> adj = {}; // התאמה מצטברת פר-פריט
  static int curOf(Map<String, dynamic> s) => (s['cur'] as int) + (adj[s['name']] ?? 0); // מלאי-אפקטיבי
  static final List<Map<String, dynamic>> extraMoves = []; // תנועות מפעולות (בצורת-ShopIntake)
  static void receive(Map<String, dynamic> s, int n) { // 📥 קבלת-מלאי
    if (n <= 0) return;
    final name = s['name'] as String;
    adj[name] = (adj[name] ?? 0) + n;
    extraMoves.insert(0, {'itemId': name, 'date': today, 'qty': n, 'kind': 'buy', 'source': 'קליטה-ידנית', 'cost': n * ((s['price'] as int?) ?? 0)});
    _ovCache = null; // הקצאה-מול-מלאי תלויה ב-cur ⇒ ריענון
  }
  static int issue(Map<String, dynamic> s, int n) { // 📤 הוצאת-מלאי (לא יותר מהקיים)
    final take = n > curOf(s) ? curOf(s) : n;
    if (take <= 0) return 0;
    final name = s['name'] as String;
    adj[name] = (adj[name] ?? 0) - take;
    extraMoves.insert(0, {'itemId': name, 'date': today, 'qty': -take, 'kind': 'issue', 'source': 'הוצאה-ידנית', 'cost': 0});
    _ovCache = null;
    return take;
  }
  static void countTo(Map<String, dynamic> s, int value) { // 🔢 ספירה: קובע מלאי מדויק
    final name = s['name'] as String;
    final delta = value - curOf(s);
    if (delta == 0) return;
    adj[name] = (adj[name] ?? 0) + delta;
    extraMoves.insert(0, {'itemId': name, 'date': today, 'qty': delta, 'kind': 'count', 'source': 'ספירת-מלאי', 'cost': 0});
    _ovCache = null;
  }
  // חוזה-תצוגה של שדות-מטא = דאטה (לא קוד-פר-שדה). המקום-השמור: הרינדור לולאה גנרית מעל זה.
  // הוספת שורה כאן ⇒ השדה מופיע לכל רשומה שנושאת אותו, אפס-שינוי-קוד (מבחן-הקונכייה, חוק-7).
  // (מלאי 'cur' שודרג מ-chip ל-StatRow נוגזרת נוכחי/יעד — לכן יצא מכאן; אלה נשארים facts אטומיים)
  static const metaFields = <Map<String, String>>[
    {'key': 'sku', 'prefix': '🔖 ', 'suffix': ''},
    {'key': 'cat', 'prefix': '🗂 ', 'suffix': ''},
    {'key': 'rate', 'prefix': '', 'suffix': '/יום'},
    {'key': 'supplier', 'prefix': '🏭 ', 'suffix': ''},
    {'key': 'price', 'prefix': '₪ ', 'suffix': ' ליח׳'},
  ];

  static double daysLeft(Map<String, dynamic> s) => curOf(s) / (s['rate'] as double);
  // כמה ימים עד שחייבים להזמין = ימים-עד-ריקון − זמן-אספקה (שלילי ⇒ כבר עברת)
  static double mustOrderIn(Map<String, dynamic> s) => daysLeft(s) - (s['lead'] as int);
  // שלושת-הפסים (הגוי-האמת של "בזמן להזמין"): 2=הזמן-היום · 1=הזמן-בקרוב · 0=בטוח
  static int band(Map<String, dynamic> s) {
    final m = mustOrderIn(s);
    if (m <= 0) return 2;
    if (m <= horizon) return 1;
    return 0;
  }

  static int qty(Map<String, dynamic> s) => ((s['target'] as int) - curOf(s)).clamp(0, s['target'] as int);
  static int get urgent => items.where((s) => sev(s) == 2).length; // דחיפות-מאוחדת (ל-_Home)

  // ─── מודל שני (מפורק): צריכה-מוקצית-לצרכנים → מחסור. חוברים לקצב ל"מקסימום-מטרה". ───
  // צרכנים = כיתות/מחלקות שצורכות ציוד (ayin.mat = [{name, qty}] — צורת-הקלט של warehouseOverview).
  static const consumers = <Map<String, dynamic>>[
    {'id': 'sci', 'name': 'מעבדת מדעים', 'ayin': {'mat': [{'name': 'ערכות מעבדה', 'qty': 30}, {'name': 'טונר מדפסת', 'qty': 2}]}},
    {'id': 'adm', 'name': 'מזכירות', 'ayin': {'mat': [{'name': 'טונר מדפסת', 'qty': 4}, {'name': 'נייר A4 (חבילות)', 'qty': 12}]}},
    {'id': 'jan', 'name': 'אחזקה', 'ayin': {'mat': [{'name': 'חומרי ניקוי', 'qty': 20}]}},
    {'id': 'cls', 'name': 'כיתות א׳-ו׳', 'ayin': {'mat': [{'name': 'נייר A4 (חבילות)', 'qty': 25}, {'name': 'מקרנים (חלופיים)', 'qty': 5}]}},
  ];
  // ─── יומן-תנועות בצורת-ShopIntake (מקור-אמת: domain.ts:955-968) — מוזן למנוע-האמת intakeLog ───
  //   itemId·date·qty·kind·source·cost = השדות האמיתיים של ShopIntake. אפס-המצאה.
  static const movements = <Map<String, dynamic>>[
    {'itemId': 'טונר מדפסת', 'date': '2026-09-01', 'qty': 12, 'kind': 'buy', 'source': 'אופיס-דיפו', 'cost': 1068},
    {'itemId': 'נייר A4 (חבילות)', 'date': '2026-08-28', 'qty': 40, 'kind': 'buy', 'source': 'פייפר-מיל', 'cost': 1800},
    {'itemId': 'חומרי ניקוי', 'date': '2026-08-25', 'qty': 60, 'kind': 'donation', 'source': 'תרומת-הורים', 'cost': 0},
    {'itemId': 'ערכות מעבדה', 'date': '2026-08-20', 'qty': 10, 'kind': 'buy', 'source': 'סיינס-לאב', 'cost': 2400},
    {'itemId': 'טונר מדפסת', 'date': '2026-08-15', 'qty': 6, 'kind': 'buy', 'source': 'אופיס-דיפו', 'cost': 534},
  ];
  // db בצורת-הקלט של intakeLog: shopItems id=name (הפריטים כאן מזוהים-בשם)
  static Map<String, Object?> get movDb => {
        'shopIntakes': [...extraMoves, ...movements], // תנועות-הפעולות + הבסיס (intakeLog ממיין תאריך-יורד)
        'shopItems': [for (final s in items) {'id': s['name'], 'name': s['name']}],
      };

  static String norm(dynamic s) => (s as String).trim(); // שקע-נרמול (חוק-1) — מוזרק ל-warehouseOverview
  // המלאי בצורת-הקלט של האטום {name, qty, cost}
  static List<Map<String, dynamic>> get _wh =>
      [for (final s in items) {'name': s['name'], 'qty': curOf(s), 'cost': s['price'] ?? 0}];
  // הסקירה המפורקת פר-שם: {item, allocated, remaining, short, byProject}
  static Map<String, Map<String, dynamic>>? _ovCache;
  static Map<String, Map<String, dynamic>> overview() =>
      _ovCache ??= {for (final r in warehouseOverview(_wh, consumers, norm)) (r['item'] as Map)['name'] as String: r};

  static bool isShort(Map<String, dynamic> s) => overview()[s['name']]?['short'] == true;
  static int allocated(Map<String, dynamic> s) => ((overview()[s['name']]?['allocated'] as num?) ?? 0).toInt();
  static int deficit(Map<String, dynamic> s) => (allocated(s) - curOf(s)).clamp(0, 1 << 30); // חסר-לכיסוי-הקצאה

  // 🎯 דחיפות מאוחדת (מקסום-מטרה): short OR band. גירעון-הקצאה ⇒ "חייבים" גם אם הריצה ארוכה.
  static int sev(Map<String, dynamic> s) {
    final b = band(s);
    return isShort(s) && b < 2 ? 2 : b;
  }

  // כמות-הזמנה מאוחדת: מכסה גם יעד-בריא (target−cur) וגם גירעון-הקצאה (allocated−cur) — הגדול.
  static int orderQty(Map<String, dynamic> s) {
    final t = qty(s), d = deficit(s);
    return t > d ? t : d;
  }

  // ─── KPI-8 · פעולת-יסוד "הערכת-מצב" (כולם מנועי-מדף/שדות-אמת, אפס-StatBlock) ───
  static int minStock(Map<String, dynamic> s) => (s['minStock'] as int?) ?? 0;
  static bool belowMin(Map<String, dynamic> s) => curOf(s) < minStock(s); // מקור: ShopItem.minStock
  static bool isOut(Map<String, dynamic> s) => curOf(s) <= 0;             // אזל
  static bool slow(Map<String, dynamic> s) => (s['rate'] as double) < 0.5;          // איטי-תנועה (קצב-תכנון נמוך)
  static bool expiring(Map<String, dynamic> s) => s['expiry'] != null;              // מקור: ShopIntake.expiry
  // available = מלאי − הוקצה-לצרכנים (warehouseOverview.remaining) — נגזר, לא stored 'reserved'
  static int available(Map<String, dynamic> s) => ((overview()[s['name']]?['remaining'] as num?) ?? curOf(s)).toInt();

  // ═══ איתור (הכרעה 23-ג · תובנה·3) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch ═══
  //   לא `.contains` שטוח — הרכבת-מנועי-מדף: נרמול-עברי (סופיות/ניקוד) + ניקוד רב-מילתי AND
  //   (כל מילה חייבת מונח-מתאים) + סינון-ציון-0 + מיון-יורד-לפי-רלוונטיות. השקעים מוזרקים (חוק-1).
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);            // שקע-norm
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];        // שקע-expand (זהות; אין טבלת-תעתיק)
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0; // שקע-score (זוג יחיד)
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty; // שקע-hasQuery
  static List<String> _termsOf(Map<String, dynamic> s) => ['${s['name']}', '${s['sku'] ?? ''}', '${s['cat'] ?? ''}'];
  static List<Map<String, dynamic>> searchItems(List<Map<String, dynamic>> items, String q) =>
      (smartFilter(q, items, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה (הכרעה 23-ג · תובנה·2) = FilterChipPill ⊕ finderMatches ═══
  //   לא פרדיקט-בוליאני-ידני — מנוע-סינון-רב-צירי (AND על נעילות); הצ׳יפ בוחר ציר-נעילה פעיל.
  static const Map<int, String> _axisOf = {1: 'below', 2: 'expiry', 3: 'out'};
  static String _axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) { // שקע-finderAxisValue
    final s = f as Map<String, dynamic>;
    if (axis == 'below') return belowMin(s) ? '1' : '0';
    if (axis == 'expiry') return expiring(s) ? '1' : '0';
    if (axis == 'out') return isOut(s) ? '1' : '0';
    return '';
  }
  static List<Map<String, dynamic>> filterItems(List<Map<String, dynamic>> items, int chip) {
    final locks = chip == 0 ? <dynamic, dynamic>{} : <dynamic, dynamic>{_axisOf[chip]!: '1'};
    return finderMatches({'families': items}, locks, _axisValue).cast<Map<String, dynamic>>();
  }

  // ═══ ייצוא (הכרעה 23-ג · תובנה) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ═══
  //   שורות = כותרת + תא-פר-שדה-אמת (מלאי-אפקטיבי). toCsv+csvEscape מהמדף (BOM + חסימת-הזרקה).
  static String statusText(Map<String, dynamic> s) =>
      isOut(s) ? 'אזל' : belowMin(s) ? 'מתחת-מינ׳' : sev(s) == 2 ? 'הזמן היום' : sev(s) == 1 ? 'הזמן בקרוב' : 'תקין';
  static const _csvHeader = ['מק״ט', 'שם', 'קטגוריה', 'יח׳', 'כמות', 'זמין', 'מינ׳', 'ערך', 'ספק', 'סטטוס'];
  static List<List<Object?>> _csvRows(List<Map<String, dynamic>> items) => [
        _csvHeader,
        for (final s in items)
          [s['sku'] ?? '', s['name'], s['cat'] ?? '', s['unit'] ?? '', curOf(s), available(s),
            minStock(s), curOf(s) * ((s['price'] as int?) ?? 0), s['supplier'] ?? '', statusText(s)],
      ];
  static String csvOf(List<Map<String, dynamic>> items) => toCsv(_csvRows(items), csvEscape) as String;
  static int get csvHeaderLen => _csvHeader.length;
  static bool exportOk(int role) => exportAllowed(false) && can(role, 'inv.export'); // שער-ייצוא ⊕ הרשאה

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 18 עמודות-המפרט כשקעי-דאטה ═══
  //   כמו metaFields (ספק/מחיר): נגזרת(get)=תמיד-מוצגת · שדה(key בלי get)=מוארת רק כשפריט נושא ערך,
  //   חסר ⇒ שקט. הוספת שדה לדאטה (barcode/warehouse/...) ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    {'key': 'sku', 'label': 'מק״ט'},
    {'label': 'שם', 'get': (Map<String, dynamic> s) => '${s['name']}'},
    {'key': 'type', 'label': 'סוג'},                 // מקום-שמור
    {'key': 'cat', 'label': 'קטגוריה'},
    {'key': 'warehouse', 'label': 'מחסן'},           // מקום-שמור
    {'key': 'location', 'label': 'מיקום'},           // מקום-שמור
    {'key': 'unit', 'label': 'יח׳'},
    {'label': 'כמות', 'get': (Map<String, dynamic> s) => '${curOf(s)}'},
    {'label': 'זמין', 'get': (Map<String, dynamic> s) => '${available(s)}'},
    {'key': 'reserved', 'label': 'שמור'},            // מקום-שמור
    {'key': 'reorderPoint', 'label': 'נק׳-הזמנה'},   // מקום-שמור
    {'label': 'מינ׳', 'get': (Map<String, dynamic> s) => '${minStock(s)}'},
    {'key': 'maxStock', 'label': 'מקס'},             // מקום-שמור
    {'label': 'עלות', 'get': (Map<String, dynamic> s) => '${s['price'] ?? '—'}'},
    {'key': 'avgCost', 'label': 'עלות-ממוצ׳'},       // מקום-שמור
    {'key': 'salePrice', 'label': 'מחיר-מכירה'},     // מקום-שמור
    {'label': 'ערך', 'get': (Map<String, dynamic> s) => shekel(curOf(s) * ((s['price'] as int?) ?? 0))},
    {'key': 'supplier', 'label': 'ספק'},
    {'key': 'barcode', 'label': 'ברקוד'},            // מקום-שמור
    {'key': '__status', 'label': 'סטטוס'},           // נגזרת-מצב (מטופלת ברנדר עם _statusLabel)
  ];
  // עמודה מוצגת: נגזרת(get)/סטטוס = תמיד; שדה = רק אם פריט כלשהו נושא ערך (המקום-השמור מואר)
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || c['key'] == '__status' ||
      rows.any((s) => s[c['key']] != null && '${s[c['key']]}'.trim().isNotEmpty);

  // ═══ הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction ═══
  //   3 זהויות-דמו מוזרקות (לא אטום!) + בורר-תפקיד מדגים את הגידור. הפעולות מגודרות פר-מפתח.
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👑 מנהל', 'email': 'mgr@school', 'config': {'adminEmails': ['mgr@school']}}, // admin ⇒ הכל
    {'label': '📦 מחסן', 'email': 'wh@school', 'config': {'features': {'inv.receive': true, 'inv.issue': true, 'inv.count': true}}}, // staff מוגבל
    {'label': '👁 צפייה', 'email': 'view@school', 'config': <String, dynamic>{}}, // staff ללא-הרשאות
  ];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['email'] as String, false, key, _isAdmin);
  }
  static String roleName(int role) =>
      roleOf((roleDefs[role]['config'] as Map).cast<String, dynamic>(), roleDefs[role]['email'] as String);

  // ═══ אוטומציות פרואקטיביות (הכרעה 23-ג · תובנה) = AlertBanner ⊕ expiringIntakes ⊕ warehouseValue ═══
  //   המערכת מתריעה לפני שדבר נשמט — פקיעה-קרובה + מלאי-מת (הון-כלוא). מנועי-מדף, אפס-זיוף.
  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  // פקיעה: expiringIntakes(מדף) על db-קליטות-פוקעות (itemId+expiry), חלון = shopExpiryWarnDays(מדף)
  static Map<String, dynamic> get _expiryDb => {
        'shopIntakes': [for (final s in items) if (s['expiry'] != null) {'itemId': s['name'], 'expiry': s['expiry']}],
        'shopItems': [for (final s in items) {'id': s['name'], 'name': s['name']}],
      };
  static List<Map<String, dynamic>> get expiringList =>
      expiringIntakes(_expiryDb, today, _iso, shopExpiryWarnDays);
  // מלאי-מת: איטי (rate<0.5) עם מלאי-רב (ימים-עד-ריקון > 45) = הון-כלוא זמן-רב (slow⊕daysLeft מורכבים)
  static bool dead(Map<String, dynamic> s) => slow(s) && daysLeft(s) > 45;
  static List<Map<String, dynamic>> get deadItems => items.where(dead).toList();
  static int get deadCapital =>
      warehouseValue([for (final s in deadItems) {'qty': curOf(s), 'cost': s['price'] ?? 0}]).toInt();

  // ═══ מחזור-חיים · מצב-מיוחד "פריט-לא-פעיל" (23-ב · דגל=עובדה) = StatusChip ⊕ SoftButton-toggle ═══
  //   הדגל active מוזרק בדאטה; toggle=state. פריט-לא-פעיל יוצא מהתצוגות-התפעוליות (טריאז'/KPI).
  static final Map<String, bool> _activeOverride = {};
  static bool activeOf(Map<String, dynamic> s) => _activeOverride[s['name']] ?? (s['active'] as bool? ?? true);
  static void toggleActive(Map<String, dynamic> s) {
    _activeOverride[s['name'] as String] = !activeOf(s);
    _ovCache = null;
  }
  static List<Map<String, dynamic>> get activeItems => items.where(activeOf).toList();
  static List<Map<String, dynamic>> get inactiveItems => items.where((s) => !activeOf(s)).toList();
}

// (פורמט-שקלים היה inline — הוחלף באטום-הלוגיקה `shekel` מ-dart-maor · §21 שכבת-הלוגיקה)

class _Inventory extends StatefulWidget {
  const _Inventory();
  @override
  State<_Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<_Inventory> {
  final Set<String> _ordered = {}; // זיכרון d2: פריטים שסומנו "הוזמן" (מצב=חיווט לגיטימי)
  final Map<String, int> _seg = {}; // מבט-נבחר פר-פריט (חיווט SegmentedSwitch→תצוגה)
  String _q = ''; // חיפוש-איתור (DsSearch→סינון)
  int _filter = 0; // 0=הכל · 1=מתחת-מינ׳ · 2=פקיעה · 3=אזלו (FilterChipPill→סינון-חריגה)
  int _mode = 0; // 0=🎯 חכם (טריאז') · 1=📋 טבלה (DsTable כל-העמודות) — SegmentedSwitch→תצוגה
  int _role = 0; // 0=מנהל · 1=מחסן · 2=צפייה (חוק-6 זהות-מוזרקת; בורר-תפקיד מדגים גידור-הרשאות)
  bool _loading = false; // מצב-מסך שמור: טעינה (רענון-דאטה אמיתי מדגים; חיבור-אסינק עתידי מאיר אותו)
  String? _error; // מצב-מסך שמור: שגיאה (מקום-שמור — מאיר כש-fetch נכשל; null בזרימה-התקינה)

  // צ׳יפ-סינון מבוקר: הזרקת-צבעים (חוק-6) + מיפוי selected/onTap ל-_filter
  Widget _fchip(int i, String label) => FilterChipPill(
        label: label, selected: _filter == i, onTap: () => setState(() => _filter = i),
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E),
        activeTextColor: const Color(0xFF0B0B15), inkColor: _ink,
        outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );

  @override
  Widget build(BuildContext context) {
    // דירוג לפי ימים-עד-ריקון עולה — הכי-קרוב-להיגמר ראשון
    final ranked = [..._InvData.activeItems]..sort((a, b) => _InvData.daysLeft(a).compareTo(_InvData.daysLeft(b)));
    // Dp3+Dp8+Dp11: קיבוץ-לפי-מצב ⇒ הדחוף בראש כקבוצה, המצב דומיננטי-במבט, היררכיה.
    //   דלי לפי מצב (הוזמן=−1) — שומר על סדר-הדירוג בתוך כל דלי.
    // קיבוץ לפי דחיפות-מאוחדת sev (short OR band) — האיחוד מניע את הטריאז', לא הקצב-בלבד.
    // KPI-8 (המפרט) על כל-המלאי — כולם מנועי-מדף/שדות-אמת (§20-ג · אפס StatBlock/math.sin):
    final all = _InvData.activeItems; // KPI תפעולי על פעילים בלבד (לא-פעילים בסקשן נפרד)
    final totalQty = grandTotal(all, (s) => _InvData.curOf(s)).toInt(); // Σ כמות (מלאי-אפקטיבי)
    final totalValue = warehouseValue([for (final s in all) {'qty': _InvData.curOf(s), 'cost': s['price'] ?? 0}]).toInt(); // Σ qty×cost
    final belowMinN = all.where(_InvData.belowMin).length;
    final outN = all.where(_InvData.isOut).length;
    final slowN = all.where(_InvData.slow).length;
    final expN = all.where(_InvData.expiring).length;
    final urgentAll = all.where((s) => !_ordered.contains(s['name']) && _InvData.sev(s) >= 1).length; // hero=המטרה
    // איתור⊕חריגה (הכרעה 23-ג): searchItems=DsSearch⊕smartFilter⊕smartScore⊕normSearch ·
    //   filterItems=finderMatches. הפייפליין רץ פעם-אחת ומזין גם טריאז' וגם טבלה (visible).
    final visible = _InvData.filterItems(_InvData.searchItems(ranked, _q), _filter);
    // טריאז' — פעולת-יסוד "הכרעה" מקבצת פר-מצב
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: [], -1: []};
    for (final s in visible) {
      buckets[_ordered.contains(s['name']) ? -1 : _InvData.sev(s)]!.add(s);
    }
    final shown = buckets.values.fold<int>(0, (n, b) => n + b.length);
    const secTitle = {2: '🔴 הזמן היום', 1: '🟠 הזמן בקרוב', 0: '🟢 מרווח בטוח', -1: '✅ הוזמן'};
    const secTone = {2: 2, 1: 3, 0: 1, -1: 1};
    return DsScaffold(
      title: 'מלאי', subtitle: '${all.length} פריטים · ${_InvData.consumers.length} מחלקות צורכות', icon: '📦',
      children: [
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות פר-תפקיד (roleOf⊕canGrantedAction)
        Align(
          alignment: Alignment.centerRight,
          child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final r in _InvData.roleDefs) r['label'] as String]) [s]], selected: {_role}, onSelect: (i) => setState(() => _role = i)),
        ),
        _gap(10),
        // פס-עליון: חיפוש-מבוקר (DsSearch) + יצירה + ייצוא — מגודרים פר-הרשאה (canGrantedAction)
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          // רענון — מדגים את מצב-הטעינה השמור (חיבור-אסינק אמיתי יאיר אותו זהה)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _refresh, child: ForgeSoftButton(fields: ['🔄']))),
          if (_InvData.can(_role, 'inv.add')) ...[
            const SizedBox(width: 8),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: ForgeSoftButton(fields: ['➕']))),
          ],
          if (_InvData.exportOk(_role)) ...[
            const SizedBox(width: 6),
            // ייצוא (23-ג): toCsv⊕csvEscape⊕exportAllowed — מייצא את הרשימה-הנראית (אחרי איתור+חריגה)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openExport(visible), child: ForgeSoftButton(fields: ['⬇ CSV']))),
          ],
        ]),
        // צ׳יפי-סינון-חריגה (FilterChipPill מבוקר) — פעולת-יסוד "זיהוי-חריגה"
        Wrap(spacing: 8, runSpacing: 6, children: [
          _fchip(0, 'הכל'),
          _fchip(1, '📉 מתחת-מינ׳ · $belowMinN'),
          _fchip(2, '⏳ פקיעה · $expN'),
          _fchip(3, '⛔ אזלו · $outN'),
        ]),
        const SizedBox(height: 12),
        // KPI-8: hero=דורשי-פעולה (המטרה) + 8 מדדי-מצב (BareStat, נושאי-ערך-אמת)
        ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatPlain(fields: ['פריטים דורשי-הזמנה', '$urgentAll'])),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['📦 פריטים', '${all.length}'])),
              Expanded(child: ForgeStatPlain(fields: ['🔢 כמות', '$totalQty'])),
              Expanded(child: ForgeStatPlain(fields: ['💰 ערך', shekel(totalValue)])),
              Expanded(child: ForgeStatPlain(fields: ['📉 מתחת-מינ׳', '$belowMinN'])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['⛔ אזלו', '$outN'])),
              Expanded(child: ForgeStatPlain(fields: ['🚚 בהזמנה', '${_ordered.length}'])),
              Expanded(child: ForgeStatPlain(fields: ['🐌 איטיים', '$slowN'])),
              Expanded(child: ForgeStatPlain(fields: ['⏳ פקיעה', '$expN'])),
            ]),
          ])),
        const SizedBox(height: 8),
        // מרכז-אוטומציות (23-ג · פרואקטיבי): המערכת מתריעה לפני שדבר נשמט — פקיעה + מלאי-מת
        if (_InvData.expiringList.isNotEmpty) ...[
          ForgeSectionPill(fields: ['${_InvData.expiringList.length} פוקעים תוך $shopExpiryWarnDays ימים: ${_InvData.expiringList.map((e) => e['itemName']).join(' · ')}', '']),
          _gap(8),
        ],
        if (_InvData.deadItems.isNotEmpty) ...[
          ForgeSectionPill(fields: ['${_InvData.deadItems.length} מלאי-מת (איטי + מלאי-רב) · ${shekel(_InvData.deadCapital)} הון-כלוא: ${_InvData.deadItems.map((s) => s['name']).join(' · ')}', '']),
          _gap(8),
        ],
        // בורר-מבט (SegmentedSwitch מבוקר): 🎯 חכם (טריאז'-החלטה) · 📋 טבלה (כל-העמודות)
        Align(
          alignment: Alignment.centerRight,
          child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['🎯 חכם', '📋 טבלה', '📜 תנועות']) [s]], selected: {_mode}, onSelect: (i) => setState(() => _mode = i)),
        ),
        const SizedBox(height: 10),
        // מצבי-מסך שמורים (מקום-שמור): טעינה + שגיאה מאירים במצב-אמת; אחרת התוכן הרגיל.
        if (_loading)
          _loadingView()
        else if (_error != null)
          ForgeSectionPill(fields: [_error!, ''])
        else if (_mode == 2)
          _movements() // אימות: יומן-תנועות (מנוע intakeLog + TimelineItem) — לא מסונן (ציר-אמת)
        else if (shown == 0)
          const Padding(padding: EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: ['אין פריטים תואמים לחיפוש/סינון', '']))
        else if (_mode == 1)
          _table(visible)
        else
          for (final st in const [2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              ForgeTitledSection(fields: ['${secTitle[st]} · ${buckets[st]!.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
                for (final s in buckets[st]!) _row(s),
              ]])),
        // מצב-מיוחד: פריטים לא-פעילים (StatusChip תג + ▶ הפעל מגודר-הרשאה) — מחוץ לתפעול
        if (_InvData.inactiveItems.isNotEmpty && _mode != 2) ...[
          _gap(10),
          ForgeTitledSection(fields: ['🚫 לא-פעילים · ${_InvData.inactiveItems.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
            for (final s in _InvData.inactiveItems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: ForgeContactTile(fields: ['${s['name']}', '${s['sku'] ?? ''} · הופסק'])),
                  const Flexible(child: ForgeIntelPill(fields: ['לא-פעיל'])),
                  if (_InvData.can(_role, 'inv.toggle')) ...[
                    const SizedBox(width: 8),
                    GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _InvData.toggleActive(s)), child: ForgeSoftButton(fields: ['▶ הפעל'])),
                  ],
                ]),
              ),
          ]])),
        ],
      ],
    );
  }

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה)
  void _refresh() {
    setState(() {
      _loading = true;
      _error = null;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  // מצב-טעינה שמור: מחוון + טקסט (אטום-מסגרת סטנדרטי; אפס ShimmerSkeleton מזייף).
  //   מרוכז דרך ה-Column עצמו (crossAxis.center) — לא Center (שדורש גובה-חסום ⇒ קורס ברשימה-נגללת).
  Widget _loadingView() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _acc),
            const SizedBox(height: 14),
            const Text('טוען מלאי…', style: TextStyle(color: _muted, fontSize: 14)),
          ],
        ),
      );

  // 📜 מבט-תנועות (פעולת-יסוד "אימות"): מנוע-האמת intakeLog מחזיר {rows חדש-ראשון, totalCost},
  //   כל שורה מגולמת ב-TimelineItem (title/time/body). אפס-timeline_flow (מזייף int events).
  Widget _movements() {
    final log = intakeLog(_InvData.movDb);
    final rows = log['rows'] as List;
    final totalCost = (log['totalCost'] as num).toInt();
    return ForgeTitledSection(fields: ['📜 יומן-תנועות · ${rows.length} · Σ ${shekel(totalCost)}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
      for (final r in rows)
        () {
          final intake = (r as Map)['intake'] as Map;
          final name = r['itemName'];
          final k = intake['kind'];
          final kind = k == 'donation' ? '🎁 תרומה-בעין' : k == 'issue' ? '📤 הוצאה' : k == 'count' ? '🔢 ספירה' : '🛒 קליטה';
          final cost = (intake['cost'] as num).toInt();
          return ForgeNotifRow(items: [['$kind · $name', '${intake['date']}']]);
        }(),
    ]]));
  }

  // 📋 מבט-טבלה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid (מזייף int rows).
  //   העמודות נגזרות מהחוזה: נגזרת=תמיד · שדה=מוארת-כשיש-נתון. שדה חדש בדאטה ⇒ עמודה חדשה, אפס-קוד.
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _InvData.columnDefs) if (_InvData.colShown(c, rows)) c];
    final labels = [for (final c in cols) c['label'] as String];
    final data = <List<String>>[
      for (final s in rows)
        [
          for (final c in cols)
            if (c['key'] == '__status')
              _statusLabel(s)
            else if (c['get'] != null)
              (c['get'] as String Function(Map<String, dynamic>))(s)
            else
              '${s[c['key']] ?? '—'}',
        ],
    ];
    return DsTable(labels: labels, rows: data);
  }

  // תווית-סטטוס פר-פריט (הכרעה מאוחדת sev + מתחת-מינ׳/אזל) — נגזרת, אחת-לטבלה-ולסטטוס-שורה
  String _statusLabel(Map<String, dynamic> s) => _ordered.contains(s['name'])
      ? '✅ הוזמן'
      : _InvData.isOut(s)
          ? '⛔ אזל'
          : _InvData.belowMin(s)
              ? '📉 מתחת-מינ׳'
              : _InvData.sev(s) == 2
                  ? '🔴 הזמן היום'
                  : _InvData.sev(s) == 1
                      ? '🟠 בקרוב'
                      : '🟢 תקין';

  // ═══ פאנל-פריט-נבחר (צד) · GlassCard(child) · פעולת-יסוד "ביצוע" — כל הפעולות על פריט-אחד ═══
  //   זהות + מצב-אמת + פעולות (SoftButton: קבלה/הוצאה/מלא-ליעד/הזמן) + תנועות-הפריט (intakeLog מסונן).
  //   הפעולות משנות את פנקס-ההתאמות (curOf) ורושמות תנועה — המסך והפאנל מתעדכנים יחד.
  void _openPanel(Map<String, dynamic> s) {
    final name = s['name'] as String;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void act(void Function() f) {
            f();
            setSheet(() {});
            setState(() {}); // רענון גם למסך שמאחור
          }
          final cur = _InvData.curOf(s), target = s['target'] as int;
          final ordered = _ordered.contains(name);
          final moves = (intakeLog(_InvData.movDb)['rows'] as List).where((r) => (r as Map)['itemName'] == name).toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.72, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  ForgeContactTile(fields: [name, '${s['sku'] ?? ''} · ${s['cat'] ?? ''} · ${s['unit'] ?? ''}']),
                  _gap(12),
                  ForgeLinearProgressStatus(fields: ['מלאי מול יעד', '$cur מתוך $target'], values: [target == 0 ? 0 : (cur / target).clamp(0.0, 1.0)]),
                  _gap(10),
                  Row(children: [
                    Expanded(child: ForgeStatPlain(fields: ['ביד', '$cur'])),
                    Expanded(child: ForgeStatPlain(fields: ['זמין', '${_InvData.available(s)}'])),
                    Expanded(child: ForgeStatPlain(fields: ['מינ׳', '${_InvData.minStock(s)}'])),
                    Expanded(child: ForgeStatPlain(fields: ['ערך', shekel(cur * ((s['price'] as int?) ?? 0))])),
                  ]),
                  _wrap(_facts(s)),
                  _gap(14),
                  const Text('פעולות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                  _gap(8),
                  // פעולות מגודרות פר-הרשאה (canGrantedAction); אין-הרשאה ⇒ מצב נעילת-הרשאות (AlertBanner)
                  Builder(builder: (_) {
                    final acts = <Widget>[
                      if (_InvData.can(_role, 'inv.receive')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _InvData.receive(s, 5)), child: ForgeSoftButton(fields: ['📥 קבלה +5'])),
                      if (_InvData.can(_role, 'inv.issue')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _InvData.issue(s, 5)), child: ForgeSoftButton(fields: ['📤 הוצאה −5'])),
                      if (_InvData.can(_role, 'inv.count')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _InvData.countTo(s, target)), child: ForgeSoftButton(fields: ['📦 מלא-ליעד'])),
                      if (_InvData.can(_role, 'inv.order')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => ordered ? _ordered.remove(name) : _ordered.add(name)), child: ForgeSoftButton(fields: [ordered ? '↩ בטל הזמנה' : '🛒 סמן הוזמן'])),
                      if (_InvData.can(_role, 'inv.toggle')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _InvData.toggleActive(s)), child: ForgeSoftButton(fields: ['⏸ השבת'])),
                    ];
                    return acts.isEmpty
                        ? const ForgeSectionPill(fields: ['צפייה-בלבד — אין הרשאת-פעולה', ''])
                        : Wrap(spacing: 8, runSpacing: 8, children: acts);
                  }),
                  _gap(16),
                  Text('תנועות הפריט · ${moves.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                  _gap(8),
                  if (moves.isEmpty)
                    const ForgeSearchEmptyState(fields: ['אין תנועות רשומות לפריט', ''])
                  else
                    for (final r in moves) _moveTile((r as Map)['intake'] as Map, s),
                ])),
            ),
          );
        },
      ),
    );
  }

  // ═══ ייצוא (23-ג · תובנה) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ GlassCard-preview ═══
  //   שער-הייצוא (exportAllowed) נבדק; בדפדפן-הסנדבוקס ההורדה חסומה ⇒ תצוגת-CSV לבדיקה+העתקה.
  void _openExport(List<Map<String, dynamic>> items) {
    final allowed = _InvData.exportOk(_role);
    final csv = allowed ? _InvData.csvOf(items) : '';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              ForgeContactTile(fields: ['ייצוא CSV', '${items.length} פריטים · ${_InvData.csvHeaderLen} עמודות']),
              _gap(10),
              if (!allowed)
                const ForgeSectionPill(fields: ['ייצוא חסום (שער-הרשאות)', ''])
              else ...[
                const Text('תצוגה מקדימה (BOM + חסימת-הזרקה):', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
                _gap(8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                  child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
                ),
              ],
            ])),
        ),
      ),
    );
  }

  // שורת-תנועה יחידה (TimelineItem) — משותפת לפאנל וליומן; kind→תווית
  Widget _moveTile(Map intake, Map<String, dynamic> s) {
    final k = intake['kind'];
    final kind = k == 'donation' ? '🎁 תרומה-בעין' : k == 'issue' ? '📤 הוצאה' : k == 'count' ? '🔢 ספירה' : '🛒 קליטה';
    final cost = (intake['cost'] as num).toInt();
    return ForgeNotifRow(items: [[kind, '${intake['date']}']]);
  }

  // המקום-השמור (חוק-7): לולאה גנרית מעל חוזה-התצוגה (_InvData.metaFields) — לא קוד-פר-שדה.
  // כל שדה-מטא שהרשומה נושאת ⇒ שבב; חסר ⇒ שקט. שדה חדש בחוזה מופיע כאן לבד (אפס-רישום-ביד).
  List<Widget> _facts(Map<String, dynamic> s) => [
        for (final f in _InvData.metaFields)
          if (s[f['key']] != null) ForgeIntelPill(fields: ['${f['prefix']}${s[f['key']]}${f['suffix']}']),
      ];

  Widget _wrap(List<Widget> kids, {double top = 6}) => Padding(
        padding: EdgeInsets.only(top: top, right: 4),
        child: Wrap(spacing: 8, runSpacing: 6, children: kids),
      );

  Widget _card(Widget inner) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ForgeStripPanelFrame(fields: ['', ''], child: inner),
      );

  Widget _gap([double h = 10]) => SizedBox(height: h);

  // הצגה מקסימלית **מאורגנת**: כל אטומי-החלקיקים קיימים, אך אטום-הארגון SegmentedSwitch (הכרעה 23-ג —
  // ארגון הוא פעולת-יסוד עם אטום משלה) מחלק אותם ל-3 מבטים ⇒ המבט-הראשון נקי, העומק בהישג-טאפ.
  //  · הוזמן  → כותרת + בטל (לולאה סגורה)
  //  · בטוח   → כותרת + מלאי + facts (אין החלטה ⇒ אין מבטים)
  //  · פעיל   → כותרת + SegmentedSwitch[🎯 החלטה · 📊 ניתוח · 📦 מלאי] + המבט-הנבחר
  Widget _row(Map<String, dynamic> s) {
    final name = s['name'] as String;
    final left = _InvData.daysLeft(s);
    final lead = s['lead'] as int;
    final band = _InvData.band(s);
    // MediaRow בולע את הקליק (InkWell פנימי no-op) ⇒ כפתור-שברון נפרד כשקע-הפתיחה (מחוץ ל-ink שלו).
    final header = Row(children: [
      Expanded(child: ForgeContactTile(fields: [name, '${left.round()} ימים ריצה · אספקה $lead י׳'])),
      IconButton(
        onPressed: () => _openPanel(s),
        icon: const Icon(Icons.chevron_left, color: _acc, size: 26),
        tooltip: 'פרטים ופעולות',
      ),
    ]);

    if (_ordered.contains(name)) {
      return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        header,
        _wrap([GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _ordered.remove(name)), child: ForgeSoftButton(fields: ['בטל']))], top: 8),
      ]));
    }
    if (band == 0) {
      return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        header, _gap(8), _viewStock(s), _wrap(_facts(s)),
      ]));
    }
    final sel = _seg[name] ?? 0;
    final view = sel == 1 ? _viewAnalysis(s) : sel == 2 ? _viewStockTab(s) : _viewDecision(s);
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      header,
      _gap(10),
      Align(
        alignment: Alignment.centerRight,
        child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['🎯 החלטה', '📊 ניתוח', '📦 מלאי']) [s]], selected: {sel}, onSelect: (i) => setState(() => _seg[name] = i)),
      ),
      _gap(12),
      view,
    ]));
  }

  // 🎯 מבט-החלטה: מועד(AlertBanner 2-ערוצים) · כמות(BareStat×3 הפרש) · עלות(BareStat×3 מכפלה) · פעולה
  Widget _viewDecision(Map<String, dynamic> s) {
    final cur = _InvData.curOf(s), sev = _InvData.sev(s);
    final qty = _InvData.orderQty(s); // כמות מאוחדת (יעד+הקצאה)
    final mustIn = _InvData.mustOrderIn(s).ceil();
    final price = s['price'] as int?;
    final why = _InvData.isShort(s) ? 'גירעון-הקצאה + ' : ''; // סיבת-הדחיפות המאוחדת
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeSectionPill(fields: [sev == 2 ? '$whyחייבים להזמין היום' : 'הזמן תוך $mustIn ימים', '']),
      _gap(),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['במלאי', '$cur'])),
        Expanded(child: ForgeStatPlain(fields: ['נדרש', '${_InvData.allocated(s)}'])),
        Expanded(child: ForgeStatPlain(fields: ['= להזמנה', '$qty'])),
      ]),
      if (price != null) ...[
        _gap(),
        Row(children: [
          Expanded(child: ForgeStatPlain(fields: ['כמות', '$qty'])),
          Expanded(child: ForgeStatPlain(fields: ['מחיר ליח׳', shekel(price)])),
          Expanded(child: ForgeStatPlain(fields: ['= עלות', shekel(qty * price)])),
        ]),
      ],
      _wrap([GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _ordered.add(s['name'] as String)), child: ForgeSoftButton(fields: ['סמן: הוזמן']))], top: 10),
    ]);
  }

  // 📊 מבט-ניתוח: השוואה(NeonBars+מרווח+כיסוי-StatRow) · מד-דחיפות(GaugeMeter) · ריצה(BareStat×3 חילוק)
  Widget _viewAnalysis(Map<String, dynamic> s) {
    final left = _InvData.daysLeft(s), lead = s['lead'] as int, cur = _InvData.curOf(s);
    final rate = s['rate'] as double;
    final margin = _InvData.mustOrderIn(s);
    final band = _InvData.band(s);
    final tone = band == 2 ? 2 : band == 1 ? 3 : 1; // הקווים והמד נצבעים לפי-המצב (שקע tone החדש)
    // נרמול מחווט מאטום-הלוגיקה clampScale (במקום .clamp inline)
    final suff = clampScale(left / lead, 0.0, 1.0).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      NeonBars(labels: const ['ימים-עד-ריקון', 'זמן-אספקה'], values: [left, lead.toDouble()], tone: tone),
      _gap(),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['מרווח מול הקו', '${margin.round()} י׳'])),
      ]),
      _gap(8),
      ForgeLinearProgressStatus(fields: ['כיסוי זמן-האספקה', '${(suff * 100).round()}%'], values: [suff]),
      _gap(10),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['קצב צריכה', '${rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(1)}/יום'])),
        Expanded(child: ForgeStatPlain(fields: ['= ריצה עד ריקון', '${left.round()} י׳'])),
      ]),
      // ─── אות-מחסור שני (מפורק · warehouseOverview): מלאי מול צריכה-מוקצית-לכיתות → גירעון/עודף ───
      // "מקסום-מטרה" = שני האותות יחד (קצב-זמן + הקצאה-לצרכנים), לא בחירה באחד.
      ...(() {
        final ov = _InvData.overview()[s['name'] as String];
        if (ov == null) return <Widget>[];
        final allocated = (ov['allocated'] as num).toInt();
        final remaining = (ov['remaining'] as num).toInt();
        final short = ov['short'] == true;
        final byP = ov['byProject'] as List;
        return <Widget>[
          _gap(14),
          Row(children: [
            Expanded(child: ForgeStatPlain(fields: ['ביד', '$cur'])),
            Expanded(child: ForgeStatPlain(fields: ['מוקצה לכיתות', '$allocated'])),
            Expanded(child: ForgeStatPlain(fields: [short ? '= גירעון' : '= עודף', '$remaining'])),
          ]),
          _wrap([for (final p in byP) ForgeIntelPill(fields: ['${(p as Map)['name']}: ${p['qty']}'])]),
        ];
      })(),
    ]);
  }

  // 📦 מבט-מלאי בטאב-הפעיל: מלאי מול יעד + חוסר + facts
  Widget _viewStockTab(Map<String, dynamic> s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _viewStock(s), _wrap(_facts(s)),
      ]);

  // מלאי מול יעד (StatRow יחס) + חוסר-עד-היעד (BareStat) — סוכן-A: יחס+חוסר, לא StatRow-יחיד.
  Widget _viewStock(Map<String, dynamic> s) {
    final cur = _InvData.curOf(s), target = s['target'] as int;
    final deficit = (target - cur).clamp(0, target);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeLinearProgressStatus(fields: ['מלאי מול יעד בריא', '$cur מתוך $target'], values: [target == 0 ? 0 : cur / target]),
      _gap(8),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['חסר עד היעד', '$deficit'])),
      ]),
    ]);
  }
}
