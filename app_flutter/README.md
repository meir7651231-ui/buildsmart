# BuildSmart — Flutter (Dart)

Parallel rewrite of BuildSmart in Flutter, targeting **iOS + Android + Web**
from a single codebase. The existing Preact app under `../app/` keeps
running — this folder is the long-term native target.

## Status

**Phase 0 — shell.**
- 5-FAB rail at the bottom (BS · Search · BS-mode · Menu · BS)
- BS dial opens 5 personas verbatim (קבלן · מנהל המערכת · חנות ספק · שליח · עובד)
- Menu dial opens 4 tabs (בית · הפרויקטים · רכש · הגדרות)
- Hebrew RTL by default (`locale: he-IL`)
- Dark Material 3 theme with brand orange + dial tokens ported from
  `../app/src/styles/tokens.css`
- 3/3 widget tests passing · web build 2.0 MB main.dart.js

## Stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter 3.29+ | Single codebase for iOS/Android/Web |
| Language | Dart 3.7+ | Null-safe, modern, fast |
| State | `flutter_riverpod` ^2.6 | Closest spirit to `@preact/signals` |
| Routing | `go_router` ^14.6 | Deep links + web URLs |
| i18n | `flutter_localizations` + `intl` | RTL + ARB-based translations |
| Persistence | `shared_preferences` | Settings/profile |
| Lints | `very_good_analysis` ^7 | Strictest preset from day one |

## Rules — same R1-R9 as the Preact app

The whole point of rewriting is to keep the **architecture** that
took INSP-0009 → INSP-0044 to crystallise. See `../app/RULES.md` and
`../CLAUDE.md` for the canonical R1-R9. In summary:

1. **R1** — exactly 5 FABs, never more, never less.
2. **R2** — אין חלון, נקודה. No new feature replaces the body —
   everything opens as a dial.
3. **R3** — settings = dial only, never sheets/modals.
4. **R4** — every dial row is two widgets: circle + label pill.
5. **R6** — Hebrew labels verbatim from `../index.html` (the 22K-line
   legacy prototype), never invented.
6. **R7** — never break the regression suite.
7. **R8** — if it's not in the legacy, don't add it.
8. **R9** — text input = inline field in the dial, never a prompt.

## Develop

```bash
cd app_flutter
flutter pub get
flutter run -d chrome           # web
flutter run -d <ios-simulator>  # iOS
flutter run -d <android-id>     # Android

flutter analyze                 # lints
flutter test                    # widget tests
flutter build web --release     # production bundle in build/web/
```

## Roadmap

- [x] Phase 0 — 5-FAB shell, dial primitive, BS persona tiles, Menu tab tiles
- [ ] Phase 1 — BS persona drills (sections + status leaves)
- [ ] Phase 2 — Search FAB (voice, barcode, filters, sort, catalog)
- [ ] Phase 3 — Menu drills (home / projects / cart / settings tree)
- [ ] Phase 4 — Persistence (shared_preferences ↔ Preact `bs.settings.v1`)
- [ ] Phase 5 — Native APIs (camera/barcode plugin, push notifications)
- [ ] Phase 6 — Backend wire (when API exists)
- [ ] Phase 7 — Store releases (App Store + Play)
