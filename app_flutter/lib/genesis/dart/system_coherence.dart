// ⚛️ אטום-Dart (דרגת-חוזה) · systemCoherence
// תפקיד: האם קו-מוצרים נשאר בתוך מערכת-מוסמכת אחת (למשל חלקי-אספקה לא מעורבבים
//        בקו-ניקוז). קצוות נסרקים בסדר-הקו; type לא-מוכר / systemId==null מדולגים;
//        יותר ממערכת לא-null אחת ⇒ לא-קוהרנטי + ה-sku הראשון-הסוטה + ה-SystemDef השונה.
// מוצא: buildsmart/app_flutter/lib/domain/connection_resolver.dart:391-409
//        (מתודת systemCoherence; ענף claude/align-main; חוק-4 — התנהגות זהה, לא-משופרת).
// אחים שהוטבעו/סוקטו (חוק-1/3, דיבר-3):
//   • _systemIdByTypeId / _systemById (שדות-מופע late-final, נגזרי-constructor —
//     connection_resolver.dart:186-195) ⇒ שקעי `connectorTypes` / `systems`; הגזירה
//     (map-literal, כפילות-id ⇒ האחרון-מנצח — דטרמיניסטי) עברה לגוף האטום verbatim.
//   • טיפוסי-שכן ⇒ הוטבעו מינימלית (רק השדות הנקראים/מאוחסנים), בתבנית האח completion.dart:
//     ProductConnectorSpec/ConnectorEnd · ConnectorType{id,systemId?} (connection_schema.dart:64-107)
//     · SystemDef (connection_schema.dart:110-128; stored-only פרט ל-id) ·
//     SystemCoherence (connection_resolver.dart:125-154).
// טוהר: dart:core בלבד; אפס state-מופע; אפס דאטה-צרובה.

/// verbatim connection_resolver.dart:391-409 (שדות-המופע ⇒ שקעים).
SystemCoherence systemCoherence(
  List<ProductConnectorSpec> line, {
  required List<ConnectorType> connectorTypes,
  required List<SystemDef> systems,
}) {
  // נגזרות-השקעים — verbatim connection_resolver.dart:186-195 (האחרון-מנצח בכפילות-id).
  final systemIdByTypeId = <String, String?>{
    for (final t in connectorTypes) t.id: t.systemId,
  };
  final systemById = <String, SystemDef>{
    for (final s in systems) s.id: s,
  };

  String? firstSystemId;
  for (final spec in line) {
    for (final end in spec.ends) {
      final sysId = systemIdByTypeId[end.connectorTypeId];
      if (sysId == null) continue;
      if (firstSystemId == null) {
        firstSystemId = sysId;
      } else if (sysId != firstSystemId) {
        return SystemCoherence(
          coherent: false,
          offendingSystem: systemById[sysId],
          offendingSku: spec.productSku,
        );
      }
    }
  }
  return const SystemCoherence(coherent: true);
}

// — טיפוסי-שכן מוטבעים (השדות הנקראים/מאוחסנים ע"י האטום בלבד) —

/// קצה-מוצר — מינימום connection_schema.dart:146-155 (האטום קורא connectorTypeId בלבד).
class ConnectorEnd {
  const ConnectorEnd({required this.connectorTypeId});
  final String connectorTypeId;
}

/// spec-מוצר — מינימום connection_schema.dart:171-204 (productSku + ends בלבד).
class ProductConnectorSpec {
  const ProductConnectorSpec({required this.productSku, this.ends = const []});
  final String productSku;
  final List<ConnectorEnd> ends;
}

/// type-מחבר — מינימום connection_schema.dart:64-107 (id + systemId בלבד; null = חסר-מערכת).
class ConnectorType {
  const ConnectorType({required this.id, this.systemId});
  final String id;
  final String? systemId;
}

/// הגדרת-מערכת — connection_schema.dart:110-128; האטום קורא רק id, השאר stored-only
/// (מוחזרים לקורא בתוך offendingSystem) ⇒ אופציונליים בהטבעה.
class SystemDef {
  const SystemDef({
    required this.id,
    this.tradeId = '',
    this.nameHe = '',
    this.color = 0,
  });
  final String id;
  final String tradeId;
  final String nameHe;
  final int color;
}

/// תוצאת-הקוהרנטיות — verbatim connection_resolver.dart:125-154 (בלי ==/hashCode — לא-נקראים באטום).
class SystemCoherence {
  const SystemCoherence({
    required this.coherent,
    this.offendingSystem,
    this.offendingSku,
  });

  /// true כשלכל-היותר מערכת לא-null מובחנת אחת מופיעה על קצוות-הקו.
  final bool coherent;

  /// ה-SystemDef של המערכת השונה — null כשהקו קוהרנטי, וגם כשהמערכת השונה
  /// איננה ב-systems (הקו עדיין לא-קוהרנטי).
  final SystemDef? offendingSystem;

  /// ה-sku הראשון (סדר-קו) הנושא קצה שמערכתו שונה מהראשונה-שנראתה; null כשקוהרנטי.
  final String? offendingSku;
}
