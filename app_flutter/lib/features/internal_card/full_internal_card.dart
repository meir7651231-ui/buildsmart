// ─────────────────────────────────────────────────────────────────────────────
// THE FULL INTERNAL PRODUCT CARD ("כרטיס-מוצר פנימי · הכי מורחב · המנוע חשוף").
// Renders up to 13 data sections for a fitting product, EACH wired to an existing
// engine function and shown ONLY when that engine returns data (R8 · no invention —
// SmartLock has no VerifiedSpec ⇒ compat/price are empty/null ⇒ those sections hide).
// Layout + palette are a 1:1 port of knowledge/internal-card mockup card-max-internal.
//
// Wiring (SSOT: knowledge/internal-card/WIRING-SSOT.md):
//   header      → typeEmoji · nameHe · sku · dims(DN/t) · brand
//   🎛️ הגדרה     → wheel axes label (קוטר · זווית · אורך · כמות)
//   🧩 וריאנטים   → variantSiblingsCountFor / variantSiblingsOf
//   🔗 מתחבר ל־   → compatibleProductsFor            (empty ⇒ hidden)
//   🔩 הוראות-חיבור→ engineeringSpecFor.endsSummary
//   🛠️ שלבי התקנה → installTipsFor
//   🧰 ערכת אביזרים→ installKitFor + recommendedKitForProduct
//   🧱 מפרט חומרים → engineeringSpecFor.material (+ endsSummary)
//   📐 מפרט הנדסי  → engineeringSpecFor (dn/di/PN/system)
//   🌡️ טמפרטורה    → engineeringSpecFor.maxTempC
//   📋 תקינות      → complianceTriggersFor
//   ⚠️ אזהרות      → systemSafetyNoteHe / connectionWarningHe
//   🧩 משלימים     → frequentlyPairedTypesFor
//   💰 הערכת מחיר  → priceFor + formatCatalogPrice    (null ⇒ hidden)
//   ＋ הוסף לסל    → priceFor (else plain label)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── palette (exact card-max-internal hexes) ──────────────────────────────────
const Color _cCard = Color(0xFFFFFFFF);
const Color _cInk = Color(0xFF232A33);
const Color _cDim = Color(0xFF7A828D);
const Color _cLine = Color(0xFFE9ECF1);
const Color _cAccent = Color(0xFFEE6A2A);
const Color _cAccentD = Color(0xFFCF551B);
const Color _cImgBg = Color(0xFFF4F6F9);
const Color _cWarn = Color(0xFFC0392B);
const Color _cSecBorder = Color(0xFFE3E7EC);
const Color _cBody = Color(0xFF48505A);
const Color _cHotBg = Color(0xFFFFF2EA);
const Color _cHotBorder = Color(0xFFFFD6BD);

/// THE full internal card. Give it a [product]; it renders every section the
/// engine can populate for that product. Reusable (any fitting SKU); the home
/// embed + standalone route both seed it with the SmartLock elbow hero.
class FullInternalCard extends ConsumerWidget {
  const FullInternalCard({required this.product, super.key});

  /// The default hero — SmartLock ברך 90° 50 (real SKU; mockup's 120050 is not
  /// in the catalog). Resolved via [catalogProductForSku].
  static const String heroSku = '70055960';

  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    final p = product;

    final sections = <Widget>[
      _header(p),
      ..._configSection(),
      ..._variantsSection(p),
      ..._connectsSection(p),
      ..._connectionInstructionsSection(p),
      ..._installStepsSection(p),
      ..._kitSection(p),
      ..._materialsSection(p),
      ..._engSpecSection(p),
      ..._temperatureSection(p),
      ..._complianceSection(p),
      ..._warningsSection(p),
      ..._complementsSection(p),
      ..._priceSection(p, settings),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _cCard),
        child: Column(
          key: const Key('fullInternalCard'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...sections,
            _buyButton(p, settings),
          ],
        ),
      ),
    );
  }

  // ── header ──────────────────────────────────────────────────────────────────
  Widget _header(LipskeyCatalogProduct p) {
    final dims = p.dims ?? const <String, dynamic>{};
    final dn = (dims['DN'] ?? '').toString();
    final di = (dims['t'] ?? '').toString();
    final metaParts = <String>[
      'SKU ${p.sku}',
      if (dn.isNotEmpty) 'dn נומינלי $dn',
      if (di.isNotEmpty) 'di קוטר פנימי $di',
      'מותג ${p.brand}',
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      color: _cCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _cImgBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(p.typeEmoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.nameHe,
                  key: const Key('internalCardName'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _cInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metaParts.join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: _cDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── section shell (6px top border · title row · body) ────────────────────────
  Widget _section({
    required String icon,
    required String title,
    required Widget child,
    String? count,
    bool warn = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _cCard,
        border: Border(top: BorderSide(color: _cSecBorder, width: 6)),
      ),
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: warn ? _cWarn : _cAccentD,
                  ),
                ),
              ),
              if (count != null) _countBadge(count),
            ],
          ),
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 11,
              color: _cBody,
              height: 1.55,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _countBadge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: _cAccent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _miniChip(String text, {bool hot = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: hot ? _cHotBg : _cImgBg,
          border: Border.all(color: hot ? _cHotBorder : _cLine),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9.5,
            color: hot ? _cAccentD : const Color(0xFF5A636E),
            fontWeight: hot ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      );

  // ── 1 · הגדרה (wheels label) ─────────────────────────────────────────────────
  List<Widget> _configSection() => [
        _section(
          icon: '🎛️',
          title: 'הגדרה',
          count: 'גלגלים',
          child: const Text('קוטר · זווית · אורך · כמות'),
        ),
      ];

  // ── 2 · variants ─────────────────────────────────────────────────────────────
  List<Widget> _variantsSection(LipskeyCatalogProduct p) {
    final count = variantSiblingsCountFor(p);
    if (count <= 1) return const [];
    final sibs = variantSiblingsOf(p);
    final labels = <String>[];
    for (final s in sibs.take(6)) {
      final sig = (s.dims?['סימון'] ?? s.dims?['DN'] ?? '').toString();
      labels.add(sig.isNotEmpty ? sig : s.nameHe);
    }
    return [
      _section(
        icon: '🧩',
        title: 'וריאנטים',
        count: '$count',
        child: Text('${labels.join(' · ')}${sibs.length > 6 ? '...' : ''}'),
      ),
    ];
  }

  // ── 3 · what connects (per-product; empty for SmartLock) ─────────────────────
  List<Widget> _connectsSection(LipskeyCatalogProduct p) {
    final mates = compatibleProductsFor(p);
    if (mates.isEmpty) return const [];
    final dn = p.connectionSizes.isNotEmpty ? p.connectionSizes.first : '';
    return [
      _section(
        icon: '🔗',
        title: 'מתחבר ל־',
        count: '${mates.length}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dn.isNotEmpty) Text('מה שמתחבר למידה $dn:'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < mates.take(8).length; i++)
                  _miniChip(mates[i].nameHe, hot: i == 0),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // ── 4 · connection instructions (ends summary) ───────────────────────────────
  List<Widget> _connectionInstructionsSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    final ends = spec?.endsSummary ?? '';
    if (ends.isEmpty) return const [];
    return [
      _section(
        icon: '🔩',
        title: 'הוראות-חיבור',
        child: Text(ends),
      ),
    ];
  }

  // ── 5 · install steps (tips) ─────────────────────────────────────────────────
  List<Widget> _installStepsSection(LipskeyCatalogProduct p) {
    final tips = installTipsFor(p);
    if (tips.isEmpty) return const [];
    return [
      _section(
        icon: '🛠️',
        title: 'שלבי התקנה',
        count: '${tips.length}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tips.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('${i + 1}. ${tips[i]}'),
              ),
          ],
        ),
      ),
    ];
  }

  // ── 6 · install kit ──────────────────────────────────────────────────────────
  List<Widget> _kitSection(LipskeyCatalogProduct p) {
    final kit = installKitFor(p);
    if (kit == null) return const [];
    final items = recommendedKitForProduct(p);
    final parts = <String>[
      if (kit.must > 0) '${kit.must} חובה',
      if (kit.optional > 0) '${kit.optional} אופציה',
      if (kit.tools > 0) '${kit.tools} כלים',
    ];
    if (parts.isEmpty) return const [];
    return [
      _section(
        icon: '🧰',
        title: 'ערכת אביזרים',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(parts.join(' · ')),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [for (final it in items.take(6)) _miniChip(it.label)],
              ),
            ],
          ],
        ),
      ),
    ];
  }

  // ── 7 · materials ────────────────────────────────────────────────────────────
  List<Widget> _materialsSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    if (spec == null || spec.material.isEmpty) return const [];
    return [
      _section(
        icon: '🧱',
        title: 'מפרט חומרים',
        child: Text(spec.material),
      ),
    ];
  }

  // ── 8 · engineering spec ─────────────────────────────────────────────────────
  List<Widget> _engSpecSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    if (spec == null) return const [];
    final di = (p.dims?['t'] ?? '').toString();
    final parts = <String>[
      if (spec.minBoreMm != null) 'dn ${spec.minBoreMm!.round()}',
      if (di.isNotEmpty) 'di $di',
      if (spec.pressureRating != null) spec.pressureRating!,
      if (spec.waterSystem.isNotEmpty) spec.waterSystem,
    ];
    if (parts.isEmpty) return const [];
    return [
      _section(
        icon: '📐',
        title: 'מפרט הנדסי',
        child: Text(parts.join(' · ')),
      ),
    ];
  }

  // ── 9 · temperature ──────────────────────────────────────────────────────────
  List<Widget> _temperatureSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    if (spec == null || spec.maxTempC <= 0) return const [];
    return [
      _section(
        icon: '🌡️',
        title: 'טמפרטורה',
        child: Text('עד ${spec.maxTempC.round()}°C'),
      ),
    ];
  }

  // ── 10 · compliance / standards ──────────────────────────────────────────────
  List<Widget> _complianceSection(LipskeyCatalogProduct p) {
    final items = complianceTriggersFor(p);
    if (items.isEmpty) return const [];
    return [
      _section(
        icon: '📋',
        title: 'דרישות תקינות',
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [for (final it in items.take(8)) _miniChip(it.label)],
        ),
      ),
    ];
  }

  // ── 11 · warnings ────────────────────────────────────────────────────────────
  List<Widget> _warningsSection(LipskeyCatalogProduct p) {
    final notes = <String>[];
    final safety = systemSafetyNoteHe(p);
    if (safety != null && safety.isNotEmpty) notes.add(safety);
    final connWarn = connectionWarningHe(p);
    if (connWarn != null && connWarn.isNotEmpty) notes.add(connWarn);
    if (notes.isEmpty) return const [];
    return [
      _section(
        icon: '⚠️',
        title: 'אזהרות',
        warn: true,
        child: Text(notes.join(' · ')),
      ),
    ];
  }

  // ── 12 · complementary products ──────────────────────────────────────────────
  List<Widget> _complementsSection(LipskeyCatalogProduct p) {
    final paired = frequentlyPairedTypesFor(p);
    if (paired.isEmpty) return const [];
    return [
      _section(
        icon: '🧩',
        title: 'אביזרים משלימים',
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [for (final t in paired.take(6)) _miniChip(t)],
        ),
      ),
    ];
  }

  // ── 13 · price estimate ──────────────────────────────────────────────────────
  List<Widget> _priceSection(LipskeyCatalogProduct p, CatalogSettings s) {
    final base = priceFor(p);
    if (base == null) return const [];
    return [
      _section(
        icon: '💰',
        title: 'הערכת מחיר',
        child: Text('הערכה לפי קטגוריה · ${formatCatalogPrice(base, s)}'),
      ),
    ];
  }

  // ── buy button ───────────────────────────────────────────────────────────────
  Widget _buyButton(LipskeyCatalogProduct p, CatalogSettings s) {
    final base = priceFor(p);
    final label = base == null
        ? '＋ הוסף לסל'
        : '＋ הוסף לסל · ${formatCatalogPrice(base, s)}';
    return Container(
      margin: const EdgeInsets.fromLTRB(13, 11, 13, 13),
      child: Material(
        key: const Key('internalCardBuy'),
        color: _cAccent,
        borderRadius: BorderRadius.circular(11),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
