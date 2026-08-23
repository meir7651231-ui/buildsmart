import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/state/push_routing.dart'
    show afterThisFrame, consumePendingThread, pendingPushThreadProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart' show showGlobalToast;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which sub-view the merged "עדכונים" tab shows: 0 = התראות, 1 = שיחות.
final updatesSubTabProvider = StateProvider<int>((_) => 0);

/// Benzi #3 — "עדכונים": the former התראות + שיחות tabs merged under ONE tab,
/// with a top segmented toggle. Both existing screens are kept alive
/// (`IndexedStack`) so their state (scroll / search / filters) survives a switch.
/// When the org's `chat` module is off (`modOn`, `lib/state/org_gates.dart`)
/// the toggle and the שיחות pane don't render at all — התראות fills the tab.
class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatOn = modOn(ref, 'chat');
    // Index safety: the שיחות pane sits at index 1, and external navigation
    // (global search / keyboard destinations) may leave the provider at 1.
    // With `chat` off the effective index is clamped to 0 (התראות) so the
    // IndexedStack can never point at the hidden pane.
    final sub = chatOn ? ref.watch(updatesSubTabProvider) : 0;
    // PUSH-CHAT degrade: with `chat` off the שיחות pane never mounts, so its
    // consumer (ChatsScreen — the chats_screen.dart consumePendingThread site)
    // can't take a tapped notification's pending thread id and it would sit
    // forever. This screen IS always built (the shell IndexedStack keeps every
    // tab alive), so the OFF arm consumes it honestly here — the single
    // off-path consume site, dark on the all-on path (`&&` short-circuits, no
    // extra dependency). Frame-deferred per the main.dart afterThisFrame
    // discipline — never a provider write or toast mid-build; the null-guard
    // inside the callback keeps a double-scheduled frame from toasting twice.
    if (!chatOn && ref.watch(pendingPushThreadProvider) != null) {
      afterThisFrame(() {
        if (consumePendingThread(ref) != null) {
          showGlobalToast('שיחות אינן פעילות בחברה זו');
        }
      });
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          if (chatOn) ...[
            _UpdatesToggle(active: sub),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
          ],
          Expanded(
            child: IndexedStack(
              index: sub,
              children: [
                const NotificationsScreen(),
                if (chatOn) const ChatsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Top segmented control for the עדכונים tab: [🔔 התראות · 💬 שיחות].
class _UpdatesToggle extends ConsumerWidget {
  const _UpdatesToggle({required this.active});

  final int active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget seg(int i, IconData icon, String label) {
      final on = active == i;
      final color = on ? BsTokens.brand : const Color(0xFF888888);
      return Expanded(
        child: InkWell(
          onTap: () => ref.read(updatesSubTabProvider.notifier).state = i,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: on ? BsTokens.brand : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          seg(0, Icons.notifications_outlined, 'התראות'),
          seg(1, Icons.chat_bubble_outline, 'שיחות'),
        ],
      ),
    );
  }
}
