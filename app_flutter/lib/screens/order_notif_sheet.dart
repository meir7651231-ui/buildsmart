import 'package:buildsmart/state/notif_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔔 התראות הזמנות ומשלוחים — the ORDER/shipment notification toggles, surfaced
/// IN the orders world (store_screen · 📦 הזמנות) per owner decision #52. Reads &
/// writes the SAME [notifSettingsProvider] the settings screen uses — this is a
/// RELOCATION of two controls (typeOrders + typeShipments), not a second store
/// of state; every other notification setting stays in הגדרות › התראות.
class OrderNotifSheet extends ConsumerWidget {
  const OrderNotifSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(notifSettingsProvider);
    final n = ref.read(notifSettingsProvider.notifier);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 2),
              child: Text(
                '🔔 התראות הזמנות ומשלוחים',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Text(
                'שאר ההתראות נשארו בהגדרות › התראות',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF888888)),
              ),
            ),
            SwitchListTile(
              title: const Text('עדכוני הזמנות'),
              subtitle: const Text('אישור · בהכנה · מוכן · שינוי סטטוס'),
              value: s.typeOrders,
              onChanged: (v) => n.update((x) => x.copyWith(typeOrders: v)),
            ),
            SwitchListTile(
              title: const Text('עדכוני משלוחים'),
              subtitle: const Text('יצא לדרך · בדרך אליך · נמסר'),
              value: s.typeShipments,
              onChanged: (v) => n.update((x) => x.copyWith(typeShipments: v)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/// Opens [OrderNotifSheet] as a modal bottom sheet from the orders world.
Future<void> showOrderNotifSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const OrderNotifSheet(),
    );
