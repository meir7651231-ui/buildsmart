// ⚛️ אטום-Dart (דרגת-חוזה) · completion
// תפקיד: בודק "שלמות-קו" מול חוקי-השלמה — (1) צורת-חומר: ≥2 קבוצות-חומר בלתי-תואמות נוכחות בקו
//        ⇒ issue; (2) צורת-טיפוס: קיים type-מפעיל אך חסר ה-type-הנדרש ⇒ issue. מחזיר רשימת-issues.
// מוצא: buildsmart/app_flutter/lib/domain/connection_resolver.dart:320-386 (מתודת completion; חוק-4).
// אחים שהוטבעו/סוקטו (חוק-3):
//   • completionRules (שדה-מופע) ⇒ שקע `rules` (List<CompletionRule>).
//   • טיפוסי-שכן ProductConnectorSpec/ConnectorEnd/CompletionRule/CompletionIssue ⇒ הוטבעו inline
//     (severity כ-String — לא-מסועף באטום, רק מאוחסן).
// טוהר: dart:core בלבד; אפס state-מופע.

/// verbatim connection_resolver.dart:320-386 (completionRules ⇒ שקע rules).
List<CompletionIssue> completion(
  List<ProductConnectorSpec> line, {
  required List<CompletionRule> rules,
}) {
  final presentGroups = <String>{
    for (final spec in line)
      if (spec.materialGroupId != null) spec.materialGroupId!,
  };
  final issues = <CompletionIssue>[];
  for (final rule in rules) {
    // (1) MATERIAL shape.
    final groups = rule.incompatibleMaterialGroups;
    if (groups != null && groups.isNotEmpty) {
      final hit = <String>{
        for (final g in groups)
          if (presentGroups.contains(g)) g,
      };
      if (hit.length >= 2) {
        issues.add(
          CompletionIssue(
            rule: rule,
            whyHe: rule.requiredInterposerWhyHe ?? rule.whyHe,
            severity: rule.severity,
            offendingSkus: [
              for (final spec in line)
                if (spec.materialGroupId != null &&
                    hit.contains(spec.materialGroupId))
                  spec.productSku,
            ],
          ),
        );
      }
    }
    // (2) TYPE shape.
    if (rule.whenInLineHasTypeId.isNotEmpty) {
      final triggerSkus = <String>[
        for (final spec in line)
          if (spec.ends.any(
            (e) => e.connectorTypeId == rule.whenInLineHasTypeId,
          ))
            spec.productSku,
      ];
      if (triggerSkus.isNotEmpty) {
        final hasRequired = line.any(
          (spec) => spec.ends.any(
            (e) => e.connectorTypeId == rule.requireTypeId,
          ),
        );
        if (!hasRequired) {
          issues.add(
            CompletionIssue(
              rule: rule,
              whyHe: rule.whyHe,
              severity: rule.severity,
              offendingSkus: triggerSkus,
            ),
          );
        }
      }
    }
  }
  return issues;
}

// — טיפוסי-שכן מוטבעים (השדות הנקראים ע"י האטום בלבד) —
class ConnectorEnd {
  const ConnectorEnd({required this.connectorTypeId});
  final String connectorTypeId;
}

class ProductConnectorSpec {
  const ProductConnectorSpec({
    required this.productSku,
    this.materialGroupId,
    this.ends = const [],
  });
  final String productSku;
  final String? materialGroupId;
  final List<ConnectorEnd> ends;
}

class CompletionRule {
  const CompletionRule({
    required this.whyHe,
    required this.severity,
    this.whenInLineHasTypeId = '',
    this.requireTypeId = '',
    this.incompatibleMaterialGroups,
    this.requiredInterposerWhyHe,
  });
  final String whyHe;
  final String severity;
  final String whenInLineHasTypeId;
  final String requireTypeId;
  final List<String>? incompatibleMaterialGroups;
  final String? requiredInterposerWhyHe;
}

class CompletionIssue {
  const CompletionIssue({
    required this.rule,
    required this.whyHe,
    required this.severity,
    required this.offendingSkus,
  });
  final CompletionRule rule;
  final String whyHe;
  final String severity;
  final List<String> offendingSkus;
}
