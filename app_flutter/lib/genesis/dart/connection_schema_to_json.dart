// ⚛️ אטום-Dart (דרגת-חוזה) · connectionSchemaToJson — סריאליזציית-JSON של סכמת-החיבורים
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart
//        (‏ProductEnd.toJson ‏:157-158 · ProductConnectorSpec.toJson ‏:206-214 ·
//        CompatibilityRule.toJson ‏:279-291 · CompletionRule.toJson ‏:356-367; חוק-4 — verbatim).
//        ⚠️ קו-האמת: הקובץ אינו קיים על main של buildsmart — חולץ מ-
//        origin/claude/align-main ≡ origin/claude/whats-happening-LyY9G (md5 זהה,
//        8e0a2620…) — ענף-העבודה החי של app_flutter.
// 🏷️ שם-הטיוטה `to_json` גנרי (טיוטה-אחות מ-studio_rules_model קודמה כ-config_ops_to_json)
//        ⇒ שם-מובחן-דומיין: connection_schema_to_json (הכרעה-4 של הקידום-הקשה).
// טוהר: אפס import. 4 מחלקות-הסכמה + 2 enums הוטבעו מינימלית-verbatim (הכרעה-2):
//        שדות + בנאי (ברירות-מחדל verbatim) + toJson בלבד. ‏fromJson (עוזריו כבר
//        אטומים: size_match_from/size_table/num_map/str_list_or_null) ו-==/hashCode
//        (תלויי listEquals/mapEquals של flutter) אינם באטום-הזה — קידוד-לאחור
//        ושוויון חיים באטומים/קופסה אחרים. ‏@immutable הושמט (תקדים end_pair).
//
// התנהגות (עוגני-שורה בחוזה): מפתח-אופציונלי (null) מושמט (collection-if);
// ‏ends/envelope תמיד-נוכחים גם-כשריקים; enum ⇒ .name; סדר-מפתחות = סדר-המקור;
// ‏TOTAL — לעולם לא זורק, אפס-mutation.
//
// קלט:  מופע בנוי של אחת מ-4 מחלקות-הסכמה.
// פלט:  Map<String, dynamic> מוכן-ל-jsonEncode, לפי טבלת-החוזה.

/// Size-matching mode of a rule (verbatim: connection_schema.dart:23).
enum SizeMatch { exactSame, anyToAny, tableLookup }

/// Rule severity (verbatim: connection_schema.dart:27; maps name-for-name to
/// the engine's CheckSeverity).
enum RuleSeverity { info, warning, critical }

/// One physical end of a product (verbatim: connection_schema.dart:146-158 —
/// fields, constructor and toJson; codecs/equality live elsewhere).
class ProductEnd {
  const ProductEnd({required this.connectorTypeId, required this.sizeValue});

  final String connectorTypeId;
  final String sizeValue;

  Map<String, dynamic> toJson() =>
      {'connectorTypeId': connectorTypeId, 'sizeValue': sizeValue};
}

/// A product's authored connector spec (verbatim: connection_schema.dart:170-214).
class ProductConnectorSpec {
  const ProductConnectorSpec({
    required this.productSku,
    required this.tradeId,
    this.ends = const [],
    this.materialId,
    this.ratingHe,
    this.envelope = const {},
    this.materialGroupId, // R1-3 (derived galvanic group)
  });

  final String productSku;
  final String tradeId;
  final List<ProductEnd> ends;
  final String? materialId;
  final String? ratingHe;
  final Map<String, num> envelope; // trade-defined keys: {maxTempC:40}|{maxAmp:16}
  final String? materialGroupId;

  Map<String, dynamic> toJson() => {
        'productSku': productSku,
        'tradeId': tradeId,
        'ends': ends.map((e) => e.toJson()).toList(),
        if (materialId != null) 'materialId': materialId,
        if (ratingHe != null) 'ratingHe': ratingHe,
        'envelope': envelope,
        if (materialGroupId != null) 'materialGroupId': materialGroupId,
      };
}

/// Authored pair-compatibility rule (verbatim: connection_schema.dart:240-291).
class CompatibilityRule {
  const CompatibilityRule({
    required this.id,
    required this.tradeId,
    required this.aTypeId,
    required this.bTypeId,
    required this.sizeMatch,
    required this.methodLabelHe,
    this.sizeTable, // for tableLookup: allowed [aSize, bSize] pairs
    this.onMismatch = RuleSeverity.warning,
    this.materialGroup, // R1-3
    this.incompatibleMaterialGroups, // R1-3
  });

  final String id;
  final String tradeId;
  final String aTypeId; // documented order: [a, b]; sizeTable rows are [aSize, bSize]
  final String bTypeId;
  final SizeMatch sizeMatch;
  final List<List<String>>? sizeTable;
  final String methodLabelHe;
  final RuleSeverity onMismatch;
  final String? materialGroup;
  final List<String>? incompatibleMaterialGroups;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'aTypeId': aTypeId,
        'bTypeId': bTypeId,
        'sizeMatch': sizeMatch.name,
        'methodLabelHe': methodLabelHe,
        if (sizeTable != null) 'sizeTable': sizeTable,
        'onMismatch': onMismatch.name,
        if (materialGroup != null) 'materialGroup': materialGroup,
        if (incompatibleMaterialGroups != null)
          'incompatibleMaterialGroups': incompatibleMaterialGroups,
      };
}

/// Authored completion rule — "when the line has X, require Y"
/// (verbatim: connection_schema.dart:322-367).
class CompletionRule {
  const CompletionRule({
    required this.id,
    required this.tradeId,
    required this.whenInLineHasTypeId,
    required this.requireTypeId,
    required this.whyHe,
    this.severity = RuleSeverity.warning,
    this.incompatibleMaterialGroups, // R1-3
    this.requiredInterposerWhyHe, // R1-3
  });

  final String id;
  final String tradeId;
  final String whenInLineHasTypeId; // trigger
  final String requireTypeId;
  final String whyHe;
  final RuleSeverity severity;
  final List<String>? incompatibleMaterialGroups;
  final String? requiredInterposerWhyHe;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'whenInLineHasTypeId': whenInLineHasTypeId,
        'requireTypeId': requireTypeId,
        'whyHe': whyHe,
        'severity': severity.name,
        if (incompatibleMaterialGroups != null)
          'incompatibleMaterialGroups': incompatibleMaterialGroups,
        if (requiredInterposerWhyHe != null)
          'requiredInterposerWhyHe': requiredInterposerWhyHe,
      };
}
