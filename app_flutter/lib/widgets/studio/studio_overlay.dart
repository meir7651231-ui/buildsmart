// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 13 — the always-mounted Studio chrome.
//
// FROZEN — screen-management directive · slice-0 (2026-07-27). The on-screen edit
// chrome (the נווט⇄ערוך toggle + the 🔀 board selector) had no good UNIVERSAL
// trigger location — screens like site-management have no fixed logo — so an
// on-screen trigger was inconsistent and confusing. It is removed from the build:
// there is NO on-screen entry to edit-mode right now (frozen until a good location
// is found). Editing moves ENTIRELY to the setup wizard (org_setup_wizard_screen),
// which stays the SOLE edit entry — STUDIO/kOrgConfigFlag stay on so the wizard is
// reachable, and the #84 owner gate (studioCanEditProvider / enterEdit) is
// unchanged; nothing on-screen can flip edit-mode anymore.
//
// The widget stays mounted-inert — always `SizedBox.shrink()`, the proven
// ConnectionIndicator always-mounted-inert pattern — so main.dart's builder Stack
// is UNTOUCHED and re-enabling later is a localized revert (git history holds the
// full chrome + the toggle/board/publish widgets). It was already answer-
// equivalent off-gate, and with `kStudioFlag` const-OFF the live build tree-shakes
// it away ⇒ non-owner / production are BYTE-IDENTICAL.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Always mounted, always inert: the on-screen Studio chrome is FROZEN (slice-0)
/// and edit entry lives in the setup wizard. Kept as a mounted no-op so the
/// main.dart builder Stack needs no change (re-enable = restore from git).
class StudioOverlay extends ConsumerWidget {
  const StudioOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox.shrink();
}
