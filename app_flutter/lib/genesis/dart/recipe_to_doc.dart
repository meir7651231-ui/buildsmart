// ⚛️ אטום-Dart (דרגת-חוזה) · recipeToDoc
// מוצא: buildsmart/app_flutter/lib/data/repositories/recipe_seed.dart:27-66 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core). בונה Map רגילה
//        מקוננת (בלי Firestore/Timestamp); המחיר מושמט במכוון (מקור).
//
// אחים שהוטבעו (טיפוסי-שכן, כלל-1) — מ-smart_tree.dart, רק השדות שהפונקציה קוראת
//        (price/getters הושמטו):
//   • `SmartStage` — emoji · label · sub · isFinal · match.
//   • `SmartBrand` — name · tag · rec · sku · imageAsset.
//   • `SmartAcc`   — name · emoji · why · must · sku.
//   • `SmartProduct` — key · name · emoji · cat · brands · acc · diagramTitle · stages.
//
// קלט:  r — מוצר-חכם.
// פלט:  שדה-מפה `recipes/{key}` — brands/acc/stages מקוננים, אופציונליים רק כשקיימים.

/// טיפוס-שכן מוטבע (smart_tree.dart:5) — רק השדות הנקראים.
class SmartStage {
  const SmartStage({
    required this.emoji,
    required this.label,
    required this.sub,
    this.isFinal = false,
    this.match = const [],
  });
  final String emoji;
  final String label;
  final String sub;
  final bool isFinal;
  final List<String> match;
}

/// טיפוס-שכן מוטבע (smart_tree.dart:80) — רק השדות הנקראים.
class SmartBrand {
  const SmartBrand({
    required this.name,
    required this.tag,
    this.rec = false,
    this.sku,
    this.imageAsset,
  });
  final String name;
  final String tag;
  final bool rec;
  final String? sku;
  final String? imageAsset;
}

/// טיפוס-שכן מוטבע (smart_tree.dart:98) — רק השדות הנקראים.
class SmartAcc {
  const SmartAcc({
    required this.name,
    required this.emoji,
    required this.why,
    required this.must,
    this.sku,
  });
  final String name;
  final String emoji;
  final String why;
  final bool must;
  final String? sku;
}

/// טיפוס-שכן מוטבע (smart_tree.dart:116) — רק השדות הנקראים.
class SmartProduct {
  const SmartProduct({
    required this.key,
    required this.name,
    required this.emoji,
    required this.cat,
    required this.brands,
    required this.acc,
    this.diagramTitle = '',
    this.stages = const [],
  });
  final String key;
  final String name;
  final String emoji;
  final String cat;
  final List<SmartBrand> brands;
  final List<SmartAcc> acc;
  final String diagramTitle;
  final List<SmartStage> stages;
}

/// [SmartProduct] → שדה-מפה של `recipes/{key}` (המחיר מושמט). טהור.
Map<String, dynamic> recipeToDoc(SmartProduct r) => <String, dynamic>{
      'key': r.key,
      'name': r.name,
      'emoji': r.emoji,
      'cat': r.cat,
      'diagramTitle': r.diagramTitle,
      'brands': <Map<String, dynamic>>[
        for (final b in r.brands)
          <String, dynamic>{
            'name': b.name,
            'tag': b.tag,
            'rec': b.rec,
            if (b.sku != null) 'sku': b.sku,
            if (b.imageAsset != null) 'imageAsset': b.imageAsset,
          },
      ],
      'acc': <Map<String, dynamic>>[
        for (final a in r.acc)
          <String, dynamic>{
            'name': a.name,
            'emoji': a.emoji,
            'why': a.why,
            'must': a.must,
            if (a.sku != null) 'sku': a.sku,
          },
      ],
      'stages': <Map<String, dynamic>>[
        for (final s in r.stages)
          <String, dynamic>{
            'emoji': s.emoji,
            'label': s.label,
            'sub': s.sub,
            'isFinal': s.isFinal,
            'match': s.match,
          },
      ],
    };
