// ⚛️ אטום-Dart (דרגת-חוזה) · sizeTableHash
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart:60 (‏_sizeTableHash; חוק-4).
//        האטום = השורה בלבד; שאר-הטיוטה (‏ConnectorType, SystemDef — data-classes-שכנות)
//        אינו היעד ולא הוטבע.
// טוהר: עצמאי לחלוטין — אפס import, אפס const, אפס שקע (חוק-1). `Object.hashAll` = dart:core.
//        שם-המקור פרטי (`_sizeTableHash`) → נחשף כ-top-level `sizeTableHash`.
//
// קלט:  t — טבלת-מידות nullable: `List<List<String>>?`.
// פלט:  `0` עבור `null`; אחרת `Object.hashAll` על גיבובי-השורות (‏`Object.hashAll` פר-שורה).

/// Order-sensitive structural hash of a nullable size table.
/// `null → 0`; otherwise `Object.hashAll` over each row's own `Object.hashAll`.
/// Verbatim behaviour of connection_schema.dart:60.
int sizeTableHash(List<List<String>>? t) =>
    t == null ? 0 : Object.hashAll(t.map(Object.hashAll));
