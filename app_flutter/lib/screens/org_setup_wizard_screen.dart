// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT-SYSTEM V5 — 🔌 אשף הקמת חברה (מסך-ההרכבה של התוכנית).
//
// המנהל מרכיב כאן OrgConfig שלם על **טיוטה מקומית**: שם-חברה · חבילת-ורטיקל
// (V4 — נקודת-פתיחה, החלפה-מלאה של terms+modules) · 13 מודולי-גל-1
// (absent=on; 'manager' נעול — נעילה-עצמית אסורה מה-UI) · 6 מונחי רישום-V3.
// "שמור והפעל" = קודם ה-provider (חי בכל האפליקציה, אפס-ריסטארט) ורק אז
// persist — כישלון-אחסון מדווח ביושר ("פעיל עכשיו — אך לא ישרוד ריסטארט").
// ייצוא/ייבוא JSON רוכבים על seam ה-file-transfer (web-first; IO מדווח
// ביושר), והייבוא **אטומי**: קובץ פסול לא נוגע בטיוטה כלל.
//
// הטיוטה היא המלך: המסך קורא את orgConfigProvider **פעם-אחת** ב-initState ולא
// watch — האשף הוא ה-WRITER של ה-provider, ו-watch היה נלחם בטיוטה (כל שמירה
// דורסת עריכה-בעיצומה). שורת-הסטטוס (_note) היא Text-inline בכוונה — לא
// toast: נבדקת-בטסט ונשארת על המסך.
//
// חוקי-בית: Text רגיל בלבד (לא CfgText — האשף עורך את מילון-המונחים עצמו,
// וסריקת gate-118 נשארת נקייה) · מפות קנוניות-מינימליות (מודול-דלוק לא נשמר
// כ-true, מונח-ריק לא נשמר כלל) · אפס-חבילות-חדשות. ויזואלית: ה-idiom הבהיר
// של בונה-הענפים (bgLight · cardLight · RTL מפורש · clamp-טקסט 1.35×).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/config/org_config.dart'
    show
        OrgConfig,
        decodeOrgConfig,
        elementShown,
        encodeOrgConfig,
        kDefaultOrgConfig,
        kOrgConfigFlag,
        moduleOn,
        termOf;
import 'package:buildsmart/config/org_modules.dart'
    show
        OrgModuleInfo,
        kOrgModules,
        kWizardLockedModules,
        kWizardModules,
        moduleForScreen;
import 'package:buildsmart/config/screen_labels_he.dart'
    show normalizeScreen, screenLabelHe;
import 'package:buildsmart/config/screen_registry.dart'
    show ManagedScreen, kManagedScreens, kScreensRootKey, keyboardLayoutKey;
import 'package:buildsmart/config/vertical_packs.dart'
    show applyVerticalPack, kVerticalPacks;
import 'package:buildsmart/screens/studio/panes/find_replace_pane.dart'
    show FindReplacePane;
import 'package:buildsmart/screens/studio/panes/history_pane.dart'
    show HistoryPane;
import 'package:buildsmart/services/file_transfer.dart'
    show downloadTextFileProvider, pickTextFileProvider;
import 'package:buildsmart/state/org_config_store.dart'
    show orgConfigProvider, persistOrgConfig;
import 'package:buildsmart/state/screen_sections.dart'
    show ScreenSectionsNotifier, screenSectionsProvider;
import 'package:buildsmart/state/studio/config_node.dart' show CfgStyle;
import 'package:buildsmart/state/studio/config_store.dart'
    show
        ConfigOp,
        SetEmoji,
        SetStyle,
        SetText,
        configStoreProvider,
        resolvedNodeProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show studioOwnerEmailProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show EditAxis, ElementDescriptor, criticalIdsProvider, kElementRegistry;
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart'
    show applyCfgTextStyle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 6 שדות-המונחים שהאשף עורך — מפתחות רישום-V3 (org_config.dart) + התווית
/// העברית של כל שדה. ריק = אוצר-המילים המקומפל (המפתח מוסר מהמפה).
const List<({String key, String label})> _kTermFields = [
  (key: 'brand.name', label: 'שם האפליקציה'),
  (key: 'brand.club', label: 'שם המועדון'),
  (key: 'nav.home', label: 'טאב ראשון (בית)'),
  (key: 'nav.catalog', label: 'טאב שני (מחלקות)'),
  (key: 'nav.updates', label: 'טאב שלישי (עדכונים)'),
  (key: 'nav.store', label: 'טאב רביעי (חנות)'),
];

/// כל אלמנטי-הרג׳יסטרי מקובצים `module→normScreen→elements`, מחושב **פעם-אחת**
/// (הרג׳יסטרי const). זה הבסיס לאקורדיון-Maor: כל מודול = סקציה, בתוכה קבוצות-מסך.
final Map<String, Map<String, List<ElementDescriptor>>> _kElementsByModule = () {
  final m = <String, Map<String, List<ElementDescriptor>>>{};
  for (final d in kElementRegistry) {
    (m[moduleForScreen(d.screen)] ??= <String, List<ElementDescriptor>>{})
        .putIfAbsent(normalizeScreen(d.screen), () => <ElementDescriptor>[])
        .add(d);
  }
  return m;
}();

/// מפתחות-המודולים עם שער-פרסונה (13 — kOrgModules). 'contractor' איננו כאן
/// (ה-app-הבסיסי, בלי שער) ⇒ סקציית-תצוגה בלבד.
final Set<String> _kGatedKeys = kOrgModules.map((m) => m.key).toSet();

/// מונחים-שזורים פר-מודול (slice-3): מפתח-מודול → [(מפתח-מונח · תווית · ברירת-מחדל)].
/// רק מונחי-רישום-V3 המחווטים בפועל (`termOf`) — הצגה-חיה "→ תצוגה" בכל סקציה.
/// עריכה נשארת במקטע "מיתוג ומונחים" (מקור-אמת אחד ל-OrgConfig.terms).
const Map<String, List<(String, String, String)>> _kModuleTerms = {
  'contractor': [('nav.home', 'שם המסך', 'בית')],
  'dive': [('nav.catalog', 'שם המסך', 'מחלקות')],
  'chat': [('nav.updates', 'שם המסך', 'עדכונים')],
  'supplier': [('nav.store', 'שם המסך', 'חנות')],
  'manager': [
    ('nav.customers', 'לקוחות', 'לקוחות'),
    ('entity.customer', 'לקוח (יחיד)', 'לקוח'),
  ],
  'rewards': [('brand.club', 'שם המועדון', 'מועדון')],
};

/// 🔌 אשף הקמת חברה — giant-system V5. נקודת-הכניסה: מקטע-הניהול בלוח-המנהל,
/// מאחורי [kOrgConfigFlag].
class OrgSetupWizardScreen extends ConsumerStatefulWidget {
  const OrgSetupWizardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const OrgSetupWizardScreen());

  @override
  ConsumerState<OrgSetupWizardScreen> createState() => _OrgSetupWizardState();
}

class _OrgSetupWizardState extends ConsumerState<OrgSetupWizardScreen> {
  /// הטיוטה — עותק-עבודה מקומי; "שמור והפעל" מזרים אותה ל-provider + persist.
  late OrgConfig _draft;

  /// החבילה האחרונה שהוחלה (הדגשת-chip בלבד — לא נשמרת בקונפיג).
  String? _selectedPackId;

  /// שורת-הסטטוס האינליינית (בכוונה לא toast — נבדקת-בטסט ונשארת על המסך).
  String? _note;

  /// שומר-כפילות ל"שמור והפעל" (ה-persist הוא async).
  bool _saving = false;

  /// אקורדיון-הרכיבים (סגנון-Maor): שאילתת-החיפוש החיה — **מסנן**, לא תנאי-הצגה.
  /// ריק ⇒ כל 14 המודולים נגללים כסקציות (מונה לכל אחת); הקלדה מסננת אלמנטים
  /// ופותחת-אוטומטית מודולים תואמים. (תיקון באג "התיבה הריקה".)
  String _elemQuery = '';

  /// מסנן-צ׳יפ פעיל (מפתח-מודול) — null = הכל. **מסנן**, לא תנאי-הצגה.
  String? _filterModule;

  /// מפתחות-המודולים שהמשתמש פתח ידנית (אקורדיון עצל — גוף נבנה רק כשפתוח).
  /// חיפוש פותח-אוטומטית מודולים תואמים בלי לגעת בסט הזה.
  final Set<String> _openModules = <String>{};

  late final TextEditingController _orgName;
  late final Map<String, TextEditingController> _termCtrls;

  @override
  void initState() {
    super.initState();
    // קריאה חד-פעמית בכוונה (לא watch): האשף הוא ה-WRITER של ה-provider —
    // watch היה נלחם בטיוטה ודורס עריכה-בעיצומה אחרי כל שמירה.
    _draft = ref.read(orgConfigProvider);
    _orgName = TextEditingController(text: _draft.orgName);
    _termCtrls = {
      for (final f in _kTermFields)
        f.key: TextEditingController(text: _draft.terms[f.key] ?? ''),
    };
  }

  @override
  void dispose() {
    _orgName.dispose();
    for (final c in _termCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// ל-OrgConfig אין copyWith (API-V1 חתום — לא נוגעים בו); הבנייה-מחדש
  /// המקומית שומרת slug/theme כפי-שהם ומחליפה רק מה שהאשף עורך — שם, מודולים,
  /// מונחים ומפת-features (ציר הצג/הסתר הרכיבים; ברירת-מחדל = carry-through).
  OrgConfig _rebuild({
    String? orgName,
    Map<String, bool>? modules,
    Map<String, bool>? features,
    Map<String, String>? terms,
  }) =>
      OrgConfig(
        slug: _draft.slug,
        orgName: orgName ?? _draft.orgName,
        theme: _draft.theme,
        features: features ?? _draft.features,
        modules: modules ?? _draft.modules,
        terms: terms ?? _draft.terms,
      );

  /// כתיבת ה-.text של בקרי-המונחים מהטיוטה — אחרי החלת-חבילה (שמוחקת מונחים),
  /// ייבוא ואיפוס. עדכון-controller אינו יורה onChanged, אז אין לולאה.
  void _syncTermControllers() {
    for (final f in _kTermFields) {
      _termCtrls[f.key]!.text = _draft.terms[f.key] ?? '';
    }
  }

  /// סנכרון-מלא (שם + מונחים) — לייבוא/איפוס, שמחליפים את הטיוטה כולה.
  void _syncAllControllers() {
    _orgName.text = _draft.orgName;
    _syncTermControllers();
  }

  /// מפת-מודולים קנונית-מינימלית: דלוק = המפתח **מוסר** (absent=on — לעולם
  /// לא שומרים true), כבוי = false מפורש.
  void _setModule(String key, {required bool on}) {
    final next = <String, bool>{..._draft.modules};
    if (on) {
      next.remove(key);
    } else {
      next[key] = false;
    }
    setState(() => _draft = _rebuild(modules: next));
  }

  /// מפת-מונחים קנונית: ריק (אחרי trim) = המפתח מוסר — אין מונחי-מחרוזת-ריקה.
  void _setTerm(String key, String raw) {
    final v = raw.trim();
    final next = <String, String>{..._draft.terms};
    if (v.isEmpty) {
      next.remove(key);
    } else {
      next[key] = v;
    }
    setState(() => _draft = _rebuild(terms: next));
  }

  /// ציר הצג/הסתר הרכיבים — קנוני-מינימלי כמו [_setModule]: הסתרה = המפתח
  /// 'element.<id>' → false, הצגה = **הסרת** המפתח (absent=on ⇒ קונפיג
  /// כולו-מוצג נשאר ריק, byte-identical). ליבה (kImmutable) לעולם לא מגיעה
  /// לכאן — ה-UI מרנדר אותה נעולה (onChanged null).
  void _setElementHidden(String id, {required bool hidden}) {
    final next = <String, bool>{..._draft.features};
    if (hidden) {
      next['element.$id'] = false;
    } else {
      next.remove('element.$id');
    }
    setState(() => _draft = _rebuild(features: next));
  }

  /// שמור והפעל — LIVE קודם (ה-provider), persist אחר-כך; כישלון-אחסון מדווח
  /// ביושר. persistOrgConfig בכוונה לא נוגע ב-provider — ההרכבה כולה כאן.
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    ref.read(orgConfigProvider.notifier).state = _draft;
    final ok = await persistOrgConfig(_draft);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _note = ok
          ? '✅ נשמר ופעיל בכל האפליקציה'
          : '⚠️ פעיל עכשיו — אך השמירה נכשלה ולא תשרוד ריסטארט';
    });
  }

  /// ייצוא הטיוטה כ-JSON דרך ה-seam — ב-IO (אין ירידת-קבצים) מדווח ביושר.
  Future<void> _export() async {
    final ok = await ref.read(downloadTextFileProvider)(
      'org-config.json',
      encodeOrgConfig(_draft),
      'application/json;charset=utf-8',
    );
    if (!mounted) return;
    setState(() {
      _note = ok ? '✅ יוצא org-config.json' : 'ייצוא זמין ב-web בלבד';
    });
  }

  /// ייבוא **אטומי**: קובץ פסול (decodeOrgConfig ⇒ null) לא נוגע בטיוטה כלל.
  /// web: סגירת בוחר-הקבצים לא מרימה אירוע — ה-Future פשוט לא נפתר; המסך
  /// נשאר שמיש לגמרי בזמן ההמתנה (אין spinner חוסם שתלוי בפתרון).
  Future<void> _import() async {
    final picked = await ref.read(pickTextFileProvider)('.json');
    if (!mounted) return;
    if (picked == null) {
      setState(() => _note = 'לא נבחר קובץ');
      return;
    }
    final cfg = decodeOrgConfig(picked.content);
    if (cfg == null) {
      setState(() => _note = '⚠️ קובץ לא-תקין — שום דבר לא יובא');
      return;
    }
    setState(() {
      _draft = cfg;
      _selectedPackId = null;
      _syncAllControllers();
      _note = '✅ יובא לטיוטה — לחץ שמור להפעלה';
    });
  }

  /// איפוס הטיוטה לברירת-המחדל הלא-ממותגת — ה-live לא נגוע עד "שמור והפעל".
  void _resetDraft() {
    setState(() {
      _draft = kDefaultOrgConfig;
      _selectedPackId = null;
      _syncAllControllers();
      _note = 'הטיוטה אופסה — לחץ שמור להפעלה';
    });
  }

  /// ה-InputDecoration של טופסי-המנהל — ה-idiom של trade_define_step
  /// (LIGHT-safe: מילוי cardLight וגבול #EDEDED גם תחת theme כהה).
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: BsTokens.cardLight,
        labelStyle:
            const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BsTokens.brand, width: 1.4),
        ),
      );

  /// כותרת-מקטע — סגנון כותרות _ManageSection בלוח-המנהל.
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: Text(
          text,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      );

  /// שורת-מודול אחת (טוגל-אב "פעיל" — שער-הפרסונה): מתג עם אימוג׳י · שם · תיאור ·
  /// מונה-רכיבים; 'manager' נעול (onChanged null — הקונפיג עצמו עדיין יודע false
  /// מייבוא-JSON חיצוני, ה-UI רק מגן). [countSuffix] = "N/M פעילים".
  Widget _moduleTile(OrgModuleInfo m, String countSuffix) {
    final locked = kWizardLockedModules.contains(m.key);
    final sub = [
      m.descHe,
      if (locked) 'מוגן נעילה-עצמית',
      countSuffix,
    ].join(' · ');
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: BsTokens.brand,
      secondary: Text(m.emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        m.label,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
      ),
      value: moduleOn(_draft, m.key),
      onChanged: locked ? null : (v) => _setModule(m.key, on: v),
    );
  }

  /// (מוצגים, סה״כ) של אלמנטי-מודול לפי הטיוטה — למונה-הסקציה.
  (int, int) _moduleCounts(String key) {
    var total = 0;
    var shown = 0;
    for (final list in (_kElementsByModule[key] ?? const {}).values) {
      for (final d in list) {
        total++;
        if (elementShown(_draft, d.id)) shown++;
      }
    }
    return (shown, total);
  }

  /// (מוצגים, סה״כ) על כל הרג׳יסטרי — למונה הגלובלי "X מתוך Y פעילים".
  (int, int) _globalCounts() {
    var total = 0;
    var shown = 0;
    for (final d in kElementRegistry) {
      total++;
      if (elementShown(_draft, d.id)) shown++;
    }
    return (shown, total);
  }

  /// "סמן הכל / נקה הכל" לאלמנטי-מודול — bulk הצג/הסתר. **מדלג על ליבה נעולה**
  /// (kImmutable) — לעולם לא מסתירים ניווט/כניסה, גם לא ב-bulk.
  void _setModuleElementsHidden(String key, {required bool hidden}) {
    final next = <String, bool>{..._draft.features};
    for (final list in (_kElementsByModule[key] ?? const {}).values) {
      for (final d in list) {
        if (d.kImmutable) continue;
        if (hidden) {
          next['element.${d.id}'] = false;
        } else {
          next.remove('element.${d.id}');
        }
      }
    }
    setState(() => _draft = _rebuild(features: next));
  }

  /// שורת-רכיב אחת: מתג הצג/הסתר + ✎ מפקח (כשיש ציר-תוכן/עיצוב לערוך — "לא רק
  /// הצג/הסתר"). ליבה (kImmutable) — המתג נעול (onChanged null, value=מוצג-תמיד)
  /// עם 🔒; ה-✎ עדיין פתוח (טקסט/צבע/גודל — הליבה נעולה רק להסתרה, לא לעריכה).
  Widget _elementTile(ElementDescriptor d) {
    final locked = d.kImmutable;
    final tile = SwitchListTile(
      key: Key('elem-toggle-${d.id}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: BsTokens.brand,
      title: Text(
        d.labelHe,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: locked
          ? const Text(
              '🔒 ליבה — נעול',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
            )
          : null,
      // ליבה מוצגת-תמיד (הגנת-ההצגה נאכפת גם ב-elementVisible); השאר מהטיוטה.
      value: locked ? true : elementShown(_draft, d.id),
      onChanged: locked ? null : (v) => _setElementHidden(d.id, hidden: !v),
    );
    // ✎ מפקח פר-רכיב — רק כשיש ציר-תוכן/עיצוב (text/emoji/style), לא הסתרה-בלבד.
    final canInspect = d.editableProps.contains(EditAxis.text) ||
        d.editableProps.contains(EditAxis.emoji) ||
        d.editableProps.contains(EditAxis.style);
    if (!canInspect) return tile;
    return Row(
      children: [
        Expanded(child: tile),
        IconButton(
          key: Key('elem-edit-${d.id}'),
          visualDensity: VisualDensity.compact,
          tooltip: 'ערוך רכיב (טקסט · צבע · גודל · משקל)',
          icon: const Text('✎', style: TextStyle(fontSize: 16)),
          onPressed: () => _openElementInspector(d),
        ),
      ],
    );
  }

  /// פותח את מפקח-הרכיב (bottom-sheet) — עורך text/emoji/style חי דרך ה-Studio
  /// config-store (applyOps→publish), contextual לפי editableProps של הרכיב.
  void _openElementInspector(ElementDescriptor d) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BsTokens.cardLight,
      builder: (_) => _ElementInspectorSheet(descriptor: d),
    );
  }

  /// slice-4 — משגר את מסך מצא-והחלף (מיחזור `FindReplacePane` verbatim).
  void _openFindReplace() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _WizardFindReplaceScreen()),
    );
  }

  /// slice-5 — משגר את מסך גרסאות-והיסטוריה (מיחזור `HistoryPane` verbatim).
  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _WizardHistoryScreen()),
    );
  }

  /// screen-mgmt slice-2 — משגר את "ניהול מסכים" (רמה-1 רשימת-מסכים).
  void _openScreenManager() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _ScreenManagerScreen()),
    );
  }

  /// גוף-מודול: קבוצות-מסך (screenLabelHe) + מתגי-הרכיבים. נבנה **רק כשהמודול
  /// פתוח** (lazy — ~896 מתגים לא נבנים בסקציות סגורות). ממויין לפי נפח.
  Widget _moduleBody(Map<String, List<ElementDescriptor>> byScreen) {
    final screens = byScreen.keys.toList()
      ..sort((a, b) {
        final d = byScreen[b]!.length.compareTo(byScreen[a]!.length);
        return d != 0 ? d : a.compareTo(b);
      });
    // Transparent Material ancestor so the SwitchListTiles have a Material to
    // paint ink/background on — the card is a colored Container, and a ListTile
    // directly under it trips a framework assertion. Transparent ⇒ card shows.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final sk in screens) ...[
            Padding(
              padding: const EdgeInsets.only(top: BsTokens.space2, bottom: 2),
              child: Text(
                screenLabelHe(sk),
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final d in byScreen[sk]!) _elementTile(d),
          ],
        ],
      ),
    );
  }

  /// אלמנטי-מודול מסוננים לפי שאילתת-החיפוש [q] (ריק ⇒ הכל). מפתח=normScreen.
  Map<String, List<ElementDescriptor>> _matchingElements(String key, String q) {
    final byScreen = _kElementsByModule[key] ?? const {};
    if (q.isEmpty) return byScreen;
    final out = <String, List<ElementDescriptor>>{};
    byScreen.forEach((screen, list) {
      final f = [
        for (final d in list)
          if (d.labelHe.toLowerCase().contains(q) ||
              d.id.toLowerCase().contains(q))
            d,
      ];
      if (f.isNotEmpty) out[screen] = f;
    });
    return out;
  }

  /// כותרת מודול-תצוגה ללא שער (קבלן — ה-app-הבסיסי): אימוג׳י · שם · תיאור · מונה.
  Widget _contractorHeader(OrgModuleInfo m, String countSuffix) => Padding(
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
        child: Row(
          children: [
            Text(m.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: BsTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.label,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${m.descHe} · $countSuffix',
                    style: const TextStyle(
                        color: BsTokens.mutedLight, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// מונחים-שזורים (slice-3): הצגה-חיה "תווית → תצוגה" של מונחי-המודול (termOf).
  /// ריק ⇒ SizedBox. העריכה עצמה במקטע "מיתוג ומונחים" (מקור-אמת אחד).
  Widget _wovenTerms(String moduleKey) {
    final terms = _kModuleTerms[moduleKey];
    if (terms == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          start: BsTokens.space3, end: BsTokens.space3, bottom: BsTokens.space2),
      child: Wrap(
        spacing: BsTokens.space2,
        runSpacing: 4,
        children: [
          for (final (key, label, def) in terms)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: BsTokens.bgLight,
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                border: Border.all(color: const Color(0xFFEDEDED)),
              ),
              child: Text(
                '🏷️ $label → ${termOf(_draft, key, def)}',
                style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// כפתור-bulk קטן (סמן/נקה-הכל).
  Widget _bulkBtn(String label, VoidCallback onTap) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: BsTokens.brand,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      );

  /// סקציית-מודול אחת באקורדיון-Maor: כותרת (שער-פרסונה למודול-שער · כותרת-בלבד
  /// לקבלן) + מונה + רצועת-פתיחה-עצלה + סמן/נקה-הכל + מתגי-רכיבים מקובצי-מסך.
  Widget _moduleSection(
    OrgModuleInfo m,
    Map<String, List<ElementDescriptor>> matched, {
    required bool open,
  }) {
    final (shown, total) = _moduleCounts(m.key);
    final gated = _kGatedKeys.contains(m.key);
    final counter = '$shown/$total פעילים';
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Transparent Material so the header SwitchListTile paints ink over
          // the colored card (a ListTile directly under a colored DecoratedBox
          // trips a framework assertion) — same guard as _moduleBody.
          Material(
            type: MaterialType.transparency,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: BsTokens.space3),
              child: gated
                  ? _moduleTile(m, counter)
                  : _contractorHeader(m, counter),
            ),
          ),
          // מונחים-שזורים (slice-3) — "תווית → תצוגה" חיה של מונחי-המודול.
          _wovenTerms(m.key),
          // רצועת-פתיחה (עצלה) — משטח-הקשה נפרד מכפתורי ה-bulk.
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() {
                      if (!_openModules.remove(m.key)) _openModules.add(m.key);
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: BsTokens.space3,
                          vertical: BsTokens.space2),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              open ? '▾ רכיבים' : '‹ רכיבים',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BsTokens.brandDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: BsTokens.space2),
                          Flexible(
                            child: Text(
                              '$shown/$total',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: BsTokens.mutedLight, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (open) ...[
                _bulkBtn('סמן הכל',
                    () => _setModuleElementsHidden(m.key, hidden: false)),
                _bulkBtn('נקה הכל',
                    () => _setModuleElementsHidden(m.key, hidden: true)),
                const SizedBox(width: BsTokens.space2),
              ],
            ],
          ),
          if (open)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  BsTokens.space3, 0, BsTokens.space3, BsTokens.space3),
              child: matched.isEmpty
                  ? const Text('אין רכיבים תואמים',
                      style: TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12.5))
                  : _moduleBody(matched),
            ),
        ],
      ),
    );
  }

  /// מקטע "מודולים ורכיבים" — אקורדיון-Maor: מונה גלובלי · חיפוש-מסנן · צ׳יפי-
  /// מסנן · 14 סקציות (קבלן ראשון). חיפוש/צ׳יפ = **מסננים** (לא תנאי-הצגה) —
  /// תיקון באג "התיבה הריקה": כל המודולים נגללים תמיד, חיפוש רק מצמצם.
  List<Widget> _buildModuleAccordion() {
    final q = _elemQuery.trim().toLowerCase();
    final (gShown, gTotal) = _globalCounts();
    return [
      _sectionTitle('מודולים ורכיבים'),
      Text(
        '$gShown מתוך $gTotal רכיבים פעילים',
        style: const TextStyle(
          color: BsTokens.brandDark,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: BsTokens.space2),
      const Text(
        'כל מודול = סקציה. פתח סקציה כדי להדליק/לכבות רכיבים. חיפוש וצ׳יפים מסננים. ליבה (ניווט/כניסה) נעולה תמיד.',
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
      ),
      const SizedBox(height: BsTokens.space3),
      TextField(
        key: const Key('elem-search'),
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
        decoration: _dec('חיפוש רכיב'),
        onChanged: (v) => setState(() => _elemQuery = v),
      ),
      const SizedBox(height: BsTokens.space2),
      Wrap(
        spacing: BsTokens.space2,
        runSpacing: BsTokens.space2,
        children: [
          ChoiceChip(
            label: const Text('הכל'),
            selected: _filterModule == null,
            onSelected: (_) => setState(() => _filterModule = null),
          ),
          for (final m in kWizardModules)
            ChoiceChip(
              label: Text('${m.emoji} ${m.label}'),
              selected: _filterModule == m.key,
              onSelected: (_) => setState(() =>
                  _filterModule = _filterModule == m.key ? null : m.key),
            ),
        ],
      ),
      const SizedBox(height: BsTokens.space3),
      for (final m in kWizardModules)
        if (_filterModule == null || _filterModule == m.key)
          ..._sectionOrEmpty(m, q),
    ];
  }

  /// סקציה בודדת (או ריק אם חיפוש-פעיל בלי-התאמות — המודול נעלם מהמסננת).
  List<Widget> _sectionOrEmpty(OrgModuleInfo m, String q) {
    final matched = _matchingElements(m.key, q);
    if (q.isNotEmpty && matched.isEmpty) return const <Widget>[];
    return [
      _moduleSection(m, matched,
          open: q.isNotEmpty || _openModules.contains(m.key)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // אותו clamp-נגישות של בונה-הענפים: עד 1.35× — מעבר לזה טפסי-RTL נשברים.
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(math.min(mq.textScaler.scale(1), 1.35)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: BsTokens.bgLight,
          appBar: AppBar(
            backgroundColor: BsTokens.cardLight,
            elevation: 0,
            iconTheme: const IconThemeData(color: BsTokens.inkLight),
            // Text רגיל בכוונה (לא CfgText) — ראה חוקי-הבית בכותרת-הקובץ.
            title: const Text(
              '🔌 אשף הקמת חברה',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space5,
            ),
            children: [
              // מצב לא-חמוש: ה-build רץ בלי ORG_CONFIG=true — הכל עובד חי,
              // אבל hydrateOrgConfig לא יטען את השמירה בפתיחה הבאה.
              if (!kOrgConfigFlag) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: BsTokens.space4,
                    vertical: BsTokens.space3,
                  ),
                  decoration: BoxDecoration(
                    color: BsTokens.warnBright.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'מצב לא-חמוש: השינויים פעילים מיד, אך לא ייטענו אחרי סגירה (נדרש build עם ORG_CONFIG=true).',
                    style: TextStyle(
                      color: BsTokens.warnText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: BsTokens.space4),
              ],
              TextField(
                controller: _orgName,
                textInputAction: TextInputAction.next,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('שם החברה'),
                onChanged: (v) =>
                    setState(() => _draft = _rebuild(orgName: v.trim())),
              ),
              const SizedBox(height: BsTokens.space5),
              _sectionTitle('בחר ורטיקל (נקודת-פתיחה)'),
              const Text(
                'החלת חבילה מחליפה מודולים+מונחים במלואם — שם וזהות נשמרים.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
              ),
              const SizedBox(height: BsTokens.space3),
              Wrap(
                spacing: BsTokens.space2,
                runSpacing: BsTokens.space2,
                children: [
                  for (final p in kVerticalPacks)
                    ChoiceChip(
                      label: Text('${p.emoji} ${p.label}'),
                      selected: _selectedPackId == p.id,
                      onSelected: (_) => setState(() {
                        _draft = applyVerticalPack(_draft, p);
                        _selectedPackId = p.id;
                        _syncTermControllers();
                      }),
                    ),
                ],
              ),
              const SizedBox(height: BsTokens.space5),
              // ── מודולים ורכיבים (giant slice-1) — אקורדיון-Maor: 14 סקציות
              // (קבלן ראשון), שער-פרסונה + מונה + סמן/נקה-הכל + מתגי-רכיבים
              // מקובצי-מסך; חיפוש/צ׳יפים מסננים; ליבה נעולה.
              ..._buildModuleAccordion(),
              const SizedBox(height: BsTokens.space5),
              _sectionTitle('מיתוג ומונחים (ריק = ברירת-המחדל)'),
              for (final f in _kTermFields) ...[
                TextField(
                  controller: _termCtrls[f.key],
                  style:
                      const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                  decoration: _dec(f.label),
                  onChanged: (v) => _setTerm(f.key, v),
                ),
                const SizedBox(height: BsTokens.space3),
              ],
              // ── כלי-סטודיו (giant slice-4/5) — מיחזור verbatim של פאנלי-הסטודיו
              // במסלול-מלא: מצא-והחלף (+publish חי) · גרסאות-והיסטוריה (שחזור).
              const SizedBox(height: BsTokens.space2),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('open-find-replace'),
                      onPressed: _openFindReplace,
                      icon: const Text('🔎', style: TextStyle(fontSize: 15)),
                      label: const Text('מצא והחלף'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('open-history'),
                      onPressed: _openHistory,
                      icon: const Text('🕘', style: TextStyle(fontSize: 15)),
                      label: const Text('גרסאות'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              // ניהול-מסכים (screen-mgmt slice-2) — רשימת-מסכים → עורך-סקציות
              // (סדר + הסתר), על מודל-הסקציות-פר-מסך (slice-1).
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('open-screen-manager'),
                  onPressed: _openScreenManager,
                  icon: const Text('🖥️', style: TextStyle(fontSize: 15)),
                  label: const Text('ניהול מסכים (סדר · הסתר)'),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: BsTokens.brand,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: Text(
                    'שמור והפעל',
                    style: TextStyle(
                      color: bsOnAccent(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              Wrap(
                spacing: BsTokens.space2,
                runSpacing: BsTokens.space2,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BsTokens.inkLight,
                      side: const BorderSide(color: Color(0xFFEDEDED)),
                    ),
                    onPressed: _export,
                    child: const Text('ייצוא JSON'),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BsTokens.inkLight,
                      side: const BorderSide(color: Color(0xFFEDEDED)),
                    ),
                    onPressed: _import,
                    child: const Text('ייבוא JSON'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: BsTokens.mutedLight,
                    ),
                    onPressed: _resetDraft,
                    child: const Text('איפוס טיוטה'),
                  ),
                ],
              ),
              if (_note != null) ...[
                const SizedBox(height: BsTokens.space3),
                Text(
                  _note!,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ✎ מפקח-הרכיב (slice-2) — עורך text/emoji/style חי דרך ה-Studio store ───────
// אוצר-המילים (token, תווית) — מקביל ל-cfgColorFromToken/Size/Weight ב-cfg_text.
// null = "ברירת מחדל" (מוחק את הציר ⇒ CfgStyle ריק ⇒ הרכיב חוזר לבסיס).

const List<(String?, String)> _kColorOpts = [
  (null, 'ברירת מחדל'),
  ('brand', 'מותג'),
  ('brandDark', 'מותג כהה'),
  ('ink', 'דיו'),
  ('muted', 'עמום'),
  ('success', 'ירוק'),
  ('danger', 'אדום'),
  ('warn', 'אזהרה'),
];

const List<(String?, String)> _kSizeOpts = [
  (null, 'ברירת מחדל'),
  ('sm', 'קטן'),
  ('md', 'בינוני'),
  ('lg', 'גדול'),
  ('xl', 'ענק'),
];

const List<(String?, String)> _kWeightOpts = [
  (null, 'ברירת מחדל'),
  ('normal', 'רגיל'),
  ('medium', 'בינוני'),
  ('semibold', 'חצי-מודגש'),
  ('bold', 'מודגש'),
];

/// מפקח-רכיב מלא (slice-2) — bottom-sheet contextual לפי `editableProps`: טקסט ·
/// אמוג׳י · צבע · גודל · משקל. כל שינוי → `applyOps`+`publish` ל-Studio store ⇒
/// **חי בכל האפליקציה** (האשף לא ב-edit-mode ⇒ רק published נראה חי). זרימת-הבסיס:
/// dropdown ל-null / "אפס" → CfgStyle ריק → הרכיב חוזר לברירת-המחדל. תצוגה-חיה
/// מקומית (בלי publish) עם `applyCfgTextStyle` — אותו מנוע שהאפליקציה מרנדרת בו.
class _ElementInspectorSheet extends ConsumerStatefulWidget {
  const _ElementInspectorSheet({required this.descriptor});

  final ElementDescriptor descriptor;

  @override
  ConsumerState<_ElementInspectorSheet> createState() =>
      _ElementInspectorSheetState();
}

class _ElementInspectorSheetState
    extends ConsumerState<_ElementInspectorSheet> {
  final _text = TextEditingController();
  final _emoji = TextEditingController();
  String? _color;
  String? _size;
  String? _weight;

  ElementDescriptor get _d => widget.descriptor;
  bool get _hasText => _d.editableProps.contains(EditAxis.text);
  bool get _hasEmoji => _d.editableProps.contains(EditAxis.emoji);
  bool get _hasStyle => _d.editableProps.contains(EditAxis.style);

  @override
  void initState() {
    super.initState();
    // Seed from the PUBLISHED resolved node (the wizard is not in edit-mode ⇒
    // resolvedNode == published — exactly what the live app shows right now).
    final n = ref.read(resolvedNodeProvider(_d.id));
    _text.text = n.text ?? '';
    _emoji.text = n.emoji ?? '';
    _color = n.style?.colorToken;
    _size = n.style?.sizeToken;
    _weight = n.style?.weightToken;
  }

  @override
  void dispose() {
    _text.dispose();
    _emoji.dispose();
    super.dispose();
  }

  /// The CfgStyle from the three dropdowns — empty (all default) ⇒ null ⇒ clears.
  CfgStyle? _style() {
    final s = CfgStyle(
      colorToken: _color,
      sizeToken: _size,
      weightToken: _weight,
    );
    return s.isEmpty ? null : s;
  }

  /// Apply the current fields to the draft AND publish ⇒ LIVE app-wide. Publishing
  /// (not just draft) is required because the wizard is not in edit-mode, so only
  /// the published layer is visible live.
  void _applyLive() {
    final id = _d.id;
    final ops = <ConfigOp>[
      if (_hasText) SetText(id, _text.text.isEmpty ? null : _text.text),
      if (_hasEmoji) SetEmoji(id, _emoji.text.isEmpty ? null : _emoji.text),
      if (_hasStyle) SetStyle(id, _style()),
    ];
    if (ops.isEmpty) return;
    ref.read(configStoreProvider.notifier)
      ..applyOps(ops)
      ..publish(
        note: 'עריכת רכיב · $id',
        byEmail: ref.read(studioOwnerEmailProvider) ?? '',
        nowMs: DateTime.now().millisecondsSinceEpoch,
        criticalIds: ref.read(criticalIdsProvider),
      );
  }

  void _reset() {
    setState(() {
      _text.text = '';
      _emoji.text = '';
      _color = null;
      _size = null;
      _weight = null;
    });
    _applyLive(); // publish the cleared (identity) node ⇒ back to default, live
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: BsTokens.cardLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _tokenDropdown(
    String label,
    List<(String?, String)> opts,
    String? value,
    ValueChanged<String?> onChanged,
  ) =>
      Padding(
        padding: const EdgeInsets.only(top: BsTokens.space3),
        child: DropdownButtonFormField<String?>(
          // `value:` (not `initialValue:`) — the former is the param that exists
          // on the CI-pinned Flutter 3.29.3; `initialValue` was only added in
          // 3.32+, so it fails to compile on the runner (blast-radius: every
          // test transitively importing this screen). Works on both toolchains.
          value: value,
          isExpanded: true,
          decoration: _dec(label),
          items: [
            for (final o in opts)
              DropdownMenuItem<String?>(value: o.$1, child: Text(o.$2)),
          ],
          onChanged: onChanged,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final previewStyle = applyCfgTextStyle(
      context,
      const TextStyle(
        color: BsTokens.inkLight,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      _style(),
    );
    final previewTxt =
        _hasText && _text.text.isNotEmpty ? _text.text : _d.labelHe;
    final previewEmoji =
        _hasEmoji && _emoji.text.isNotEmpty ? '${_emoji.text} ' : '';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: BsTokens.space4,
          end: BsTokens.space4,
          top: BsTokens.space4,
          bottom: MediaQuery.of(context).viewInsets.bottom + BsTokens.space4,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '✎ ${_d.labelHe}',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: BsTokens.typeSubhead,
                ),
              ),
              Text(
                _d.id,
                style: const TextStyle(
                    color: BsTokens.mutedLight, fontSize: BsTokens.typeCaption),
              ),
              const SizedBox(height: BsTokens.space3),
              // תצוגה-חיה (מקומית, בלי publish) — אותו מנוע-רינדור של האפליקציה.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(BsTokens.space3),
                decoration: BoxDecoration(
                  color: BsTokens.bgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Text('$previewEmoji$previewTxt', style: previewStyle),
              ),
              if (_hasText) ...[
                const SizedBox(height: BsTokens.space3),
                TextField(
                  key: const Key('insp-text'),
                  controller: _text,
                  decoration: _dec('טקסט'),
                  onChanged: (_) => setState(() {}),
                  onEditingComplete: _applyLive,
                ),
              ],
              if (_hasEmoji) ...[
                const SizedBox(height: BsTokens.space3),
                TextField(
                  controller: _emoji,
                  decoration: _dec('אמוג׳י'),
                  onChanged: (_) => setState(() {}),
                  onEditingComplete: _applyLive,
                ),
              ],
              if (_hasStyle) ...[
                _tokenDropdown('צבע', _kColorOpts, _color, (v) {
                  setState(() => _color = v);
                  _applyLive();
                }),
                _tokenDropdown('גודל', _kSizeOpts, _size, (v) {
                  setState(() => _size = v);
                  _applyLive();
                }),
                _tokenDropdown('משקל', _kWeightOpts, _weight, (v) {
                  setState(() => _weight = v);
                  _applyLive();
                }),
              ],
              const SizedBox(height: BsTokens.space4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('insp-reset'),
                      onPressed: _reset,
                      child: const Text('אפס לברירת-מחדל'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: BsTokens.brand),
                      onPressed: () {
                        _applyLive();
                        Navigator.of(context).maybePop();
                      },
                      child: const Text('החל וסגור (חי)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── מצא-והחלף באשף (slice-4) — מסלול-מלא סביב `FindReplacePane` של הסטודיו ──────
// מיחזור **verbatim** של הפאנל (חיפוש-מצע על overrides · תצוגת before→after ·
// applyOps אצווה→טיוטה). האשף מוסיף רק "פרסם לכולם (חי)" ב-AppBar — הצעד ההופך
// את הטיוטה לחיה (האשף לא ב-edit-mode ⇒ publish הכרחי, בדיוק כמו ✎/slice-2).
class _WizardFindReplaceScreen extends ConsumerWidget {
  const _WizardFindReplaceScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.brand,
          foregroundColor: Colors.white,
          title: const Text('מצא והחלף בטקסטים'),
          actions: [
            TextButton.icon(
              onPressed: () {
                ref.read(configStoreProvider.notifier).publish(
                      note: 'מצא-והחלף · אשף',
                      byEmail: ref.read(studioOwnerEmailProvider) ?? '',
                      nowMs: DateTime.now().millisecondsSinceEpoch,
                      criticalIds: ref.read(criticalIdsProvider),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('פורסם — חי בכל האפליקציה ✓'),
                  ),
                );
              },
              icon: const Icon(Icons.publish, color: Colors.white),
              label: const Text(
                'פרסם לכולם (חי)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        body: const FindReplacePane(),
      ),
    );
  }
}

// ─── גרסאות והיסטוריה באשף (slice-5) — מסלול-מלא סביב `HistoryPane` של הסטודיו ──
// מיחזור **verbatim** של הפאנל (רשימת ConfigVersion חדש-ראשון · הערה/מפרסם/זמן ·
// "שחזר" = rollback קדימה-בלבד מאחורי דיאלוג-אישור · מצב-ריק ידידותי). כל
// "פרסם לכולם" (מ-✎/slice-2 או מצא-והחלף/slice-4) נרשם כאן — וניתן לשחזר.
class _WizardHistoryScreen extends StatelessWidget {
  const _WizardHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.brand,
          foregroundColor: Colors.white,
          title: const Text('גרסאות והיסטוריה'),
        ),
        body: const HistoryPane(),
      ),
    );
  }
}

// ─── ניהול-מסכים באשף (screen-mgmt slice-2) — רמה-1 מסכים → רמה-2 סקציות ─────────
// שני מפלסים על מודל-הסקציות-פר-מסך (slice-1): רמה-1 מסדרת/מסתירה מסך-שלם
// (rootKey=kScreensRootKey), רמה-2 מסדרת/מסתירה את הסקציות של מסך (rootKey=id).
// ברירת-מחדל (בלי התאמה) = סדר קנוני, הכל מוצג ⇒ זהה-בייטים. persist דרך slice-1.

/// רשימה נגררת+מוסתרת מעל `screenSectionsProvider` — משותפת לשני המפלסים.
class _SectionManagerList extends ConsumerWidget {
  const _SectionManagerList({
    required this.rootKey,
    required this.defaults,
    required this.meta,
    this.onEnter,
  });

  final String rootKey;
  final List<String> defaults;

  /// id → (emoji · label · האם ניתן להיכנס פנימה [רמה-2]).
  final Map<String, ({String emoji, String label, bool canEnter})> meta;
  final void Function(String id)? onEnter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(screenSectionsProvider); // rebuild on any layout change
    final n = ref.read(screenSectionsProvider.notifier);
    final ids = n.orderedIds(rootKey, defaults);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (o, nw) => n.reorder(rootKey, defaults, o, nw),
          children: [
            for (var i = 0; i < ids.length; i++) _row(context, n, i, ids[i]),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: OutlinedButton.icon(
            onPressed: () => n.resetScreen(rootKey),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('אפס סדר/הסתרה'),
          ),
        ),
      ],
    );
  }

  Widget _row(
      BuildContext context, ScreenSectionsNotifier n, int i, String id) {
    final m = meta[id];
    final hidden = n.isHidden(rootKey, id);
    final label = n.labelOf(rootKey, id, m?.label ?? id);
    return Container(
      key: ValueKey(id),
      margin: const EdgeInsets.fromLTRB(
          BsTokens.space4, BsTokens.space1, BsTokens.space4, BsTokens.space1),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: i,
            child: const Padding(
              padding: EdgeInsets.all(BsTokens.space3),
              child: Icon(Icons.drag_indicator, color: BsTokens.mutedLight),
            ),
          ),
          Text(m?.emoji ?? '•', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: hidden ? BsTokens.mutedLight : BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                decoration: hidden ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          // ✎ עריכה — שינוי-שם הפריט (חי במקלדת · בעורך לסקציות).
          IconButton(
            key: Key('sec-edit-$rootKey-$id'),
            visualDensity: VisualDensity.compact,
            icon: const Text('✎', style: TextStyle(fontSize: 15)),
            tooltip: 'ערוך שם',
            onPressed: () => _renameItem(context, n, id, label),
          ),
          Switch(
            key: Key('sec-show-$rootKey-$id'),
            value: !hidden,
            activeColor: BsTokens.brand,
            onChanged: (_) => n.toggle(rootKey, id),
          ),
          if (m?.canEnter ?? false)
            IconButton(
              key: Key('sec-enter-$id'),
              icon: const Icon(Icons.chevron_left),
              tooltip: 'ערוך סקציות',
              onPressed: () => onEnter?.call(id),
            ),
        ],
      ),
    );
  }

  /// ✎ עריכת-שם: דיאלוג rename. "שמור" → override; "אפס" (או ריק) → חזרה
  /// לברירת-המחדל. חל חי (מקלדת: האריח משתנה · סקציות: השם בעורך).
  Future<void> _renameItem(BuildContext context, ScreenSectionsNotifier n,
      String id, String current) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: current),
    );
    if (value != null) n.setLabel(rootKey, id, value);
  }
}

/// ✎ rename dialog — a StatefulWidget so it OWNS + disposes its own controller
/// (disposing a controller a plain dialog builder created races the dismiss
/// animation and asserts). Pops the new name, `''` to reset, or null on dismiss.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: BsTokens.cardLight,
          title: const Text('ערוך שם'),
          content: TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'שם',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(''), // ריק → ברירת-מחדל
              child: const Text('אפס לברירת-מחדל'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: BsTokens.brand),
              onPressed: () => Navigator.of(context).pop(_ctrl.text),
              child: const Text('שמור'),
            ),
          ],
        ),
      );
}

/// רמה-1 — רשימת המסכים (סדר / הסתר מסך-שלם), חץ → עורך-הסקציות של המסך.
class _ScreenManagerScreen extends StatelessWidget {
  const _ScreenManagerScreen();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.brand,
          foregroundColor: Colors.white,
          title: const Text('ניהול מסכים'),
        ),
        body: _SectionManagerList(
          rootKey: kScreensRootKey,
          defaults: [for (final s in kManagedScreens) s.id],
          meta: {
            for (final s in kManagedScreens)
              s.id: (emoji: s.emoji, label: s.labelHe, canEnter: true),
          },
          onEnter: (id) {
            final screen = kManagedScreens.firstWhere((s) => s.id == id);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _ScreenSectionEditor(screen: screen),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// רמה-2 — עורך-הסקציות של מסך אחד (סדר + הסתר). מסך שטרם-נבנה-כסקציות מציג
/// placeholder כן (slice-5), בלי סקציות מומצאות.
class _ScreenSectionEditor extends StatelessWidget {
  const _ScreenSectionEditor({required this.screen});

  final ManagedScreen screen;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.brand,
          foregroundColor: Colors.white,
          title: Text('${screen.emoji} ${screen.labelHe} — סקציות'),
          actions: [
            // slice-4: the per-screen keyboard is edited HERE (from the screen
            // editor), never from the keyboard itself.
            if (screen.hasKeyboard)
              TextButton.icon(
                key: const Key('open-screen-keyboard'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _ScreenKeyboardEditor(screen: screen),
                  ),
                ),
                icon: const Text('⌨️', style: TextStyle(fontSize: 15)),
                label: const Text('מקלדת',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        body: screen.isSectionBuilt
            ? _SectionManagerList(
                rootKey: screen.id,
                defaults: [for (final s in screen.sections) s.id],
                meta: {
                  for (final s in screen.sections)
                    s.id: (emoji: s.emoji, label: s.labelHe, canEnter: false),
                },
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(BsTokens.space5),
                  child: Text(
                    'המסך הזה טרם נבנה כסקציות.\n'
                    'עריכת-הסקציות תיפתח כשהמסך יומר למבנה-סקציות (slice-5).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: BsTokens.mutedLight, height: 1.4),
                  ),
                ),
              ),
      ),
    );
  }
}

/// slice-4 — עורך המקלדת של מסך אחד (סדר + הסתר אריחי-מקלדת), על אותו מודל-
/// הסקציות (rootKey=`kbd:<screen>`) ואותו `_SectionManagerList`. נערך מכאן ולא
/// מהמקלדת (כלי לא עורך את עצמו). **תשתית:** נשמר; החלת-הסינון על המקלדת-הצפה
/// תחווט כשהמקלדת-הגלובלית (`kKbGlobal`) תשוגר — עד אז אין אפקט-חי.
class _ScreenKeyboardEditor extends StatelessWidget {
  const _ScreenKeyboardEditor({required this.screen});

  final ManagedScreen screen;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.brand,
          foregroundColor: Colors.white,
          title: Text('⌨️ מקלדת · ${screen.labelHe}'),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF4E5),
              padding: const EdgeInsets.all(BsTokens.space3),
              child: const Text(
                'סדר והסתר את אריחי-המקלדת של המסך. נשמר עכשיו; יחול על '
                'המקלדת-הצפה כשתשוגר (kKbGlobal).',
                style: TextStyle(color: Color(0xFF7A3E00), fontSize: 12.5),
              ),
            ),
            Expanded(
              child: _SectionManagerList(
                rootKey: keyboardLayoutKey(screen.id),
                defaults: [for (final k in screen.keyboardTools) k.id],
                meta: {
                  for (final k in screen.keyboardTools)
                    k.id: (emoji: k.emoji, label: k.labelHe, canEnter: false),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
