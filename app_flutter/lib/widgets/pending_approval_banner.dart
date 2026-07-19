// ─────────────────────────────────────────────────────────────────────────────
// pending_approval_banner — U1.5.2 (user-system): the "ממתין לאישור" strip.
//
// A thin top banner shown ONLY to a signed-in user whose `users/{uid}.status` is
// `pending` (all-by-approval, decision #1) — a standing notice that most actions
// are blocked until an admin activates them. It reads [pendingApprovalProvider]
// (rbac.dart), which is TRUE only when `kUserSystem` is on AND the user-system
// sync has created the pending `users` doc; in every normal build it is false, so
// this renders `SizedBox.shrink()` (nothing).
//
// DORMANT: mounted behind `if (kUserSystem)` at its single call-site (home_shell,
// mirroring the `if (kIntelLive)` consent-modal pattern) → const-false in every
// normal build → the widget + this file tree-shake away → byte-identical.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/rbac.dart' show pendingApprovalProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart' show showToast;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The standing "waiting for admin approval" strip. Renders nothing unless the
/// signed-in user is pending. Placed at the top of the shell body (a `Positioned`
/// top strip) so it overlays the content without restructuring the layout.
///
/// It also announces the moment the wait ENDS. Approval used to be silent from
/// the user's side: the push (`onUserActivated`) only lands if notifications
/// were permitted, and the live site is regularly opened in a browser that
/// denied them — so the notification alone would leave exactly the people who
/// waited longest still staring at "ממתין לאישור". Watching the flip in-app
/// needs no permission and cannot be declined.
class PendingApprovalBanner extends ConsumerStatefulWidget {
  const PendingApprovalBanner({super.key});

  @override
  ConsumerState<PendingApprovalBanner> createState() =>
      _PendingApprovalBannerState();
}

class _PendingApprovalBannerState extends ConsumerState<PendingApprovalBanner> {
  @override
  Widget build(BuildContext context) {
    // The pending → approved EDGE, not the state: `previous` is null on the
    // first build, so someone who was already active when the app opened is not
    // congratulated for nothing.
    ref.listen<bool>(pendingApprovalProvider, (wasPending, isPending) {
      if ((wasPending ?? false) && !isPending) {
        showToast(context, 'החשבון שלך אושר ✓ — אפשר להתחיל');
      }
    });
    if (!ref.watch(pendingApprovalProvider)) return const SizedBox.shrink();
    return const Material(
      color: Color(0xFFFFF3CD), // soft amber — a non-blocking notice
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: BsTokens.space2,
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top, size: 18, color: Color(0xFF8A6D00)),
              SizedBox(width: BsTokens.space2),
              Expanded(
                child: Text(
                  'החשבון שלך ממתין לאישור מנהל — חלק מהפעולות חסומות עד ההפעלה.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A6D00),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
