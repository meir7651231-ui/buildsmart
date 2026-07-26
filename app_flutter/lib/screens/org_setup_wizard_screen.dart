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
        encodeOrgConfig,
        kDefaultOrgConfig,
        kOrgConfigFlag,
        moduleOn;
import 'package:buildsmart/config/org_modules.dart'
    show OrgModuleInfo, kOrgModules, kWizardLockedModules;
import 'package:buildsmart/config/vertical_packs.dart'
    show applyVerticalPack, kVerticalPacks;
import 'package:buildsmart/services/file_transfer.dart'
    show downloadTextFileProvider, pickTextFileProvider;
import 'package:buildsmart/state/org_config_store.dart'
    show orgConfigProvider, persistOrgConfig;
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
  /// המקומית שומרת slug/theme/features כפי-שהם ומחליפה רק מה שהאשף עורך.
  OrgConfig _rebuild({
    String? orgName,
    Map<String, bool>? modules,
    Map<String, String>? terms,
  }) =>
      OrgConfig(
        slug: _draft.slug,
        orgName: orgName ?? _draft.orgName,
        theme: _draft.theme,
        features: _draft.features,
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
