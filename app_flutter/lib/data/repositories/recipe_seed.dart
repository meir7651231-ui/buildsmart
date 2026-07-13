// RECIPE SEED (SPEC-catalog-to-server · C2.3).
//
// Migrates the work-recipes (`smart_tree.dart` `kSmartProducts`) → `recipes/{key}`,
// preserving the sku-links (each brand/accessory that has a supplier `sku` keeps it,
// so a recipe part joins the catalog by sku). A reversible serializer + a seed driven
// through the shared [FirestoreDocSink].
//
// PRICE IS DELIBERATELY OMITTED (R1-6 + owner decision: price lives only in the store
// `inventory`, never in a world-readable catalog/recipe doc). This is exactly the
// C3.5 direction — the recipe's hardcoded price ESTIMATE is dropped; a part's real
// price comes from `inventory` via its sku. So the recipe doc carries STRUCTURE only.
//
// GATING: referenced only by the gated seed + tests → tree-shakes out of OFF.

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/store_inventory.dart'
    show FirestoreDocSink;
import 'package:buildsmart/data/smart_tree.dart'
    show SmartAcc, SmartBrand, SmartProduct, SmartStage, kSmartProducts;

/// The server collection for work-recipes (C0.2).
const String kRecipesCollection = 'recipes';

/// [SmartProduct] → `recipes/{key}` field-map. Nested brands / accessories / stages,
/// each keeping its sku-link. Price omitted (see file header).
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

/// `recipes/{key}` doc → [SmartProduct]. Inverse of [recipeToDoc] (price stays null —
/// it is intentionally not stored). Tolerant to partial docs.
SmartProduct recipeFromDoc(RemoteDoc doc) {
  final j = doc.data;
  List<Map<String, dynamic>> listOf(String k) =>
      ((j[k] as List?) ?? const <dynamic>[]).cast<Map<String, dynamic>>();
  return SmartProduct(
    key: (j['key'] as String?) ?? doc.id,
    name: (j['name'] as String?) ?? '',
    emoji: (j['emoji'] as String?) ?? '',
    cat: (j['cat'] as String?) ?? '',
    diagramTitle: (j['diagramTitle'] as String?) ?? '',
    brands: <SmartBrand>[
      for (final b in listOf('brands'))
        SmartBrand(
          name: (b['name'] as String?) ?? '',
          tag: (b['tag'] as String?) ?? '',
          rec: (b['rec'] as bool?) ?? false,
          sku: b['sku'] as String?,
          imageAsset: b['imageAsset'] as String?,
        ),
    ],
    acc: <SmartAcc>[
      for (final a in listOf('acc'))
        SmartAcc(
          name: (a['name'] as String?) ?? '',
          emoji: (a['emoji'] as String?) ?? '',
          why: (a['why'] as String?) ?? '',
          must: (a['must'] as bool?) ?? false,
          sku: a['sku'] as String?,
        ),
    ],
    stages: <SmartStage>[
      for (final s in listOf('stages'))
        SmartStage(
          emoji: (s['emoji'] as String?) ?? '',
          label: (s['label'] as String?) ?? '',
          sub: (s['sub'] as String?) ?? '',
          isFinal: (s['isFinal'] as bool?) ?? false,
          match: ((s['match'] as List?) ?? const <dynamic>[]).cast<String>(),
        ),
    ],
  );
}

/// Seed all work-recipes → `recipes/{key}` (doc-id = key ⇒ idempotent). Returns count.
Future<int> seedAllRecipes(FirestoreDocSink sink) async {
  for (final r in kSmartProducts) {
    await sink(r.key, recipeToDoc(r));
  }
  return kSmartProducts.length;
}
