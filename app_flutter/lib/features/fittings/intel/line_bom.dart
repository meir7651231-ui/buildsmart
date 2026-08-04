// 🧠 מנוע-אביזרים · פאזה D slice 4 — כתב-כמויות (BOM · shopping-list). היכולת:
// עוגני-קו → `buildInstallation` (המנוע החי) → **רשימת-קנייה** (מוצר × כמות) + סה״כ-
// פריסים + פערים-לא-פתירים + מונה-תאימות-קריטית. מגודר · off-live.
//
// 🔒 טהור · `install_engine` כבר בבנייה-החיה ⇒ ייבוא לא מוסיף קוד-חי · אף מסך לא
// מייבא `intel/` ⇒ tree-shaken כשהדגל כבוי ⇒ הזרימה החיה byte-identical.
// מקורקע: `buildInstallation` (עוגנים→תוכנית · quantities/gaps/compliance קיימים).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart'
    show InstallationPlan, buildInstallation;
import 'package:flutter/foundation.dart' show immutable;

/// שורת-כתב-כמויות: מק״ט · שם · כמות (יחידות פיזיות להזמנה).
@immutable
class BomRow {
  const BomRow(this.sku, this.nameHe, this.qty);
  final String sku;
  final String nameHe;
  final int qty;
}

/// כתב-כמויות מלא של תוכנית-התקנה: שורות + סה״כ + שלמות + מונה-בטיחות-קריטית.
@immutable
class LineBom {
  const LineBom({
    required this.rows,
    required this.totalPieces,
    required this.complete,
    required this.criticalOpen,
  });

  final List<BomRow> rows;
  final int totalPieces;
  final bool complete; // אין פערים-לא-פתירים (gaps ריק)
  final int criticalOpen; // פריטי-בטיחות-קריטיים חסרים (0 = תקין)
}

/// שורות ה-BOM של תוכנית — פר-רכיב (בסדר-הופעה) עם כמותו (`qtyOf`). טהור.
List<BomRow> bomRows(InstallationPlan plan) => [
      for (final p in plan.items) BomRow(p.sku, p.nameHe, plan.qtyOf(p.sku)),
    ];

/// **היכולת** (D4): עוגנים → `buildInstallation` (מקורקע) → כתב-כמויות מלא.
/// אין זריקה (M1) — תוכנית-ריקה מחזירה BOM ריק ותקין.
LineBom lineBom(
  List<LipskeyCatalogProduct> anchors, {
  int maxDepthPerSegment = 6,
  int tempC = 20,
}) {
  final plan = buildInstallation(
    anchors,
    maxDepthPerSegment: maxDepthPerSegment,
    tempC: tempC,
  );
  return LineBom(
    rows: bomRows(plan),
    totalPieces: plan.totalPieces,
    complete: plan.isComplete,
    criticalOpen: plan.criticalOpen(tempC),
  );
}
