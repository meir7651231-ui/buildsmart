// 🔑 מנוע-קטלוג-3D · פאזה B (שלבים 30+34 + הרכבה) — המפרט-הבַּניָה המלא: מרכיב את
// שכבות-הגזירה של אביזר-יחיד (מידות · envelope · קצוות-מדויקים · תווית-חיבור ·
// פרמטרי-ריתוך · בטיחות-קו-חם · תקנים) למבנה אחד. ניכוי-החיתוך Z הוא ברמת-מסלול
// (`cut_list.dart`), לא כאן. מגודר (`features/fittings/`).
//
// 🛡️ M5: הריתוך/בטיחות נשענים על השכבות המאומתות (`weld_table`/`safety`) — ערכי-
// ייחוס + caveat חובה, לעולם לא ערך-מחייב · uncertain → null.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show ConnectorEnd, EndType;
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:buildsmart/features/fittings/plan/deep_ends.dart';
import 'package:buildsmart/features/fittings/plan/envelope.dart';
import 'package:buildsmart/features/fittings/plan/safety.dart';
import 'package:buildsmart/features/fittings/plan/weld_table.dart';
import 'package:flutter/foundation.dart' show immutable;

/// תקני PP-R — verbatim מהמקור-המאומת `gen3d.html:422` (שלב 34).
const List<String> kPprStandards = [
  'DIN 8077/8078', 'ISO 15874', 'EN ISO 15874', 'DVS 2207-11', 'PN20', 'SDR6',
];

/// שיטת-החיבור בקצה נתון (שלב 30) — נגזרת מסוג-הקצה.
String connectionMethodFor(ConnectorEnd end) => switch (end.type) {
      EndType.hdpeCompression => 'ריתוך-שקע (סוקט-פיוז׳ן) 260°C',
      EndType.bspMale => 'תבריג BSP חיצוני (זכר)',
      EndType.bspFemale => 'תבריג BSP פנימי (נקבה)',
      EndType.pexPress => 'Press / טבעת-כיווץ',
      EndType.copperPress => 'Press / O-ring',
      EndType.drainOpening => 'פתח-ניקוז',
    };

/// המפרט-הבַּניָה המלא של אביזר PP-R. כל השדות נגזרים; הריתוך/בטיחות = ערכי-ייחוס.
@immutable
class BuildableSpec {
  const BuildableSpec({
    required this.family,
    required this.od,
    required this.dims,
    required this.envelope,
    required this.ends,
    required this.connectionMethods,
    required this.weld,
    required this.hotLineSafety,
    required this.standards,
    this.od2,
  });

  final String family;
  final int od;
  final int? od2;
  final Map<String, double> dims; // generate()
  final Envelope? envelope; // תיבת-חוסם
  final List<ConnectorEnd> ends; // קצוות-מדויקים
  final List<String> connectionMethods; // תווית פר-קצה (שלב 30)
  final WeldParams? weld; // ערכי-ייחוס DVS (null מחוץ-לטבלה)
  final List<SafetyAdvisory> hotLineSafety; // ריק בקו-קר
  final List<String> standards; // שלב 34

  bool get isComplete =>
      dims.isNotEmpty && envelope != null && ends.isNotEmpty && standards.isNotEmpty;
}

/// המשפחות שהמנוע-הטהור יודע לגזור להן מידות.
const Set<String> _kSpecFamilies = {
  'מצמד', 'ברך 90°', 'ברך 45°', 'ברך מחותכת', 'מסעף (טי)',
  'מתאם תבריג', 'ברז כדורי', 'מצרה', 'רוכב', 'צווארון', 'פקק',
};

/// מרכיב את המפרט-הבַּניָה המלא ל-(family, od). [tempC] קובע בטיחות-קו-חם;
/// לאדפטר-תבריג [threadInch]/[threadMale] קובעים את קצה-ה-BSP. משפחה-לא-מוכרת
/// → `null` (M1). ריתוך = ערכי-ייחוס (`weldParamsFor`, null מחוץ-לטבלה).
BuildableSpec? buildableSpecFor(
  String family,
  int od, {
  int? od2,
  int tempC = 20,
  String? threadInch,
  bool? threadMale,
}) {
  if (!_kSpecFamilies.contains(family)) return null;
  final dims = generate(family, od, od2: od2);
  final ends = family == 'מתאם תבריג'
      ? ppRThreadAdapterEnds(od, threadInch: threadInch, male: threadMale)
      : (weldEndsFor(family, od) ?? const <ConnectorEnd>[]);
  return BuildableSpec(
    family: family,
    od: od,
    od2: od2,
    dims: dims,
    envelope: envelopeFor(family, od, od2: od2),
    ends: ends,
    connectionMethods: [for (final e in ends) connectionMethodFor(e)],
    weld: weldParamsFor(od), // ערכי-ייחוס בלבד (caveat נלווה ב-WeldParams)
    hotLineSafety: hotLineSafetyFor(kPprMaterial, tempC),
    standards: kPprStandards,
  );
}
