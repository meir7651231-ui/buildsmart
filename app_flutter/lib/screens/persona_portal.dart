import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/store_stock.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared persona-portal tiles for the 🏪 store + 🛵 courier role-apps
/// (proto 06 §2.8 `renderStorePortal` [L20760] + §3.5 `openCourierPortal`
/// [L20786]). Tiles whose data the prototype exposes verbatim (§7 ratings /
/// zones / bulk tiers / fleet) open an info sheet with that data, and the
/// auto-stock tile shows the LIVE out-of-stock products (the supplier's
/// [storeOosProvider] set, shared with the store dashboard's מלאי tab); the
/// remaining action-only tools (barcode, nav, POD, chat) show an honest
/// "to be wired" line rather than faking a feature (R8 — no invention).

enum PortalKind {
  ratings,
  sla,
  zones,
  bulk,
  barcode,
  fleet,
  chatContractor,
  autoStock,
  nav,
  pod,
  chatStore,
}

class PortalTileData {
  const PortalTileData(this.title, this.sub, this.kind);
  final String title;
  final String sub;
  final PortalKind kind;
}

/// 🏪 supplier portal — 8 tiles (proto §2.8 [L20763], verbatim title / subtitle).
const List<PortalTileData> kStorePortalTiles = [
  PortalTileData('⭐ דירוג ספקים', 'ציון וביצועים', PortalKind.ratings),
  PortalTileData('⏱️ מעקב SLA', 'זמני אספקה', PortalKind.sla),
  PortalTileData('🗺️ אזורי הפצה', 'מפת אזורים', PortalKind.zones),
  PortalTileData('📉 הנחות כמות', 'מדרגות הנחה', PortalKind.bulk),
  PortalTileData('🏷️ הפקת ברקודים', 'תוויות למוצרים', PortalKind.barcode),
  PortalTileData('🚛 ניהול צי רכב', 'רכבים וזמינות', PortalKind.fleet),
  PortalTileData('💬 צ׳אט עם קבלן', 'הודעות פנימיות', PortalKind.chatContractor),
  PortalTileData('🔄 עדכון מלאי', 'אוטומטי לפי מכירות', PortalKind.autoStock),
];

/// 🛵 courier portal — 6 tiles (proto §3.5 [L20786], verbatim title / subtitle).
const List<PortalTileData> kCourierPortalTiles = [
  PortalTileData('🧭 ניווט למשלוח', 'מסלול לאתר', PortalKind.nav),
  PortalTileData('🚛 צי רכב', 'רכבים וזמינות', PortalKind.fleet),
  PortalTileData('⏱️ מעקב SLA', 'זמני אספקה', PortalKind.sla),
  PortalTileData('🗺️ אזורי הפצה', 'מפת אזורים', PortalKind.zones),
  PortalTileData('📸 אישור מסירה', 'POD + צילום', PortalKind.pod),
  PortalTileData('💬 צ׳אט עם חנות', 'הודעות פנימיות', PortalKind.chatStore),
];

/// A single square portal tile (used in both grids).
class PortalTileButton extends StatelessWidget {
  const PortalTileButton({
    required this.title,
    required this.sub,
    required this.onTap,
    super.key,
  });

  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens a portal as a grid of [tiles] in a bottom sheet (the courier's
/// "פורטל השליח" button). Each tile then opens its own [showPortalSheet].
void showPersonaPortalGrid(
  BuildContext context,
  String head,
  List<PortalTileData> tiles,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              head,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: BsTokens.space3,
              crossAxisSpacing: BsTokens.space3,
              childAspectRatio: 1.5,
              children: [
                for (final t in tiles)
                  PortalTileButton(
                    title: t.title,
                    sub: t.sub,
                    onTap: () => showPortalSheet(context, t),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Opens the info sheet for [tile]. Tall content scrolls (isScrollControlled +
/// SingleChildScrollView) so it never clips.
void showPortalSheet(BuildContext context, PortalTileData tile) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: _PortalSheet(tile: tile),
    ),
  );
}

class _PortalSheet extends ConsumerWidget {
  const _PortalSheet({required this.tile});
  final PortalTileData tile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tile.title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tile.sub,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space4),
            ..._content(ref),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(WidgetRef ref) {
    switch (tile.kind) {
      case PortalKind.ratings:
        return [
          for (final r in kSupplierRatings)
            _row('⭐ ${r.score} · ${r.orders} הזמנות · ${r.onTime}% בזמן'),
        ];
      case PortalKind.zones:
        return [
          for (final z in kDistZones)
            _row('${z.name} · ${z.eta} · משלוח ${fMoney(z.fee)}'),
        ];
      case PortalKind.sla:
        return [
          for (final z in kDistZones) _row('${z.name} · יעד אספקה: ${z.eta}'),
        ];
      case PortalKind.bulk:
        return [
          for (final t in kBulkTiers) _row('${t.min}+ יח׳ · ${t.discount}% הנחה'),
        ];
      case PortalKind.fleet:
        return [
          for (final v in kFleet)
            _row('${v.name} · ${v.cap} · ${v.status} · נהג ${v.driver}'),
        ];
      case PortalKind.autoStock:
        // Live out-of-stock list — the supplier's [storeOosProvider] set, the
        // same source the store dashboard's מלאי tab toggles.
        final oos = ref.watch(storeOosProvider).toList()..sort();
        if (oos.isEmpty) {
          return [_row('✓ כל המוצרים זמינים במלאי')];
        }
        return [
          _row('⚠️ ${oos.length} מוצרים אזלו מהמלאי'),
          for (final name in oos) _row('❌ $name'),
        ];
      case PortalKind.barcode:
      case PortalKind.chatContractor:
      case PortalKind.nav:
      case PortalKind.pod:
      case PortalKind.chatStore:
        return [_row('${tile.sub} — כלי זה יחובר בהמשך הפיתוח.')];
    }
  }

  Widget _row(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
      ),
    ),
  );
}
