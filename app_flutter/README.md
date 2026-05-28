# BuildSmart — Flutter (Dart)

Parallel rewrite of BuildSmart in Flutter, targeting **iOS + Android + Web**
from a single codebase. The existing Preact app under `../app/` keeps
running — this folder is the long-term native target.

## Status

**Active development — ~v4.71.** Light-mode, RTL, store-launch target.
- 4-tab bottom-nav (קטלוג · שיחות · התראות · חנות) + a floating cart FAB. The BS
  dial opens via the AppBar wordmark (5 personas); the **Menu + Search dials are
  built but not yet wired to a trigger** (see `knowledge/spec/shell-and-dials.md` §7).
- Real catalog: ~935 Lipskey products + forgiving search + finder + variants +
  smart-tree + product sheet with attribute chips.
- **Install Studio + BOM/compatibility engine** (verified-spec graph, Dijkstra
  routing, safety checklist) — deeper than the prototype.
- Cart + checkout, chats, notifications, 4 settings screens (persisted).
- Hebrew RTL (`locale: he-IL`); **light** theme (`AppTheme.light`, brand orange).
- 52 test files + in-app regression harness (12 suites); `flutter analyze` clean;
  `main.dart.js` ≈ 4.8 MB.
- Port roadmap to full prototype + Preact parity: **`knowledge/PARITY.md`**.

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

1. **R1** — 5 FABs is the *rule*; the current shell realizes a 4-tab + cart-FAB
   variant (only the BS dial wired) — see `knowledge/spec/shell-and-dials.md` §7.
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

- [x] Shell + dial primitive + BS persona tiles + Menu/Search/Settings trees
- [x] BS persona drills (sections + status leaves)
- [x] Catalog (935 products, search, finder, variants, smart-tree, product sheet)
- [x] Install Studio + BOM/compatibility engine
- [x] Cart + checkout, chats, notifications, 4 settings screens + persistence
- [ ] Wire the Menu + Search dials to triggers; fill the contractor persona
- [ ] Port the ~85% gap (profile/ranks/rewards, projects/finance/tasks, B2B
      flows, the 4 persona apps, onboarding/RBAC) — see `knowledge/PARITY.md`
- [ ] Native: camera/barcode done; push/media pending
- [ ] Backend wire (when API exists) · Store releases (App Store + Play)
