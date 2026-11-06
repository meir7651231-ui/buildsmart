# Changelog

Milestones that were merged into the repo, by date. Source: the repo's merged pull requests.
The project does not use release tags yet; the app version is in `app_flutter/pubspec.yaml` (`1.5.2+14` today).

אבני-דרך שמוזגו לריפו, לפי תאריך. המקור: ה-Pull Requests הממוזגים בריפו.

## 2026-11-06
- Repo presentation: bilingual README (`README.md` Hebrew · `README.en.md` English), `assets/` (hero, flow diagram, logo, social image), `CHANGELOG.md`, `SECURITY.md`. No product code changed.

## 2026-08-23
- `main` aligned with the development branch `claude/whats-happening-LyY9G` — 1,693 commits merged (#58).

## 2026-08-12 / 08-13
- Filtered-network support: catalog images via `cdn.buildsmart-il.com`, catalog/config API via the project domain, and an edge proxy (Cloudflare Worker) for Firestore, Auth and chat — behind flags, off by default (#25–#47).
- Chat fixes: identity by user id, customer threads routed to real DMs, the missing Firestore index (#48–#54).
- Deploy-gate test fixes (#56, #57).

## 2026-07-25
- `clean-two-links` workflow registered on `main` (#24).

## 2026-07-14
- `seed-catalog` workflow on `main` — manual catalog seeding to Firestore, dry-run by default (#23).

## 2026-07-08 / 07-09
- Studio (no-code editor): owner-editable screen elements, wired in five coverage rounds; dormant by default (#6, #10–#12, #14–#22).
- Cloud Functions deploy fixes for the rollup schedulers (#7–#9).
- Manager code-login for the web build (#13).

## 2026-05-25
- Catalog model, compatibility engine, offline support, Flutter 3.44 (#4).
- Flutter app and Vercel deploy config merged to `main` (#3).

## 2026-05-21
- New app skeleton (Preact + TypeScript + Vite) under `app/` (#2).

## 2026-05-20
- Prototype router wired so the URL hash tracks the current screen (#1).
