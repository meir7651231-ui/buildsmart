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
        moduleOn;
import 'package:buildsmart/config/org_modules.dart'
    show OrgModuleInfo, kOrgModules, kWizardLockedModules;
import 'package:buildsmart/config/screen_labels_he.dart'
    show normalizeScreen, screenLabelHe;
import 'package:buildsmart/config/vertical_packs.dart'
    show applyVerticalPack, kVerticalPacks;
import 'package:buildsmart/services/file_transfer.dart'
    show downloadTextFileProvider, pickTextFileProvider;
import 'package:buildsmart/state/org_config_store.dart'
    show orgConfigProvider, persistOrgConfig;
import 'package:buildsmart/state/studio/element_registry.dart'
    show ElementDescriptor, kElementRegistry;
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
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

  /// מקטע-רכיבים: שאילתת-החיפוש החיה. הרשימה מונחית-חיפוש — ריק ⇒ לא מציגים
  /// קבוצות (האשף נשאר קצר, כפתור-השמירה בהישג); הקלדה חושפת קבוצות תואמות.
  String _elemQuery = '';

  /// קבוצות-מסך שהמשתמש כיווץ ידנית (ברירת-המחדל בחיפוש: פתוח, כדי שהתאמות
  /// יופיעו מיד). מפתח-מסך מנורמל ב-set = מכווץ.
  final Set<String> _collapsedElemScreens = <String>{};

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

  /// שורת-מודול אחת: מתג עם אימוג׳י · שם · תיאור; 'manager' נעול (onChanged
  /// null — הקונפיג עצמו עדיין יודע false מייבוא-JSON חיצוני, ה-UI רק מגן).
  Widget _moduleTile(OrgModuleInfo m) {
    final locked = kWizardLockedModules.contains(m.key);
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
        locked ? '${m.descHe} · מוגן נעילה-עצמית' : m.descHe,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
      ),
      value: moduleOn(_draft, m.key),
      onChanged: locked ? null : (v) => _setModule(m.key, on: v),
    );
  }

  /// סופר-רכיבים בקבוצת-מסך (סכום כל האזורים) — לשורת-המשנה ולמיון-לפי-נפח.
  int _elemCount(Map<String, List<ElementDescriptor>> areas) =>
      areas.values.fold<int>(0, (n, l) => n + l.length);

  /// שורת-רכיב אחת: מתג הצג/הסתר. ליבה (kImmutable) — נעולה (onChanged null,
  /// value=מוצג-תמיד) עם חיווי 🔒; לעולם לא מציעים לכבות ניווט/כניסה.
  Widget _elementTile(ElementDescriptor d) {
    final locked = d.kImmutable;
    return SwitchListTile(
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
  }

  /// גוף קבוצת-מסך: תוויות-אזור (raw — חופשי) + מתגי-הרכיבים. נבנה בהורה **רק
  /// כשהקבוצה פתוחה** (lazy — 863 רכיבים לא נבנים בקבוצות סגורות).
  Widget _elemGroupBody(Map<String, List<ElementDescriptor>> areas) {
    final areaKeys = areas.keys.toList()..sort();
    // Transparent Material ancestor so the SwitchListTiles have a Material to
    // paint ink/background on — the group card is a colored DecoratedBox, and a
    // ListTile directly under a colored DecoratedBox trips a framework assertion
    // (its ink/bg would be hidden). Transparent ⇒ the card color still shows.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final area in areaKeys) ...[
            Padding(
              padding: const EdgeInsets.only(top: BsTokens.space2, bottom: 2),
              child: Text(
                area,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final d in areas[area]!) _elementTile(d),
          ],
        ],
      ),
    );
  }

  /// מקטע "רכיבים" — כותרת + הסבר + שדה-חיפוש, ואז תוצאות מונחות-חיפוש. מכוון:
  /// 863 רכיבים לא נשפכים כברירת-מחדל — האשף נשאר קצר (כפתור-השמירה בהישג),
  /// והקלדה חושפת רק את הקבוצות התואמות.
  List<Widget> _buildElementsSection() {
    final q = _elemQuery.trim().toLowerCase();
    return [
      _sectionTitle('רכיבים'),
      const Text(
        'חפש רכיב כדי להציג או להסתיר אותו. ליבה (ניווט/כניסה) נעולה תמיד.',
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
      ),
      const SizedBox(height: BsTokens.space3),
      TextField(
        key: const Key('elem-search'),
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
        decoration: _dec('חיפוש רכיב'),
        onChanged: (v) => setState(() => _elemQuery = v),
      ),
      const SizedBox(height: BsTokens.space3),
      ..._buildElementResults(q),
    ];
  }

  /// תוצאות-החיפוש של מקטע-הרכיבים. ריק ⇒ רמז (בלי לבנות קבוצות). אחרת: סינון
  /// פר-רכיב לפי labelHe/id, קיבוץ מסך→אזור (מיזוג-כפילויות ב-[normalizeScreen]),
  /// מיון לפי נפח (יורד) עם שובר-שוויון יציב, וכל קבוצה נפתחת כברירת-מחדל.
  List<Widget> _buildElementResults(String q) {
    if (q.isEmpty) {
      return const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: BsTokens.space2),
          child: Text(
            'הקלד שם רכיב (בעברית) כדי להציג ולהסתיר.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
        ),
      ];
    }
    final groups = <String, Map<String, List<ElementDescriptor>>>{};
    for (final d in kElementRegistry) {
      if (!d.labelHe.toLowerCase().contains(q) &&
          !d.id.toLowerCase().contains(q)) {
        continue;
      }
      (groups[normalizeScreen(d.screen)] ??=
              <String, List<ElementDescriptor>>{})
          .putIfAbsent(d.area, () => <ElementDescriptor>[])
          .add(d);
    }
    if (groups.isEmpty) {
      return const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: BsTokens.space2),
          child: Text(
            'לא נמצאו רכיבים תואמים',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
        ),
      ];
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        final ca = _elemCount(groups[a]!);
        final cb = _elemCount(groups[b]!);
        return ca != cb ? cb.compareTo(ca) : a.compareTo(b);
      });
    return [
      for (final sk in keys)
        _ElemGroup(
          title: screenLabelHe(sk),
          sub: '${_elemCount(groups[sk]!)} רכיבים',
          // ברירת-מחדל פתוח (התאמות נראות מיד); המשתמש יכול לכווץ.
          open: !_collapsedElemScreens.contains(sk),
          onTap: () => setState(() {
            if (!_collapsedElemScreens.remove(sk)) {
              _collapsedElemScreens.add(sk);
            }
          }),
          // הגוף נבנה רק כשפתוח — זו ה-laziness (מכווץ ⇒ אפס מתגים).
          body: _collapsedElemScreens.contains(sk)
              ? null
              : _elemGroupBody(groups[sk]!),
        ),
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
              _sectionTitle('מודולים'),
              for (final m in kOrgModules) _moduleTile(m),
              const SizedBox(height: BsTokens.space5),
              // ── מקטע "רכיבים" (giant-system) — ציר הצג/הסתר על רג׳יסטרי-
              // הסטודיו, מקובץ מסך→אזור, חיפוש-חי, אקורדיון עצל; ליבה נעולה.
              ..._buildElementsSection(),
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

/// מקטע-רכיבים אחד (מסך) באקורדיון — סגנון _ManageSection של לוח-המנהל,
/// ממומש-מחדש מקומית (חוקי-בית: Text רגיל בלבד, בלי CfgText/HelpTarget). הגוף
/// ([body]) נבנה בהורה **רק כשפתוח** ומועבר null כשסגור — כך 863 מתגי-הרכיבים
/// לא נבנים בקבוצות סגורות.
class _ElemGroup extends StatelessWidget {
  const _ElemGroup({
    required this.title,
    required this.sub,
    required this.open,
    required this.onTap,
    this.body,
  });

  final String title;
  final String sub;
  final bool open;
  final VoidCallback onTap;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final content = body;
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
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(BsTokens.space3),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sub,
                            style: const TextStyle(
                              color: BsTokens.mutedLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    // ▾ פתוח · ‹ סגור — אותם גליפים של _ManageSection (RTL).
                    Text(
                      open ? '▾' : '‹',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open && content != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                BsTokens.space3,
                0,
                BsTokens.space3,
                BsTokens.space3,
              ),
              child: content,
            ),
        ],
      ),
    );
  }
}
