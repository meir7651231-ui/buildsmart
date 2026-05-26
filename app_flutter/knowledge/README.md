# app_flutter — Knowledge Protocol

Single source of truth for the **Flutter** app (`app_flutter/`). Read this
before touching code, even with conversation context. The legacy Preact
protocol lives in `app/knowledge/` and does **not** govern Flutter work.

## The files

| File | What it holds |
|---|---|
| `README.md` (this) | the protocol + index |
| `STATUS.md` | current state snapshot — screens, features, wiring counts, version |
| `ARCHITECTURE.md` | structure: screens / state / data / widgets, navigation, theming |
| `TESTING.md` | the verification protocol — harness, `flutter test`, mutation testing |
| `CONVENTIONS.md` | light-mode, RTL, commit/version, inherited shell rules |
| `DECISIONS.md` | ADR-style log of notable decisions |
| `../WIRING.md` | the wiring contract — every button/setting → behavior → status |

## The protocol — every change follows this

1. **Locate, don't invent.** Find the real code/string before editing. No
   feature, string, or behavior that isn't grounded in the codebase (R8).
2. **Extract logic to pure helpers** when it needs to be correct. Embedded
   widget logic (math, filters, mappings, thresholds) is moved to top-level
   pure functions so it can be unit-tested. See `cartVat`, `notifPasses`,
   `indexableWord`, `notifMutedSections`.
3. **Wire ⇒ contract ⇒ test.** Any setting/button wired to a real effect must
   be (a) listed in `../WIRING.md` with its status, and (b) covered by a check
   in `test/` (usually `gaps_test.dart` / `wiring_test.dart`). The contract and
   the tests stay in sync.
4. **Verify before commit:**
   ```bash
   export PATH="/home/user/flutter/bin:$PATH"
   cd app_flutter
   flutter analyze        # 0 errors (info/warnings from legacy dead code are tolerated)
   flutter test           # all green
   flutter build web --release
   ```
5. **Mutation-test the logic** when adding/altering a pure helper: inject a
   bug, confirm a test goes red, revert. The goal for domain logic is
   **100% caught** (see `TESTING.md`). UI-only effects are exercised through
   their underlying providers/helpers, not pixel rendering.
6. **Commit small, push to** `claude/whats-happening-LyY9G`. Never push to
   main without explicit approval. Bump the in-app version label
   (`home_shell.dart`) when shipping a user-visible change.

## Status legend (used across these docs)
✅ wired (real effect) · 🚧 בבנייה (placeholder) · ⛔ blocked (needs data/server/telephony)
