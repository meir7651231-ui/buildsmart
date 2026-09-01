// ⚛️ אטום-Dart (דרגת-חוזה) · verifiedSpecToDoc
// מוצא: buildsmart/app_flutter/lib/data/repositories/verified_spec_seed.dart:33-49 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core). בונה Map רגילה
//        (בלי Firestore/Timestamp) — הקצוות = enum-as-name, temp = מספר.
//
// אחים שהוטבעו (טיפוסי-שכן, כלל-1):
//   • `EndType` — enum verbatim מ-lipskey_verified_connections.dart:24.
//   • `WaterSystem` — enum verbatim מ-lipskey_verified_connections.dart:41.
//   • `ConnectorEnd` — מ-lipskey_verified_connections.dart:43, רק `type` + `size`
//        (מתודות-ההתנהגות directMatesWith/pipeSharedWith/system הושמטו).
//   • `VerifiedSpec` — מ-lipskey_verified_connections.dart:77, רק השדות שהפונקציה
//        קוראת (sku · ends · material · pressureRating · pexType · maxTempC ·
//        systemOverride); המתודות compatibleWith/… הושמטו.
//
// קלט:  s — מפרט מאומת.
// פלט:  שדה-מפה `verified_specs/{sku}` — האופציונליים נכתבים רק כשקיימים.

/// enum verbatim (lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// enum verbatim (lipskey_verified_connections.dart:41).
enum WaterSystem { supply, drainage }

/// טיפוס-שכן מוטבע (lipskey_verified_connections.dart:43) — רק `type` + `size`.
class ConnectorEnd {
  const ConnectorEnd(this.type, this.size);
  final EndType type;
  final String size;
}

/// טיפוס-שכן מוטבע (lipskey_verified_connections.dart:77) — רק השדות הנקראים.
class VerifiedSpec {
  const VerifiedSpec({
    required this.sku,
    required this.ends,
    required this.material,
    this.pressureRating,
    this.pexType,
    this.maxTempC = 40,
    this.systemOverride,
  });
  final String sku;
  final List<ConnectorEnd> ends;
  final String material;
  final String? pressureRating;
  final String? pexType;
  final double maxTempC;
  final WaterSystem? systemOverride;
}

/// [VerifiedSpec] → שדה-מפה של `verified_specs/{sku}`. טהור.
Map<String, dynamic> verifiedSpecToDoc(VerifiedSpec s) => <String, dynamic>{
      'sku': s.sku,
      'material': s.material,
      'maxTempC': s.maxTempC,
      'ends': <Map<String, dynamic>>[
        for (final e in s.ends) <String, dynamic>{'type': e.type.name, 'size': e.size},
      ],
      if (s.pressureRating != null) 'pressureRating': s.pressureRating,
      if (s.pexType != null) 'pexType': s.pexType,
      if (s.systemOverride != null) 'systemOverride': s.systemOverride!.name,
    };
