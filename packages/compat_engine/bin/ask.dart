// Ask the compatibility engine questions in JSON, get answers in JSON.
//
//   echo '{"op":"check","chain":["217861","116632"]}' | dart run compat_engine:ask
//   echo '{"ops":[{"op":"search","q":"סיפון לכיור 1.25"}, ...]}' | dart run compat_engine:ask
//
// One process answers a whole batch (`ops`), so callers pay the startup once.
// Ops:
//   search      {q, limit?}            products whose name matches the words/sizes in q
//   candidates  {q, perWord?, limit?}  a few products for each part named in q
//   product     {sku}                  one product
//   compatible  {sku, limit?, tempC?}  what connects to it
//   check       {chain: [sku...], tempC?}
//               each neighbouring pair: connects? how? why not? and the
//               shortest bridge of real products when it doesn't; the install
//               kit when the whole chain connects; parts that can't take the
//               line's temperature (tempProblems).
import 'dart:convert';
import 'dart:io';

import 'package:compat_engine/data/lipskey_catalog.dart';
import 'package:compat_engine/data/lipskey_hotwater.dart';
import 'package:compat_engine/data/lipskey_verified_connections.dart';
import 'package:compat_engine/logic/install_engine.dart';
import 'package:compat_engine/logic/install_kit.dart';

// Verified ends: VerifiedSpec / ConnectorEnd come with lipskey_verified_connections.

final Map<String, LipskeyCatalogProduct> _bySku = {
  for (final p in chainUniverse) p.sku: p,
};

Map<String, Object?> productJson(LipskeyCatalogProduct p) => {
      'sku': p.sku,
      'name': p.nameHe,
      'category': p.categoryHe,
      'brand': p.brand,
      'sizes': p.connectionSizes,
      'verified': kVerifiedSpecs.containsKey(p.sku),
      'maxTemp': productMaxTempC(p),
    };

const _stop = {
  'את', 'של', 'עם', 'על', 'לא', 'מה', 'צריך', 'צריכה', 'אני', 'יש', 'זה',
  'לחבר', 'חיבור', 'לקנות', 'רוצה', 'איך', 'או', 'גם', 'כל', 'בין', 'אל',
};
const _prefixes = 'הלבומשכ';

final _inch = RegExp(r'''(\d+(?:\.\d+)?)\s*(?:"|''|״|אינץ|צול)''');
final _dn = RegExp(r'DN\s?(\d+)', caseSensitive: false);
final _num = RegExp(r'\b(\d{2,3})\b');
final _frac = RegExp(r'\b(\d/\d)\b');

/// Words and sizes asked for. Sizes are matched against the product's
/// connection sizes as well as its name.
({List<String> words, Set<String> sizes}) parseQuery(String q) {
  final sizes = <String>{
    for (final m in _inch.allMatches(q)) m.group(1)!,
    for (final m in _dn.allMatches(q)) m.group(1)!,
    for (final m in _frac.allMatches(q)) m.group(1)!,
  };
  final rest = q.replaceAll(_inch, ' ').replaceAll(_dn, ' ').replaceAll(_frac, ' ');
  sizes.addAll(_num.allMatches(rest).map((m) => m.group(1)!));
  final words = RegExp(r'[א-ת]{2,}|[A-Za-z]{3,}')
      .allMatches(rest)
      .map((m) => m.group(0)!)
      .where((w) => !_stop.contains(w))
      .toList();
  return (words: words, sizes: sizes);
}

bool _hasWord(String name, String w) {
  if (name.toLowerCase().contains(w.toLowerCase())) return true;
  // "לכיור" → "כיור": one Hebrew prefix letter.
  return w.length > 3 && _prefixes.contains(w[0]) && name.contains(w.substring(1));
}

/// "1/2" in "×1/2\"" but not in "11/2"; "32" in "32×25" but not in "320".
bool _hasSize(String name, String s) =>
    RegExp('(?<![\\d./])${RegExp.escape(s)}(?![\\d/])').hasMatch(name);

List<Map<String, Object?>> search(String q, int limit) {
  final query = parseQuery(q);
  final scored = <(int, LipskeyCatalogProduct)>[];
  for (final p in chainUniverse) {
    final words = query.words.where((w) => _hasWord(p.nameHe, w)).length;
    if (words == 0) continue;
    final sizes = query.sizes
        .where((s) => p.connectionSizes.contains(s) || _hasSize(p.nameHe, s))
        .length;
    if (query.sizes.isNotEmpty && sizes == 0) continue;
    final verified = kVerifiedSpecs.containsKey(p.sku) ? 1 : 0;
    scored.add((words * 10 + sizes * 15 + verified, p));
  }
  scored.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final s in scored.take(limit)) productJson(s.$2)];
}

/// Parts for a request in free text: the best few for each word asked about
/// (with the sizes asked about), so a request naming a pipe, an adapter and a
/// tap gets all three kinds, not ten couplings.
List<Map<String, Object?>> candidates(String q, int perWord, int limit) {
  final query = parseQuery(q);
  final sizes = query.sizes.join(' ');
  final seen = <String>{};
  final out = <Map<String, Object?>>[];
  void add(Iterable<Map<String, Object?>> ps) {
    for (final p in ps) {
      if (out.length >= limit) return;
      if (seen.add(p['sku'] as String)) out.add(p);
    }
  }

  for (final w in query.words) {
    add(search('$w $sizes', perWord));
  }
  add(search(q, limit));
  return out;
}

bool _mates(VerifiedSpec a, ConnectorEnd ea, VerifiedSpec b, ConnectorEnd eb) =>
    VerifiedSpec(sku: a.sku, ends: [ea], material: a.material)
        .compatibleWith(VerifiedSpec(sku: b.sku, ends: [eb], material: b.material));

/// Which ends of each part can take the previous part, when every end joins at
/// most one neighbour (the pairwise check alone would let a two-ended adapter
/// use the same end on both sides). Index i holds the ends of chain[i] that the
/// walk can arrive on; {-1} = the first part (nothing arrives), null = a part
/// without verified ends (not tracked). An empty set = the walk is stuck there.
List<Set<int>?> endWalk(List<LipskeyCatalogProduct> chain) {
  final out = <Set<int>?>[];
  for (var i = 0; i < chain.length; i++) {
    final spec = kVerifiedSpecs[chain[i].sku];
    if (i == 0 || spec == null) {
      out.add(spec == null ? null : {-1});
      continue;
    }
    final prev = kVerifiedSpecs[chain[i - 1].sku];
    final arrivedPrev = out[i - 1];
    if (prev == null || arrivedPrev == null) {
      out.add({for (var z = 0; z < spec.ends.length; z++) z});
      continue;
    }
    out.add({
      if (arrivedPrev.isNotEmpty)
        for (var z = 0; z < spec.ends.length; z++)
          if (arrivedPrev.any((x) => [
                for (var y = 0; y < prev.ends.length; y++)
                  if (y != x) y,
              ].any((y) => _mates(prev, prev.ends[y], spec, spec.ends[z]))))
            z,
    });
  }
  return out;
}

/// Real parts that join [a] (arrived on one of [arrived]) to [b]: one part if
/// possible, else two. Only two-ended parts: a tee or a manifold would leave an
/// open port on the line.
List<LipskeyCatalogProduct>? endBridge(
    LipskeyCatalogProduct a, Set<int> arrived, LipskeyCatalogProduct b, int tempC) {
  final sa = kVerifiedSpecs[a.sku], sb = kVerifiedSpecs[b.sku];
  if (sa == null || sb == null || arrived.isEmpty) return null;
  final freeA = <ConnectorEnd>{
    for (final x in arrived)
      for (var y = 0; y < sa.ends.length; y++)
        if (y != x) sa.ends[y],
  };
  final parts = [
    for (final p in chainUniverse)
      if (p.sku != a.sku &&
          p.sku != b.sku &&
          kVerifiedSpecs[p.sku]?.ends.length == 2 &&
          productSuitableForTemp(p, tempC))
        p,
  ]..sort((x, y) => (isFitting(x) ? 0 : 1).compareTo(isFitting(y) ? 0 : 1)); // fittings first: a nipple, not a shower arm
  // The end of each part left free after joining the side it came from.
  List<(LipskeyCatalogProduct, ConnectorEnd)> from(
          VerifiedSpec s, Iterable<ConnectorEnd> ends) =>
      [
        for (final p in parts)
          for (var i = 0; i < 2; i++)
            if (ends.any((e) => _mates(s, e, kVerifiedSpecs[p.sku]!, kVerifiedSpecs[p.sku]!.ends[i])))
              (p, kVerifiedSpecs[p.sku]!.ends[1 - i]),
      ];
  bool reachesB(LipskeyCatalogProduct p, ConnectorEnd e) =>
      sb.ends.any((z) => _mates(kVerifiedSpecs[p.sku]!, e, sb, z));

  final first = from(sa, freeA);
  for (final (p, e) in first) {
    if (reachesB(p, e)) return [p];
  }
  for (final (p, e) in first) {
    for (final (q, f) in from(kVerifiedSpecs[p.sku]!, [e])) {
      if (q.sku != p.sku && reachesB(q, f)) return [p, q];
    }
  }
  return null;
}

Map<String, Object?> check(List<String> skus, int tempC) {
  final unknown = [for (final s in skus) if (!_bySku.containsKey(s)) s];
  final chain = [for (final s in skus) if (_bySku[s] != null) _bySku[s]!];
  final pairs = <Map<String, Object?>>[];
  for (var i = 0; i < chain.length - 1; i++) {
    final a = chain[i], b = chain[i + 1];
    final ok = canConnect(a, b);
    final pair = <String, Object?>{'from': a.sku, 'to': b.sku, 'connects': ok};
    if (ok) {
      pair['method'] = connectionMethodLabel(a, b);
    } else {
      pair['reason'] = connectionFailReason(a, b);
      final path = findShortestPath(a, b, tempC: tempC);
      pair['bridge'] = path == null || path.length < 3
          ? null
          : [for (final p in path.sublist(1, path.length - 1)) productJson(p)];
    }
    pairs.add(pair);
  }
  // Second pass: each end joins one neighbour only.
  final walk = endWalk(chain);
  for (var i = 0; i < pairs.length; i++) {
    final arrivedB = walk[i + 1];
    if (arrivedB == null || walk[i] == null || arrivedB.isNotEmpty) continue;
    final pair = pairs[i];
    if (pair['connects'] == true) {
      pair
        ..['connects'] = false
        ..['endConflict'] = true
        ..remove('method')
        ..['reason'] = 'הקצה של ${chain[i].nameHe} שמתאים לחלק הבא כבר תפוס בחיבור לחלק הקודם';
    }
    final bridge = endBridge(chain[i], walk[i]!, chain[i + 1], tempC);
    pair['bridge'] = bridge == null ? null : [for (final p in bridge) productJson(p)];
    break; // past a dead end the walk says nothing; fix this one and ask again
  }
  final allConnect = unknown.isEmpty && pairs.every((p) => p['connects'] == true);
  final tempProblems = [
    for (final p in chain)
      if (!productSuitableForTemp(p, tempC)) {'sku': p.sku, 'name': p.nameHe, 'maxTemp': productMaxTempC(p)},
  ];
  return {
    'tempC': tempC,
    'tempProblems': tempProblems,
    'unknown': unknown,
    'products': [for (final p in chain) productJson(p)],
    'pairs': pairs,
    'allConnect': allConnect,
    'kit': allConnect
        ? [
            for (final k in recommendedKitFor(chain))
              {'label': k.label, 'reason': k.reason, 'severity': k.severityHe},
          ]
        : const [],
  };
}

Object? answer(Map<String, Object?> op) {
  final limit = (op['limit'] as num?)?.toInt() ?? 8;
  final tempC = (op['tempC'] as num?)?.toInt() ?? 20;
  switch (op['op']) {
    case 'search':
      return search('${op['q'] ?? ''}', limit);
    case 'candidates':
      final perWord = (op['perWord'] as num?)?.toInt() ?? 3;
      return candidates('${op['q'] ?? ''}', perWord, (op['limit'] as num?)?.toInt() ?? 15);
    case 'product':
      final p = _bySku['${op['sku']}'];
      return p == null ? null : productJson(p);
    case 'compatible':
      final p = _bySku['${op['sku']}'];
      if (p == null) return {'error': 'unknown sku ${op['sku']}'};
      return [for (final c in compatibleWith(p, tempC: tempC).take(limit)) productJson(c)];
    case 'check':
      return check([for (final s in (op['chain'] as List? ?? const [])) '$s'], tempC);
    default:
      return {'error': 'unknown op ${op['op']}'};
  }
}

Future<void> main(List<String> args) async {
  final input = args.isNotEmpty ? args.join(' ') : await stdin.transform(utf8.decoder).join();
  final req = jsonDecode(input) as Map<String, Object?>;
  Object? safe(Map<String, Object?> op) {
    try {
      return answer(op);
    } catch (e) {
      return {'error': '$e'};
    }
  }

  final ops = req['ops'] as List?;
  final out = ops == null
      ? safe(req)
      : [for (final op in ops) safe((op as Map).cast<String, Object?>())];
  stdout.writeln(jsonEncode(out));
}
