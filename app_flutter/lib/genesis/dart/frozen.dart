// ⚛️ אטום-Dart (דרגת-חוזה) · frozen
// תפקיד: צילום-רגע IMMUTABLE של משטח-שאילתות הרישום (addition-a §9) — מרוץ בין
//        בניית-פרומפט לפרסור רואה תמונת-רישום יציבה אחת, גם אם המקור זז מתחתיו.
// מוצא: buildsmart/app_flutter/lib/logic/studio/registry_view.dart:69-93 (‏RegistryView.frozen; חוק-4).
// אחים שהוטבעו/סוקטו:
//   • 5 מתודות-this של RegistryView (elementIds/propKeysFor/allowedValues/actionIdsFor/
//     componentTypes, ‏:44-63) ⇒ 5 שקעי-פונקציה (חוק-3).
//   • FakeRegistryView (‏:96-158) ⇒ הוטבע כ-class מינימלי FrozenRegistryView (הכרעה 2):
//     סמנטיקת `.of` verbatim (‏:106-133) — איחוד-ids, Set.unmodifiable בכל הרמות,
//     שאילתה fail-closed (‏`?? _empty`, ‏:143-157). ירושת RegistryView הוסרה (אין היררכיה
//     באטום) — היכולת שירש (frozen) מומשה ישירות: הקפאה-חוזרת שקולת-תוכן.
// טוהר: dart:core בלבד; אפס import, אפס דאטה-צרובה, אפס זהות/סוד.

/// צילום-רגע בלתי-ניתן-לשינוי של הרישום — הטבעת FakeRegistryView (‏:96-158) המינימלית.
/// כל הקבוצות unmodifiable ⇒ אי-אפשר להרחיב קבוצה-סגורה שהוחזרה; שאילתה על id/prop
/// לא-ידוע ⇒ קבוצה ריקה (fail-closed — לעולם לא זורק, לעולם לא pass-all).
class FrozenRegistryView {
  /// בנייה מקבוצות מוזרקות — verbatim ‏`FakeRegistryView.of` (‏:106-133): ‏[ids] מאוחד
  /// עם מפתחות שאר-המפות, כך ש-id שמוזכר רק ב-[propKeys]/[actionIds]/[allowedValues]
  /// הוא עדיין element תקף (אין id חצי-רשום).
  FrozenRegistryView.of({
    Set<String> ids = const {},
    Map<String, Set<String>> propKeys = const {},
    Map<String, Map<String, Set<String>>> allowedValues = const {},
    Map<String, Set<String>> actionIds = const {},
    Set<String> componentTypes = const {},
  })  : _ids = Set<String>.unmodifiable(<String>{
          ...ids,
          ...propKeys.keys,
          ...allowedValues.keys,
          ...actionIds.keys,
        }),
        _propKeys = {
          for (final e in propKeys.entries)
            e.key: Set<String>.unmodifiable(e.value),
        },
        _allowedValues = {
          for (final e in allowedValues.entries)
            e.key: {
              for (final v in e.value.entries)
                v.key: Set<String>.unmodifiable(v.value),
            },
        },
        _actionIds = {
          for (final e in actionIds.entries)
            e.key: Set<String>.unmodifiable(e.value),
        },
        _componentTypes = Set<String>.unmodifiable(componentTypes);

  final Set<String> _ids;
  final Map<String, Set<String>> _propKeys;
  final Map<String, Map<String, Set<String>>> _allowedValues;
  final Map<String, Set<String>> _actionIds;
  final Set<String> _componentTypes;

  static const Set<String> _empty = <String>{};

  Set<String> elementIds() => _ids;

  Set<String> propKeysFor(String id) => _propKeys[id] ?? _empty;

  Set<String> allowedValues(String id, String propKey) =>
      _allowedValues[id]?[propKey] ?? _empty;

  Set<String> actionIdsFor(String id) => _actionIds[id] ?? _empty;

  Set<String> componentTypes() => _componentTypes;

  /// במקור FakeRegistryView יורש את `frozen()` מ-RegistryView — הקפאת-צילום מחזירה
  /// צילום שקול-תוכן (אידמפוטנטי). כאן ישירות, דרך אותו בנאי-שקעים.
  FrozenRegistryView frozen() => frozenRegistrySnapshot(
        elementIds: elementIds,
        propKeysFor: propKeysFor,
        allowedValues: allowedValues,
        actionIdsFor: actionIdsFor,
        componentTypes: componentTypes,
      );
}

/// verbatim registry_view.dart:69-93 — ‏5 מתודות-this ⇒ 5 שקעים (חוק-3); רק ערכים
/// לא-ריקים נאספים; ‏allowedValues נשאל אך-ורק על מפתחות מתוך propKeysFor(id) (‏:80).
FrozenRegistryView frozen({
  required Set<String> Function() elementIds,
  required Set<String> Function(String id) propKeysFor,
  required Set<String> Function(String id, String propKey) allowedValues,
  required Set<String> Function(String id) actionIdsFor,
  required Set<String> Function() componentTypes,
}) =>
    frozenRegistrySnapshot(
      elementIds: elementIds,
      propKeysFor: propKeysFor,
      allowedValues: allowedValues,
      actionIdsFor: actionIdsFor,
      componentTypes: componentTypes,
    );

/// גוף-המקור (‏:70-92) — שם-עזר כדי ש-frozen (top-level) ו-FrozenRegistryView.frozen
/// (המתודה שהמקור מוריש) יחלקו מימוש אחד. אותה לוגיקה, אותם עוגנים.
FrozenRegistryView frozenRegistrySnapshot({
  required Set<String> Function() elementIds,
  required Set<String> Function(String id) propKeysFor,
  required Set<String> Function(String id, String propKey) allowedValues,
  required Set<String> Function(String id) actionIdsFor,
  required Set<String> Function() componentTypes,
}) {
  final ids = elementIds();
  final propKeys = <String, Set<String>>{};
  final allowed = <String, Map<String, Set<String>>>{};
  final actions = <String, Set<String>>{};
  for (final id in ids) {
    final pk = propKeysFor(id);
    if (pk.isNotEmpty) propKeys[id] = pk;
    final acts = actionIdsFor(id);
    if (acts.isNotEmpty) actions[id] = acts;
    final byProp = <String, Set<String>>{};
    for (final k in pk) {
      final vals = allowedValues(id, k);
      if (vals.isNotEmpty) byProp[k] = vals;
    }
    if (byProp.isNotEmpty) allowed[id] = byProp;
  }
  return FrozenRegistryView.of(
    ids: ids,
    propKeys: propKeys,
    allowedValues: allowed,
    actionIds: actions,
    componentTypes: componentTypes(),
  );
}
