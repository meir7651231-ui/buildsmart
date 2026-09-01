// ⚛️ אטום-Dart (דרגת-חוזה) · endPair (‏`_endPair` + עוזרו `_sizeOk`)
// מוצא: buildsmart/app_flutter/lib/domain/connection_resolver.dart:239-302
//        (‏ConnectionResolver._endPair:239-266 · _sizeOk:277-302; חוק-4 — verbatim).
//        ⚠️ קו-האמת: הקובץ אינו קיים על main של buildsmart — חולץ מ-
//        origin/claude/align-main ≡ origin/claude/whats-happening-LyY9G (md5 זהה,
//        0b34f3fa…) — ענף-העבודה החי של app_flutter.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core — Object.hash).
//       ‏4 טיפוסי-הסכמה הוטבעו מינימלית-verbatim (הכרעה-2 של הקידום-הקשה):
//         • enum SizeMatch    (connection_schema.dart:23)
//         • enum RuleSeverity (connection_schema.dart:27)
//         • ProductEnd        (connection_schema.dart:146-168 — שני שדות-הקריאה)
//         • CompatibilityRule (connection_schema.dart:240-277 — רק 7 השדות
//           שהאטום קורא: id/aTypeId/bTypeId/sizeMatch/sizeTable/methodLabelHe/
//           onMismatch; ‏toJson/==/tradeId/material* אינם נקראים כאן — בקופסה).
//       ‏ConnectResult (connection_resolver.dart:49-83) הוטבע verbatim
//       (‏==/hashCode נשמרו; ‏@immutable הושמט — אין ייבוא flutter באטום).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `rules` — שדה-המופע ConnectionResolver.rules (‏:170) ⇒ פרמטר. נסרק
//     בסדר-הרשימה (authored order = שובר-השוויון הדטרמיניסטי).
//   • `normalizeSize` — שכן top-level (‏connection_resolver.dart:31) ⇒ שקע
//     `String Function(String)`. התנהגות-המקור: מסיר כל `"` (U+0022) ואז trim —
//     `'1/2'` == `'1/2"'` == `' 1/2" '`. **כל** השוואות-הגודל עוברות דרכו
//     (‏exactSame וגם תאי-tableLookup).
//
// התנהגות (מקור :239-266 — טבלת-ההכרעה של ConnectResult, ‏:36-42):
//   1. סורקים rules בסדר-הרשימה. חוקה מתאימה-לזוג FORWARD כאשר
//      `rule.aTypeId==endA.type && rule.bTypeId==endB.type`, או REVERSE כשה-ids
//      מתאימים בהיפוך (חוקת-same-type נתפסת כ-forward — האוריינטציות מתלכדות).
//   2. החוקה הראשונה שמתאימה-לזוג **וגם** עוברת בדיקת-גודל ⇒
//      ‏ConnectResult(mates:true, methodLabelHe:rule.methodLabelHe, rule:rule).
//   3. חוקה שמתאימה-לזוג אך נכשלת-בגודל אינה עוצרת את הסריקה; אם אף חוקה לא
//      חיברה — ה-size-miss ה-**ראשון** מעצב את הכישלון:
//      ‏(mates:false, methodLabelHe:'', severity:rule.onMismatch, rule:rule).
//   4. אף חוקה לא כיסתה את זוג-הטיפוסים ⇒ `_noRule`:
//      ‏(mates:false, methodLabelHe:'', severity:null, rule:null) — "לא מתחבר"
//      מתועד, לא-חריגה.
//   בדיקת-גודל (_sizeOk, ‏:277-302): ‏exactSame ⇒ שוויון-אחרי-normalize ·
//   ‏anyToAny ⇒ תמיד-true · tableLookup ⇒ שורות `[aSize,bSize]` באוריינטציית
//   ‏(aTypeId,bTypeId) המוצהרת של החוקה — הצד שמגלם aTypeId מספק עמודה 0
//   (‏reverse ⇒ מחפשים `[endB,endA]`); שורה קצרה מ-2 מדולגת; טבלה-null תחת
//   ‏tableLookup לעולם אינה מתאימה.
//
// קלט:  endA, endB     — שני קצוות-המוצר (ProductEnd).
//       rules          — חוקות-ההתאמה המחוברות (סדר = עדיפות).
//       normalizeSize  — שקע-נירמול-גודל (במקור: הסרת `"` + trim).
// פלט:  ConnectResult — לפי טבלת-ההכרעה שלעיל.

/// Size-matching mode of a rule (verbatim: connection_schema.dart:23).
enum SizeMatch { exactSame, anyToAny, tableLookup }

/// Rule severity (verbatim: connection_schema.dart:27; maps name-for-name to
/// the engine's CheckSeverity).
enum RuleSeverity { info, warning, critical }

/// Pure input holder — the two fields the evaluator reads
/// (verbatim fields: connection_schema.dart:154-155).
class ProductEnd {
  const ProductEnd({required this.connectorTypeId, required this.sizeValue});
  final String connectorTypeId;
  final String sizeValue;
}

/// Authored pair rule — minimal verbatim holder: only the 7 fields this atom
/// reads (connection_schema.dart:268-275; codecs/equality live in the box).
class CompatibilityRule {
  const CompatibilityRule({
    required this.id,
    required this.aTypeId,
    required this.bTypeId,
    required this.sizeMatch,
    required this.methodLabelHe,
    this.sizeTable, // for tableLookup: allowed [aSize, bSize] pairs
    this.onMismatch = RuleSeverity.warning,
  });

  final String id;
  final String aTypeId; // documented order: [a, b]; sizeTable rows are [aSize, bSize]
  final String bTypeId;
  final SizeMatch sizeMatch;
  final List<List<String>>? sizeTable;
  final String methodLabelHe;
  final RuleSeverity onMismatch;
}

/// The outcome of evaluating one end-pair against the authored
/// [CompatibilityRule]s (verbatim: connection_resolver.dart:49-83; decision
/// table :36-42 — exactly three shapes: matched / size-miss / no-rule).
class ConnectResult {
  const ConnectResult({
    required this.mates,
    required this.methodLabelHe,
    this.severity,
    this.rule,
  });

  /// Whether the two ends physically mate under some authored rule.
  final bool mates;

  /// The matched rule's authored joint label (Hebrew); `''` when [mates] is
  /// false.
  final String methodLabelHe;

  /// Null on success and on "no rule at all"; the considered rule's
  /// [CompatibilityRule.onMismatch] when a pair-rule existed but its size
  /// check failed.
  final RuleSeverity? severity;

  /// The matched rule (on success) or the first pair-matching rule whose size
  /// check failed (on a size-miss); null when no rule covers the type-pair.
  final CompatibilityRule? rule;

  @override
  bool operator ==(Object other) =>
      other is ConnectResult &&
      other.mates == mates &&
      other.methodLabelHe == methodLabelHe &&
      other.severity == severity &&
      other.rule == rule;

  @override
  int get hashCode => Object.hash(mates, methodLabelHe, severity, rule);
}

/// "No rule covered the type-pair" — a documented "doesn't connect", never an
/// exception (verbatim: connection_resolver.dart:197-198).
const ConnectResult _noRule = ConnectResult(mates: false, methodLabelHe: '');

/// Evaluates one end-pair against [rules] in list order — verbatim behavior of
/// `ConnectionResolver._endPair` (connection_resolver.dart:239-266).
ConnectResult endPair(
  ProductEnd endA,
  ProductEnd endB, {
  required List<CompatibilityRule> rules,
  required String Function(String) normalizeSize,
}) {
  CompatibilityRule? firstSizeMiss;
  for (final rule in rules) {
    final forward = rule.aTypeId == endA.connectorTypeId &&
        rule.bTypeId == endB.connectorTypeId;
    final reverse = !forward &&
        rule.aTypeId == endB.connectorTypeId &&
        rule.bTypeId == endA.connectorTypeId;
    if (!forward && !reverse) continue;
    if (_sizeOk(rule, endA, endB, forward: forward, normalizeSize: normalizeSize)) {
      return ConnectResult(
        mates: true,
        methodLabelHe: rule.methodLabelHe,
        rule: rule,
      );
    }
    firstSizeMiss ??= rule;
  }
  if (firstSizeMiss != null) {
    return ConnectResult(
      mates: false,
      methodLabelHe: '',
      severity: firstSizeMiss.onMismatch,
      rule: firstSizeMiss,
    );
  }
  return _noRule;
}

/// Size check per `rule.sizeMatch`, all comparisons via [normalizeSize]
/// (verbatim: connection_resolver.dart:277-302; orientation rule :270-276).
bool _sizeOk(
  CompatibilityRule rule,
  ProductEnd endA,
  ProductEnd endB, {
  required bool forward,
  required String Function(String) normalizeSize,
}) {
  switch (rule.sizeMatch) {
    case SizeMatch.exactSame:
      return normalizeSize(endA.sizeValue) == normalizeSize(endB.sizeValue);
    case SizeMatch.anyToAny:
      return true;
    case SizeMatch.tableLookup:
      final table = rule.sizeTable;
      if (table == null) return false;
      final aSide = normalizeSize(forward ? endA.sizeValue : endB.sizeValue);
      final bSide = normalizeSize(forward ? endB.sizeValue : endA.sizeValue);
      for (final row in table) {
        if (row.length < 2) continue;
        if (normalizeSize(row[0]) == aSide &&
            normalizeSize(row[1]) == bSide) {
          return true;
        }
      }
      return false;
  }
}
