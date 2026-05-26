# Checklists — app_flutter

Copy-paste these for common changes. Each ends at a green `flutter test`.

## Wire a setting to a real effect
- [ ] Find the field in `lib/state/<area>_settings.dart` and confirm it's read
      nowhere yet (write-only).
- [ ] If the effect is logic (math/filter/mapping/threshold), **extract a pure
      top-level helper** and have the widget call it.
- [ ] Wire the widget to the helper/provider.
- [ ] Add the row to `../WIRING.md` with status ✅ and the helper name.
- [ ] Add a check in `test/gaps_test.dart` (or `wiring_test.dart`).
- [ ] If the helper is "enforced", add its signature to
      `test/knowledge_protocol_test.dart` and a `WIRING.md` reference.
- [ ] `flutter analyze` (0 errors) · `flutter test` (green).
- [ ] Mutation-check: inject a bug in the helper, confirm a test goes red, revert.
- [ ] Bump version label in `home_shell.dart`; commit; pull `--no-rebase`; push.

## Add / convert a screen (light mode)
- [ ] Scaffold bg `0xFFF5F6FA`, cards `0xFFFFFFFF`, AppBar `foregroundColor: 0xFF1A1A1A`.
- [ ] No white text on a light surface (white only on colored buttons/badges).
- [ ] Emoji boxes in headless screenshots are expected (not a bug).
- [ ] The light-mode guard in `knowledge_protocol_test.dart` must stay green
      (no `backgroundColor: const Color(0xFF111111)`).
- [ ] Verify visually if reachable; otherwise note "not visually verified".

## Add a placeholder → real behavior
- [ ] Replace the "בבנייה" toast with the real action.
- [ ] Move the row in `../WIRING.md` from 🚧 to ✅; add a test.

## Before every commit
- [ ] `flutter analyze` — 0 errors (legacy `info`/unused-element warnings tolerated).
- [ ] `flutter test` — all green (includes the protocol enforcement test).
- [ ] `flutter build web --release` for UI changes.
- [ ] Branch `claude/whats-happening-LyY9G`; never main without approval.
- [ ] No model id / internal id in commits, code, or docs.

## When mutation testing finds a MISSED bug
- [ ] It's a coverage gap. Extract the logic if embedded; add a pinning test.
- [ ] If the mutation is behaviorally equivalent, pin it with an adversarial
      input (e.g. a negative subtotal) rather than ignoring it.
- [ ] Re-run the sweep until domain logic is 100% caught.
