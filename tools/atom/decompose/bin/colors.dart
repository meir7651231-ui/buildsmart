// atom-decompose · COLORS layer.
//
// Additive decomposition pass: inventories every hardcoded color literal across
// the screen graph and classifies it by ROLE (surface / text / border / icon /
// shadow / gradient / other), flagging the LIGHT-hardcoded SURFACES that break
// dark mode (a white/near-white background painted OVER the themed Scaffold).
//
// Pure source scan (dart:io + RegExp) — no pub deps, runs with bare `dart run`.
// Output: a per-screen COLORS.json under the atom knowledge dir + a global
// ATLAS.md work-list ranked by dark-mode offender count. Never touches the
// existing decomposer output (golden tests unaffected).
//
//   dart run tools/atom/decompose/bin/colors.dart --batch app_flutter/lib/screens
//   dart run tools/atom/decompose/bin/colors.dart --batch app_flutter/lib --out app_flutter/knowledge/colors

import 'dart:io';

/// A hardcoded color reference (a literal or a light BsTokens const) at one site.
class ColorHit {
  ColorHit(this.file, this.line, this.token, this.role, this.isLightSurface);
  final String file;
  final int line;
  final String token; // Color(0x..) · Colors.x · BsTokens.x
  final String role; // surface|text|border|icon|shadow|gradient|other
  final bool isLightSurface; // a light color used as a SURFACE ⇒ dark-mode bug
}

// Light hexes/tokens that, used as a surface, defeat dark mode.
final _lightHexes = RegExp(
  r'0x(FF)?(FFFFFF|FAFAFA|FAF8F5|F5F6FA|F5F5F5|EEEEEE|E9E2D9|FFFFFE|FDFDFD|F8F8F8|F0F0F0)',
  caseSensitive: false,
);
const _lightTokens = {
  'BsTokens.bgLight', 'BsTokens.cardLight', 'BsTokens.bgLightAlt',
  'BsTokens.surfaceMid', 'Colors.white', 'Colors.white70', 'Colors.white54',
};
final _surfaceProps = RegExp(
  r'(backgroundColor|scaffoldBackgroundColor|tileColor|cardColor|fillColor|surfaceTintColor)\s*:',
);
final _colorTok = RegExp(r'(Color\(0x[0-9A-Fa-f]{6,8}\)|Colors\.\w+|BsTokens\.\w+)');

// Container/box constructors whose `color:` is a SURFACE (page/card background).
final _boxCtor = RegExp(r'\b(Container|DecoratedBox|ColoredBox|Card|Material|BoxDecoration)\b');
// BsTokens named for backgrounds — a surface wherever they appear.
const _bgNamedTokens = {
  'BsTokens.bgLight', 'BsTokens.cardLight', 'BsTokens.bgLightAlt',
  'BsTokens.surfaceMid', 'BsTokens.bgDark', 'BsTokens.cardDark',
};

String _roleFor(String line, String token) {
  if (_surfaceProps.hasMatch(line)) return 'surface';
  // A background-named token is a surface wherever it lands (color:/Container/…).
  if (_bgNamedTokens.contains(token)) return 'surface';
  if (line.contains('TextStyle') || RegExp(r'\bhintStyle|labelStyle|\.copyWith').hasMatch(line)) return 'text';
  if (line.contains('BorderSide') || line.contains('Border.all') || line.contains('border')) return 'border';
  if (line.contains('Icon(') || line.contains('iconColor') || line.contains('checkColor')) return 'icon';
  if (line.contains('BoxShadow') || line.contains('shadow')) return 'shadow';
  if (line.contains('Gradient') || line.contains('gradient')) return 'gradient';
  // `color:` on the same line as a Container/Card/box ⇒ a background surface.
  if (RegExp(r'\bcolor\s*:').hasMatch(line) && _boxCtor.hasMatch(line)) return 'surface';
  if (RegExp(r'\bcolor\s*:').hasMatch(line)) return 'text'; // bare color: ≈ fg/text
  return 'other';
}

bool _isLight(String token) {
  if (_lightTokens.contains(token)) return true;
  return _lightHexes.hasMatch(token);
}

/// A light SURFACE that is legitimately allowed to stay a fixed light color —
/// NOT a dark-mode bug. Two cases, both principled:
///  1. Non-widget source dirs — `lib/theme/` (the theme DEFINITION: a light
///     constant there IS the source of the light theme, e.g.
///     `ColorScheme.surface: isDark ? … : white`, or a `ThemeExtension`'s
///     owner-overridable light default), and `lib/logic/` + `lib/data/` (pure
///     logic/models that render NO widget — a color constant there is a
///     reference/default value, e.g. the contrast-check baseline, never a
///     painted app-chrome background).
///  2. An explicit author opt-out inside a widget file: `// atlas:ignore` on the
///     line or the line above it — used for a genuine non-chrome surface such as
///     a signature ink-capture canvas that must stay white for the exported PNG.
bool _isExcludedSurface(String file, List<String> lines, int i) {
  final f = file.replaceAll(r'\', '/');
  for (final dir in const ['/theme/', '/logic/', '/data/']) {
    if (f.contains('lib$dir')) return true;
  }
  final here = lines[i];
  final above = i > 0 ? lines[i - 1] : '';
  return here.contains('atlas:ignore') || above.contains('atlas:ignore');
}

List<ColorHit> _scan(File f) {
  final rel = f.path.replaceFirst(RegExp(r'^\./'), '');
  final hits = <ColorHit>[];
  final lines = f.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trimLeft().startsWith('//')) continue; // skip comments
    if (!_colorTok.hasMatch(line)) continue;
    // Multi-line box context: a Container/Card/BoxDecoration opened in the prior
    // ~2 lines makes a bare `color:` here a background surface.
    final prior = (i >= 2 ? lines[i - 2] : '') + '\n' + (i >= 1 ? lines[i - 1] : '');
    final boxCtx = _boxCtor.hasMatch(prior);
    final effLine = boxCtx ? '$line Container' : line; // hint _roleFor
    for (final m in _colorTok.allMatches(line)) {
      final tok = m.group(1)!;
      final role = _roleFor(effLine, tok);
      final offender = role == 'surface' &&
          _isLight(tok) &&
          !_isExcludedSurface(rel, lines, i);
      hits.add(ColorHit(rel, i + 1, tok, role, offender));
    }
  }
  return hits;
}

void main(List<String> argv) {
  final args = List<String>.from(argv);
  String? optOf(String flag) {
    final i = args.indexOf(flag);
    return (i >= 0 && i + 1 < args.length) ? args[i + 1] : null;
  }

  final batchDir = optOf('--batch');
  final out = optOf('--out') ?? 'app_flutter/knowledge/colors';
  if (batchDir == null) {
    stderr.writeln('usage: colors.dart --batch <dir> [--out <dir>]');
    exit(2);
  }
  final dir = Directory(batchDir);
  if (!dir.existsSync()) {
    stderr.writeln('colors: dir not found: $batchDir');
    exit(2);
  }

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final perScreen = <String, List<ColorHit>>{};
  var total = 0, lightSurface = 0;
  final roleCounts = <String, int>{};
  for (final f in files) {
    final hits = _scan(f);
    if (hits.isEmpty) continue;
    perScreen[f.path] = hits;
    total += hits.length;
    for (final h in hits) {
      roleCounts[h.role] = (roleCounts[h.role] ?? 0) + 1;
      if (h.isLightSurface) lightSurface++;
    }
  }

  // Rank screens by dark-mode offenders (light surfaces), then total.
  final ranked = perScreen.entries.toList()
    ..sort((a, b) {
      final ao = a.value.where((h) => h.isLightSurface).length;
      final bo = b.value.where((h) => h.isLightSurface).length;
      if (ao != bo) return bo - ao;
      return b.value.length - a.value.length;
    });

  final outDir = Directory(out)..createSync(recursive: true);
  final md = StringBuffer()
    ..writeln('# Color Atlas — dark-mode decomposition (auto-generated)')
    ..writeln()
    ..writeln('Scanned **${files.length}** files · **${perScreen.length}** carry colors.')
    ..writeln()
    ..writeln('- **$total** hardcoded color references total')
    ..writeln('- **$lightSurface** LIGHT-hardcoded SURFACES ⇒ the dark-mode offenders (a white bg painted over the themed Scaffold)')
    ..writeln('- by role: ${(roleCounts.entries.toList()..sort((a, b) => b.value - a.value)).map((e) => '${e.key}=${e.value}').join(' · ')}')
    ..writeln()
    ..writeln('## Work-list — screens ranked by dark-mode offenders (fix top-down)')
    ..writeln()
    ..writeln('| screen | light-surfaces | total colors |')
    ..writeln('|---|---|---|');
  for (final e in ranked) {
    final off = e.value.where((h) => h.isLightSurface).length;
    if (off == 0) continue;
    final name = e.key.split('/').last;
    md.writeln('| `$name` | **$off** | ${e.value.length} |');
  }
  md
    ..writeln()
    ..writeln('## Offender sites (light surfaces, file:line → token)')
    ..writeln();
  for (final e in ranked) {
    final offenders = e.value.where((h) => h.isLightSurface).toList();
    if (offenders.isEmpty) continue;
    md.writeln('### ${e.key}');
    for (final h in offenders) {
      md.writeln('- `${h.file}:${h.line}` · `${h.token}`');
    }
    md.writeln();
  }
  File('${outDir.path}/ATLAS.md').writeAsStringSync(md.toString());

  stdout.writeln('colors: ${files.length} files scanned · ${perScreen.length} with colors');
  stdout.writeln('colors: $total refs · $lightSurface LIGHT-SURFACE offenders (dark-mode bugs)');
  stdout.writeln('colors: roles → ${(roleCounts.entries.toList()..sort((a, b) => b.value - a.value)).map((e) => '${e.key}=${e.value}').join(' · ')}');
  stdout.writeln('colors: wrote ${outDir.path}/ATLAS.md');
  stdout.writeln('');
  stdout.writeln('TOP 15 screens to fix (by light-surface offenders):');
  var shown = 0;
  for (final e in ranked) {
    final off = e.value.where((h) => h.isLightSurface).length;
    if (off == 0) continue;
    stdout.writeln('  ${off.toString().padLeft(3)}  ${e.key.split('/').last}');
    if (++shown >= 15) break;
  }
}
