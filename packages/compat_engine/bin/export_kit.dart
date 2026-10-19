// Export the catalog as a kit for the general compatibility engine
// (mmmm/swarm-engine/src/kit): one row per product with verified ends, plus
// every pair this engine says connects, so the two engines can be compared.
//
//   dart run compat_engine:export_kit <catalog.csv> [<pairs.txt>]
//
// Ends are written as "<kind> <size>"; the kinds match kits/plumbing-lipskey:
// M/F = BSP male/female, C = compression socket, PEX, CU = copper press,
// D = drain opening.
import 'dart:io';

import 'package:compat_engine/data/lipskey_hotwater.dart';
import 'package:compat_engine/data/lipskey_verified_connections.dart';

const kinds = {
  EndType.bspMale: 'M',
  EndType.bspFemale: 'F',
  EndType.hdpeCompression: 'C',
  EndType.pexPress: 'PEX',
  EndType.copperPress: 'CU',
  EndType.drainOpening: 'D',
};

String csv(String s) => '"${s.replaceAll('"', '""')}"';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run compat_engine:export_kit <catalog.csv> [<pairs.txt>]');
    exit(64);
  }
  final out = StringBuffer('sku,name,category,material,ends\n');
  final specs = <String, VerifiedSpec>{};
  for (final p in chainUniverse) {
    final s = kVerifiedSpecs[p.sku];
    if (s == null || specs.containsKey(p.sku)) continue;
    specs[p.sku] = s;
    final ends = s.ends.map((e) => '${kinds[e.type]} ${e.size}').join('; ');
    out.writeln([csv(p.sku), csv(p.nameHe), csv(p.categoryHe), csv(s.material), csv(ends)].join(','));
  }
  File(args[0]).writeAsStringSync(out.toString());
  if (args.length > 1) {
    final pairs = StringBuffer();
    for (final a in specs.entries) {
      for (final b in specs.entries) {
        if (a.key != b.key && a.value.compatibleWith(b.value)) pairs.writeln('${a.key}|${b.key}');
      }
    }
    File(args[1]).writeAsStringSync(pairs.toString());
  }
  stdout.writeln('exported ${specs.length} products');
}
