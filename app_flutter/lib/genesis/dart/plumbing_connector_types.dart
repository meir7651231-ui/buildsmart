// ⚛️ אטום-Dart (דרגת-חוזה) · plumbingConnectorTypes
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:271-299
//        (‏plumbingConnectorTypes; ענף claude/whats-happening-LyY9G; חוק-4 — התנהגות
//        זהה-ביט, לא-משופרת). ConnectorType אחד פר-EndType, ממוין לפי id;
//        sizeValues = קבוצת-הגדלים הנבדלת-והממוינת שנראתה לאותו סוג-קצה על-פני
//        כל המפרטים המאומתים; nameHe = תווית-תיאור authored (הפיזיקה לא קוראת אותה);
//        systemId נגזר ממיפוי-המערכת המאומת של ConnectorEnd.system.
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3; דפוס usable_connector):
//   • kVerifiedSpecs (המפה הגלובלית, lipskey_verified_connections.dart) — במקור:
//     `for (final spec in kVerifiedSpecs.values) for (final end in spec.ends)`.
//     קורס לשקע `verifiedEnds` (Iterable<ConnectorEnd> שטוח) — האיסוף הוא
//     צבירת-קבוצה (Set) אדישה-לקיבוץ, ולכן השטחה = פלט זהה-ביט. הקופסה מחווטת:
//     `[for (final s in kVerifiedSpecs.values) ...s.ends]`.
// אחים-באותו-קובץ שהוטבעו verbatim (חוק-1; תקדים conn_type_id/system_id):
//   • kPlumbingTradeId (plumbing_trade_seed.dart:30) · _connTypeId (‏:40) ·
//     _systemId (‏:38).
//   • _systemOfEndType (‏:57) — במקור `ConnectorEnd(e, '').system`; ה-getter
//     ‏system (lipskey_verified_connections.dart:70-77) קורא רק את `type`, לכן
//     ה-switch הוטבע כאן ישירות על ה-EndType — זהה-התנהגות, בלי מופע-ביניים.
// טיפוסי-שכן שהוטבעו מינימלית (תבנית verified_spec_to_doc):
//   • EndType (lipskey_verified_connections.dart:24, verbatim — סדר-ההכרזה קובע
//     את סדר-הבנייה טרם-המיון) · WaterSystem (‏:41, verbatim) ·
//     ConnectorEnd (‏:43, רק type+size) ·
//     ConnectorType (connection_schema.dart:64-85, רק ה-constructor והשדות).
// טוהר: dart:core בלבד; אפס state; אפס דאטה-צרובה מלבד תוויות-ה-nameHe
//        וסכימת-ה-id — שתיהן חלק מגוף-המקור הקדוש עצמו (לא שכן).
//
// קלט:  verifiedEnds — כל קצוות-המחבר של כל המפרטים המאומתים (שטוח).
// פלט:  6 ConnectorType (אחד פר-EndType), ממוינים לפי id.

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

/// טיפוס-שכן מוטבע (connection_schema.dart:64-85) — constructor + שדות בלבד.
class ConnectorType {
  const ConnectorType({
    required this.id,
    required this.tradeId,
    required this.nameHe,
    this.sizeValues = const [],
    this.systemId,
  });
  final String id;
  final String tradeId;
  final String nameHe;
  final List<String> sizeValues;
  final String? systemId;
}

/// המזהה השמור של סחר-האינסטלציה המובנה — verbatim (plumbing_trade_seed.dart:30).
const String kPlumbingTradeId = 'plumbing';

/// מזהה-סוג-חיבור יציב — verbatim (plumbing_trade_seed.dart:40).
String _connTypeId(EndType e) => '$kPlumbingTradeId.conn.${e.name}';

/// מזהה-מערכת יציב — verbatim (plumbing_trade_seed.dart:38).
String _systemId(WaterSystem s) => '$kPlumbingTradeId.sys.${s.name}';

/// המערכת של סוג-קצה — ה-switch המאומת של ConnectorEnd.system
/// (lipskey_verified_connections.dart:70-77), מוטבע ישירות על ה-EndType
/// (במקור: `ConnectorEnd(e, '').system` — ה-getter קורא רק את type).
WaterSystem _systemOfEndType(EndType e) => switch (e) {
      EndType.hdpeCompression || EndType.drainOpening => WaterSystem.drainage,
      EndType.bspMale ||
      EndType.bspFemale ||
      EndType.pexPress ||
      EndType.copperPress =>
        WaterSystem.supply,
    };

/// ConnectorType אחד פר-[EndType], ממוין לפי id — verbatim
/// plumbing_trade_seed.dart:271-299 (‏kVerifiedSpecs ⇒ שקע-הקצוות). PURE.
List<ConnectorType> plumbingConnectorTypes(Iterable<ConnectorEnd> verifiedEnds) {
  const nameHe = <EndType, String>{
    EndType.hdpeCompression: 'הידוק HDPE',
    EndType.pexPress: 'PEX פרס',
    EndType.copperPress: 'נחושת פרס',
    EndType.bspMale: 'תבריג זכר (BSP)',
    EndType.bspFemale: 'תבריג נקבה (BSP)',
    EndType.drainOpening: 'פתח ניקוז',
  };
  // Collect the distinct sizes per end-type across every verified spec.
  final sizesByType = <EndType, Set<String>>{
    for (final e in EndType.values) e: <String>{},
  };
  for (final end in verifiedEnds) {
    sizesByType[end.type]!.add(end.size);
  }
  return <ConnectorType>[
    for (final e in EndType.values)
      ConnectorType(
        id: _connTypeId(e),
        tradeId: kPlumbingTradeId,
        nameHe: nameHe[e]!,
        sizeValues: sizesByType[e]!.toList()..sort(),
        systemId: _systemId(_systemOfEndType(e)),
      ),
  ]..sort((a, b) => a.id.compareTo(b.id));
}
