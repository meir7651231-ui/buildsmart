# Changelog

Milestones merged into the repo. Source: the repo's merged pull requests (numbers in brackets).
No release tags yet. App version today: `1.5.2+14` (`app_flutter/pubspec.yaml`); in-app build label: `v7.02`.

אבני-דרך שמוזגו לריפו. המקור: ה-Pull Requests הממוזגים (המספרים בסוגריים). עדיין אין תגיות שחרור.

## Unreleased — repo presentation (2026-11-06)
- Bilingual README (`README.md` Hebrew · `README.en.md` English) with real app screenshots, a demo GIF and diagrams in `assets/`.
- `CHANGELOG.md` and `SECURITY.md` added.
- Root tidy-up with `git mv` only: `CATALOG_PROTOCOL.md` and `knowledge/C5.4-firestore-backup.md` moved to `docs/`.
- No product code changed.

## Milestone 7 — `main` is the source of truth (2026-08-23)
- `main` aligned with the development branch `claude/whats-happening-LyY9G` — 1,693 commits merged (#58).

## Milestone 6 — works on filtered networks (2026-08-12 → 08-13)
- Catalog images via `cdn.buildsmart-il.com`, catalog/config API via the project domain (#25, #26).
- Edge proxy (Cloudflare Worker) for Firestore, Auth and chat, behind a "filtered internet" switch that is off by default (#27–#47).
- Chat fixes: identity by user id, customer threads routed to real DMs, the missing Firestore index (#48–#54).
- Deploy-gate test fixes (#56, #57).

## Milestone 5 — catalog go-live tooling (2026-07-14 → 07-25)
- `seed-catalog` workflow on `main` — manual catalog seeding to Firestore, dry-run by default (#23).
- `clean-two-links` workflow registered on `main` (#24).

## Milestone 4 — Studio, the no-code editor (2026-07-08 → 07-09)
- Owner-editable screen elements, wired in five coverage rounds; dormant by default (#6, #10–#12, #14–#22).
- Cloud Functions deploy fixes for the rollup schedulers (#7–#9).
- Manager code-login for the web build (#13).

## Milestone 3 — catalog model and compatibility engine (2026-05-25)
- Catalog model, compatibility engine, offline support, Flutter 3.44 (#4).
- Flutter app and Vercel deploy config merged to `main` (#3).

## Milestone 2 — new app skeleton (2026-05-21)
- Preact + TypeScript + Vite app under `app/` (#2).

## Milestone 1 — prototype routing (2026-05-20)
- Prototype router wired so the URL hash tracks the current screen (#1).
