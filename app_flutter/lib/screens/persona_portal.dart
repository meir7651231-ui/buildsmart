import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/store_stock.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared persona-portal tiles for the 🏪 store + 🛵 courier role-apps
/// (proto 06 §2.8 `renderStorePortal` [L20760] + §3.5 `openCourierPortal`
/// [L20786]). Tiles whose data the prototype exposes verbatim (§7 ratings /
/// zones / bulk tiers / fleet) open an info sheet with that data, and the
/// auto-stock tile shows the LIVE out-of-stock products (the supplier's
/// [storeOosProvider] set, shared with the store dashboard's מלאי tab); the 💬
/// chat tiles open the shared cross-persona [ChatsScreen] for the portal's active
/// persona (🏪 store / 🛵 courier — CH-4); and the remaining action-only tools
/// (barcode, nav, POD) show an honest "to be wired" line rather than faking a
/// feature (R8 — no invention).
///
/// #74 — the 🛵 courier board no longer opens this grid as a dialog: its portal
/// is a TAB (`CourierPortalTab`, courier_portal_tab.dart) that reuses
/// [kCourierPortalTiles] + [PortalTileButton] but wires each tile for real
/// (POD → PersonaPodSheet · nav/SLA → SERVER-READY sheets · fleet/zones →
/// seeded local sheets · chat → audience:'courier'). The nav/pod branches in
/// the sheet below remain only as the honest legacy fallback.

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
      color: Theme.of(context).colorScheme.surface,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    backgroundColor: Theme.of(context).colorScheme.surface,
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
    backgroundColor: Theme.of(context).colorScheme.surface,
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
            ..._content(context, ref),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref) {
    switch (tile.kind) {
      case PortalKind.ratings:
        // fake-data-sweep: kSupplierRatings is a demo seed with no live source —
        // gate the DATA rows together with the label (not just the note), so the
        // review build never shows fake ratings; show an honest server-pending
        // row instead of a blank sheet.
        return [
          if (!kHideUnderConstruction) ...[
            for (final r in kSupplierRatings)
              _row(context, '⭐ ${r.score} · ${r.orders} הזמנות · ${r.onTime}% בזמן'),
            _note('נתוני הדגמה (seed מהפרוטוטייפ) — יוחלפו בנתונים חיים עם חיבור השרת'),
          ] else
            _row(context, 'דירוגי ספקים חיים יתווספו עם חיבור השרת'),
        ];
      case PortalKind.zones:
        return [
          for (final z in kDistZones)
            _row(context, '${z.name} · ${z.eta} · משלוח ${fMoney(z.fee)}'),
        ];
      case PortalKind.sla:
        return [
          for (final z in kDistZones) _row(context, '${z.name} · יעד אספקה: ${z.eta}'),
        ];
      case PortalKind.bulk:
        return [
          for (final t in kBulkTiers) _row(context, '${t.min}+ יח׳ · ${t.discount}% הנחה'),
        ];
      case PortalKind.fleet:
        // fake-data-sweep: kFleet is a demo seed with no live source — gate it and
        // show an honest server-pending row instead of fabricated vehicles.
        return [
          if (!kHideUnderConstruction) ...[
            for (final v in kFleet)
              _row(context, '${v.name} · ${v.cap} · ${v.status} · נהג ${v.driver}'),
          ] else
            _row(context, 'ניהול צי חי יתחבר עם חיבור השרת'),
        ];
      case PortalKind.autoStock:
        // Live out-of-stock list — the supplier's [storeOosProvider] set, the
        // same source the store dashboard's מלאי tab toggles.
        final oos = ref.watch(storeOosProvider).toList()..sort();
        if (oos.isEmpty) {
          return [_row(context, '✓ כל המוצרים זמינים במלאי')];
        }
        return [
          _row(context, '⚠️ ${oos.length} מוצרים אזלו מהמלאי'),
          for (final name in oos) _row(context, '❌ $name'),
        ];
      // 💬 chat tiles are now wired (CH-4) to the shared cross-persona
      // [ChatsScreen]. The portal serves a SINGLE active persona, so the tile's
      // counterpart fixes which role opens the screen: the supplier portal's
      // "צ׳אט עם קבלן" runs under the 🏪 store ([BsRole.store]); the courier
      // portal's "צ׳אט עם חנות" runs under the 🛵 courier ([BsRole.courier]).
      // 🔒 ISOLATION (SPEC §2.5): we ONLY push `ChatsScreen(persona:)` — it
      // wraps itself as a standalone Scaffold whose back button pops straight
      // back to this portal; no route to home_shell / role_picker / any other
      // persona's board.
      case PortalKind.chatContractor:
        return [_ChatEntryRow(label: tile.title, persona: BsRole.store)];
      case PortalKind.chatStore:
        return [_ChatEntryRow(label: tile.title, persona: BsRole.courier)];
      // barcode (store) is still honestly unwired; nav/pod reach here only if
      // the legacy courier grid-dialog is opened — the courier BOARD wires them
      // for real in CourierPortalTab (#74).
      case PortalKind.barcode:
      case PortalKind.nav:
      case PortalKind.pod:
        return [_row(context, '${tile.sub} — כלי זה יחובר בהמשך הפיתוח.')];
    }
  }

  Widget _row(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
      ),
    ),
  );

  /// F-48 — honest demo/seed annotation under seeded numbers (the SAME muted
  /// `_note` pattern as the courier portal, courier_portal_tab.dart:169-170;
  /// never lets a prototype seed pose as live data).
  Widget _note(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Text(
      text,
      style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
    ),
  );
}

/// The 💬 chat tile's content row inside a portal sheet (CH-4). Tapping it closes
/// the portal sheet and pushes the shared cross-persona [ChatsScreen] for this
/// portal's active [persona] (🏪 store / 🛵 courier).
///
/// 🔒 ISOLATION (SPEC §2.5): the ONLY navigation is `push(ChatsScreen(persona:))`
/// — that screen is a self-contained standalone Scaffold ("שיחות" + back→pop), so
/// the back button returns to THIS portal; nothing here routes to home_shell, the
/// role picker, or any other persona's board.
class _ChatEntryRow extends StatelessWidget {
  const _ChatEntryRow({required this.label, required this.persona});

  final String label;
  final BsRole persona;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: () {
            // Capture the navigator BEFORE popping — after the sheet closes this
            // row's own context is defunct, so a fresh `Navigator.of(context)`
            // lookup would fail. Pop the portal sheet, then push the persona's
            // standalone chat onto the same navigator.
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(
              MaterialPageRoute<void>(
                builder: (_) => ChatsScreen(persona: persona),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: BsTokens.space3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$label ›',
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_left,
                  color: BsTokens.mutedLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
