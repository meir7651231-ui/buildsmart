// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · קרנל-ה-workflow — PURE Dart, אפס Flutter.
//
// הדפוס מ-Maor `lib/ayin.ts` — **הדפוס עובר, הקוד לא**: מכונת-מצבים גנרית
// ניתנת-לשם (5 שלבים), guards פר-שלב, מתכנן-מעבר טהור (patch + אירוע-לוח +
// toast), dedup-על-שם, ותזמון-"מגע-הבא" + דוח-"טופל-היום". המפתחות הפנימיים
// קבועים; **כל תווית דרך termOf** (מיתוג פר-ורטיקל: אינסטלציה תקרא לזה
// "בקשה→תזמון→העמסה→מסירה→סגור", חשמל אחרת).
//
// זהו קרנל additive-נטו: אף מנוע/מסך קיים לא נוגע בו (אסור — 6 חוזי-בדיקה
// נעולים על orders/material/tasks). הצרכן החי מגיע בפרוסה מגודרת נפרדת; כאן
// הלוגיקה הטהורה + חוזי-הבדיקה, מוכחת מוטציה.
//
// לוח-זמנים: `nextTouch` הוא תאריך-תזכורת מתוזמן בלבד — **אין auto-advance**
// כשהוא עובר (כמו ayin). כל תאריך נבנה מ-isoLocal (מקומי, לא-UTC — ישראל).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart' show OrgConfig, termOf;
import 'package:buildsmart/logic/text_normalize.dart' show normName;

/// חמשת השלבים בסדר קבוע (אינדקס 0..4). המפתחות מסתדרים ל-'new'..'done'.
enum WfStage { intake, prep, ready, dispatch, done }

const List<WfStage> kWfStages = [
  WfStage.intake,
  WfStage.prep,
  WfStage.ready,
  WfStage.dispatch,
  WfStage.done,
];

/// מפתח-סריאליזציה יציב (תואם ayin: new/lead/eyes/answer/done → כאן שמות-בנייה
/// נקיים, אבל היציבות היא מה שנשמר לאורך גרסאות).
String wfStageKey(WfStage s) => switch (s) {
      WfStage.intake => 'intake',
      WfStage.prep => 'prep',
      WfStage.ready => 'ready',
      WfStage.dispatch => 'dispatch',
      WfStage.done => 'done',
    };

WfStage? wfStageFromKey(String k) => switch (k) {
      'intake' => WfStage.intake,
      'prep' => WfStage.prep,
      'ready' => WfStage.ready,
      'dispatch' => WfStage.dispatch,
      'done' => WfStage.done,
      _ => null,
    };

/// תוויות-נופלות ניטרליות (ניתנות-לשם דרך termOf `workflow.stage.<key>`).
const Map<WfStage, String> _kStageFallback = {
  WfStage.intake: 'חדש',
  WfStage.prep: 'בהכנה',
  WfStage.ready: 'מוכן',
  WfStage.dispatch: 'מסירה',
  WfStage.done: 'הושלם',
};

String wfStageLabel(OrgConfig cfg, WfStage s) =>
    termOf(cfg, 'workflow.stage.${wfStageKey(s)}', _kStageFallback[s]!);

/// שם-הפיצ'ר / שם-הפריט / שם-היחידה — ניתנים-לשם.
String wfFeatureLabel(OrgConfig cfg) => termOf(cfg, 'nav.workflow', 'מעקב טיפול');
String wfItemLabel(OrgConfig cfg) => termOf(cfg, 'entity.wfItem', 'פריט');
String wfUnitLabel(OrgConfig cfg) => termOf(cfg, 'entity.wfUnit', 'כמות');

int wfStageIndex(WfStage s) => kWfStages.indexOf(s);

WfStage? wfNextStage(WfStage s) {
  final i = wfStageIndex(s);
  return i < kWfStages.length - 1 ? kWfStages[i + 1] : null;
}

/// פריט-שורה במקרה-workflow (dedup לפי שם-מנורמל; כמות אופציונלית).
class WfName {
  const WfName({required this.id, required this.name, this.units, this.done = false});
  final String id;
  final String name;
  final int? units; // null = לא-נספר
  final bool done;
}

class WfLog {
  const WfLog({required this.date, required this.units, this.name});
  final String date;
  final int units;
  final String? name;
}

/// מקרה-workflow יחיד — immutable; `copyWith` לשינויים.
class WfCase {
  const WfCase({
    this.stage = WfStage.intake,
    this.note = '',
    this.dispatchPushed = false,
    this.nextTouch = '',
    this.nextTouchTime = '',
    this.lastTouch = '',
    this.names = const [],
    this.log = const [],
  });

  final WfStage stage;
  final String note;
  final bool dispatchPushed; // נקבע בלחיצה-1 של מסירה; מתאפס ב-revert-לפני-מסירה
  final String nextTouch; // 'YYYY-MM-DD' — מגע-הבא המתוזמן
  final String nextTouchTime; // 'HH:MM'
  final String lastTouch; // מוטבע כמעט בכל מוטציה — מקור "טופל-היום"
  final List<WfName> names;
  final List<WfLog> log;

  WfCase copyWith({
    WfStage? stage,
    String? note,
    bool? dispatchPushed,
    String? nextTouch,
    String? nextTouchTime,
    String? lastTouch,
    List<WfName>? names,
    List<WfLog>? log,
  }) =>
      WfCase(
        stage: stage ?? this.stage,
        note: note ?? this.note,
        dispatchPushed: dispatchPushed ?? this.dispatchPushed,
        nextTouch: nextTouch ?? this.nextTouch,
        nextTouchTime: nextTouchTime ?? this.nextTouchTime,
        lastTouch: lastTouch ?? this.lastTouch,
        names: names ?? this.names,
        log: log ?? this.log,
      );
}

/// כמות מצטברת של כל השמות.
int wfUnitsTotal(WfCase a) =>
    a.names.fold(0, (t, x) => t + (x.units ?? 0));

/// "פעיל" — מוצג בלוח ברגע שקרתה אינטראקציה כלשהי.
bool wfActive(WfCase? a) {
  if (a == null) return false;
  return a.stage != WfStage.intake ||
      a.names.isNotEmpty ||
      a.lastTouch.isNotEmpty ||
      a.log.isNotEmpty;
}

/// האם כפתור-הקידום גלוי בשלב הנוכחי (ה-guard).
bool wfActionVisible(WfCase a) {
  switch (a.stage) {
    case WfStage.done:
      return false;
    case WfStage.intake:
      return a.names.isNotEmpty;
    case WfStage.ready:
      return a.names.any((n) => n.units != null);
    case WfStage.prep:
    case WfStage.dispatch:
      return true;
  }
}

/// תווית-כפתור-הקידום פר-שלב.
String wfAdvanceLabel(OrgConfig cfg, WfCase a) {
  switch (a.stage) {
    case WfStage.intake:
      return '${wfStageLabel(cfg, WfStage.prep)} ←';
    case WfStage.prep:
      return '✓ אישור — ${wfStageLabel(cfg, WfStage.prep)}';
    case WfStage.ready:
      return '${wfStageLabel(cfg, WfStage.dispatch)} ←';
    case WfStage.dispatch:
      return a.dispatchPushed
          ? '✓ ${wfStageLabel(cfg, WfStage.done)}'
          : '📞 דחיפה ללוח';
    case WfStage.done:
      return '';
  }
}

/// תוצאת-תכנון-מעבר: patch + אירוע-לוח אופציונלי + toast. null אם לא-גלוי.
class WfAdvancePlan {
  const WfAdvancePlan({required this.patch, required this.event, required this.toast});
  final WfCase patch; // מוחל דרך copyWith על המקרה החי
  final ({String title, bool done})? event;
  final String toast;
}

/// מתכנן-המעבר הטהור. מחזיר null כשהפעולה לא-גלויה. שלב "dispatch" הוא
/// **2-לחיצות**: לחיצה-1 מדליקה dispatchPushed ונשארת ב-dispatch; לחיצה-2
/// (כשכבר-נדחף) מקדמת ל-done. (מראה verbatim את planAyinAdvance של מאור.)
WfAdvancePlan? planWfAdvance(OrgConfig cfg, String name, WfCase a) {
  if (!wfActionVisible(a)) return null;
  final feat = wfFeatureLabel(cfg);
  final item = wfItemLabel(cfg);
  final unit = wfUnitLabel(cfg);
  switch (a.stage) {
    case WfStage.intake:
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.prep),
        event: (title: '$feat: ${wfStageLabel(cfg, WfStage.prep)} — $name (${a.names.length} $item)', done: false),
        toast: 'נרשמו ${a.names.length} — נכנס ללוח: ${wfStageLabel(cfg, WfStage.prep)}',
      );
    case WfStage.prep:
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.ready),
        event: (title: '$feat: ${wfStageLabel(cfg, WfStage.prep)} ✓ — $name', done: true),
        toast: 'אושר — עכשיו: ${wfStageLabel(cfg, WfStage.ready)}',
      );
    case WfStage.ready:
      final units = wfUnitsTotal(a);
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.dispatch),
        event: (title: '$feat: ${wfStageLabel(cfg, WfStage.dispatch)} — $name ($units $unit)', done: false),
        toast: 'נרשם — נכנס ללוח: ${wfStageLabel(cfg, WfStage.dispatch)}',
      );
    case WfStage.dispatch:
      if (!a.dispatchPushed) {
        return WfAdvancePlan(
          patch: a.copyWith(dispatchPushed: true),
          event: (title: '$feat: ${wfStageLabel(cfg, WfStage.dispatch)} — $name', done: false),
          toast: 'נמסר — נרשם בלוח היומי',
        );
      }
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.done),
        event: (title: '$feat: ${wfStageLabel(cfg, WfStage.done)} — $name', done: true),
        toast: 'הטיפול הושלם ✓',
      );
    case WfStage.done:
      return null;
  }
}

/// patch-החזרה (revert): חזרה לפני "dispatch" מנקה את dispatchPushed.
WfCase wfRevertPatch(WfCase a, WfStage to) => a.copyWith(
      stage: to,
      dispatchPushed: wfStageIndex(to) >= wfStageIndex(WfStage.dispatch) &&
          a.dispatchPushed,
    );

/// נרמול-שם ל-dedup: מ-ליבת-הטקסט המשותפת ([normName] = normSearch + הסרת-רווח).
String wfNormName(String s) => normName(s);

/// הוספת-שם טהורה: dedup לפי wfNormName; רשומת-log רק אם ניתנה כמות.
/// מחזיר או ({names, log?}) או שגיאה.
({List<WfName> names, List<WfLog>? log})? planAddName(
  WfCase a,
  String rawName,
  int? units,
  String id, {
  required String todayIso,
}) {
  final nm = rawName.trim();
  if (nm.isEmpty) return null; // ריק — המתקשר מציג את השגיאה
  final key = wfNormName(nm);
  if (a.names.any((x) => wfNormName(x.name) == key)) return null; // כפול
  final names = [...a.names, WfName(id: id, name: nm, units: units)];
  if (units != null) {
    return (names: names, log: [WfLog(date: todayIso, units: units, name: nm), ...a.log]);
  }
  return (names: names, log: null);
}

/// דוח "טופל-היום": שורות-כותרת + מקרה-לכל-מי-שנגע-היום (lastTouch או log-היום).
List<List<Object>> wfDailyRows(
  OrgConfig cfg,
  List<({String name, String phone, WfCase? wf})> entities,
  String todayIso,
) {
  final unit = wfUnitLabel(cfg);
  final item = wfItemLabel(cfg);
  final rows = <List<Object>>[
    ['שם', 'טלפון', '$unit היום', 'שלב', item, 'מתי לדבר שוב', 'הערה'],
  ];
  for (final e in entities) {
    final a = e.wf;
    if (a == null) continue;
    final touched =
        a.lastTouch == todayIso || a.log.any((l) => l.date == todayIso);
    if (!touched) continue;
    final logToday = a.log.where((l) => l.date == todayIso).toList();
    final unitsToday = logToday.isNotEmpty
        ? logToday.fold<int>(0, (t, l) => t + l.units)
        : (wfUnitsTotal(a) == 0 ? '' : wfUnitsTotal(a));
    final namesLine = a.names
        .map((n) => n.name + (n.units != null ? ' ·${n.units}' : '') + (n.done ? ' ✓' : ''))
        .join(' · ');
    rows.add([
      e.name,
      e.phone,
      unitsToday,
      wfStageLabel(cfg, a.stage),
      namesLine,
      a.nextTouch,
      a.note,
    ]);
  }
  return rows;
}

// (נרמול-החיפוש-העברי חולץ ל-lib/logic/text_normalize.dart — נקודת-אמת אחת
// שגם ה-CRM צורך; ההתנהגות זהה-בייטים לפונקציה שהייתה כאן.)
