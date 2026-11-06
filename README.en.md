<p align="left"><b>English</b> · <a href="README.md">עברית</a></p>

<p align="center"><img src="assets/hero.svg" alt="BuildSmart — site procurement and tasks, with a catalog that knows what connects to what" width="100%"></p>

<p align="center">
<a href="https://github.com/meir7651231-ui/buildsmart/actions/workflows/deploy.yml"><img src="https://github.com/meir7651231-ui/buildsmart/actions/workflows/deploy.yml/badge.svg?branch=main" alt="Deploy to GitHub Pages"></a>
<a href="https://github.com/meir7651231-ui/buildsmart/actions/workflows/catalog-qa.yml"><img src="https://github.com/meir7651231-ui/buildsmart/actions/workflows/catalog-qa.yml/badge.svg" alt="catalog-qa"></a>
<img src="https://img.shields.io/badge/Flutter-3.44-F26B1D?labelColor=1F1A13" alt="Flutter 3.44">
<img src="https://img.shields.io/badge/platforms-iOS%20·%20Android%20·%20Web-F26B1D?labelColor=1F1A13" alt="iOS · Android · Web">
</p>

<h3 align="center">One app for site procurement, orders and tasks — with a plumbing catalog that knows what connects to what.</h3>

<p align="center"><a href="#the-problem"><b>The problem</b></a> · <a href="#how-it-works">How it works</a> · <a href="#whats-inside">What's inside</a> · <a href="#what-it-does-not-do">What it does not do</a> · <a href="#the-numbers">The numbers</a> · <a href="#see-it-in-action">Demo</a> · <a href="#run-it-locally">Run it locally</a> · <a href="#status-and-versions">Status</a> · <a href="#faq">FAQ</a> · <a href="#security-and-license">License</a></p>

---

## The problem

On a construction site, ordering materials happens over the phone, on WhatsApp and through supplier catalogs full of near-identical items.
One wrong size, or a fitting that doesn't connect to the pipe already laid, and someone drives back to the store while the work waits.

**BuildSmart puts it in one place:** an automatically checked catalog, an engine that works out which fittings connect,
cart and orders, chat, and a separate view for each role — contractor, manager, supplier store, courier and worker.

The app itself is Hebrew-first (right-to-left).

<p align="center"><img src="assets/beforeafter.en.svg" alt="Without BuildSmart: phone orders, sizes from memory, fittings that don't fit. With BuildSmart: one checked catalog, variant by shape and size, the engine shows what connects, orders tied to a project" width="100%"></p>

## How it works

<p align="center"><img src="assets/how.en.svg" alt="Supplier catalog → quality gate (catalog_qa.py) → compatibility engine → the app, on top of a Firebase backend and an edge proxy" width="100%"></p>

1. **Supplier catalog** — product data (sizes, categories, images) lives in code, in `app_flutter/lib/data/`.
2. **Quality gate** — `scripts/catalog_qa.py` checks the catalog on every data change (the `catalog-qa` workflow). A blocking error turns CI red.
3. **Compatibility engine** — a verified spec graph, connection routing and a bill of materials (BOM) — `app_flutter/lib/logic/install_engine.dart`.
4. **The app** — Flutter, one codebase for iOS, Android and the web. The backend is Firebase (Firestore, Auth, Cloud Functions and security rules); for filtered networks there is an edge proxy (Cloudflare Worker) in `edge-proxy/`.

## What's inside

<p align="center"><img src="assets/capabilities.en.svg" alt="Verified catalog · compatibility engine · Install Studio · cart and orders · chat · 5 roles · barcode and camera · filtered networks · one codebase" width="100%"></p>

<table>
<tr>
<td align="center" width="25%"><img src="assets/screens/home.png" alt="Home: departments, smart tree and work route" width="100%"><br><sub>Home</sub></td>
<td align="center" width="25%"><img src="assets/screens/catalog.png" alt="Plumbing catalog by category" width="100%"><br><sub>Catalog</sub></td>
<td align="center" width="25%"><img src="assets/screens/product.png" alt="Fittings with variant picker: shape, size, thread" width="100%"><br><sub>Variants</sub></td>
<td align="center" width="25%"><img src="assets/screens/cart.png" alt="Cart: project assignment and delivery options" width="100%"><br><sub>Cart</sub></td>
</tr>
</table>
<p align="center"><sub>Real screenshots from <code>flutter build web</code> in demo mode (sample data, no login). The UI is in Hebrew.</sub></p>

**Repo map:**

| Folder / file | What it is | State |
|---|---|---|
| [`app_flutter/`](app_flutter/) | The app — Flutter + Riverpod, iOS · Android · Web, Hebrew RTL | 🟢 active development |
| [`app/`](app/) | The previous version — Preact + TypeScript + Vite (PWA) | 🟡 live on GitHub Pages, bug fixes only |
| [`functions/`](functions/) | Firebase Cloud Functions (TypeScript) — orders, credit, notifications and more | backend |
| [`firestore.rules`](firestore.rules) · [`rules_test/`](rules_test/) | Database security rules and their tests | backend |
| [`edge-proxy/`](edge-proxy/) | Edge proxy (Cloudflare Worker) — all traffic through one domain | backend |
| [`scripts/`](scripts/) | Catalog quality gate, catalog import, build and version scripts | tooling |
| [`orchestrator/`](orchestrator/) · [`perfect-agent/`](perfect-agent/) · [`tools/atom/`](tools/atom/) · [`atom-engine/`](atom-engine/) | Tooling and procedures for the AI coding agents that build the project | dev tooling |
| [`index.html`](index.html) | The original prototype (~22k lines) — the source of the Hebrew copy | archive / source |
| [`docs/CATALOG_PROTOCOL.md`](docs/CATALOG_PROTOCOL.md) · [`scripts/CATALOG_ROADMAP.md`](scripts/CATALOG_ROADMAP.md) | Catalog knowledge protocol and roadmap (Hebrew) | docs |

## What it does not do

- **Not in the stores yet.** There is no App Store or Google Play release yet — launch prep is in progress.
- **No card payments.** The app has no payment-gateway integration; the cart computes totals and delivery options.
- **No price list.** Catalog items show "price per supplier".
- **The quality gate covers one catalog.** `catalog_qa.py` checks the Lipskey catalog (`lipskey_catalog.dart`, 923 products) — not the other brand catalogs.
- **Not a substitute for a professional.** The engine suggests connections from catalog specs; the call on site stays with the installer.
- **Some features are off by default.** The no-code Studio is dormant until enabled, and filtered-network mode turns on only when the user picks it.

## The numbers

<p align="center"><img src="assets/numbers.en.svg" alt="923 verified catalog products · 6,034 Flutter tests passing · 0 analyze errors · 0 blocking catalog errors" width="100%"></p>

## See it in action

<p align="center"><img src="assets/demo.gif" alt="Demo: home screen, catalog, fittings with variants, add to cart" width="320"></p>

## Run it locally

<p align="center"><img src="assets/install.svg" alt="Run locally: catalog audit, generate version, flutter pub get, flutter build web, serve build/web" width="100%"></p>

Every command below was run and passed (2026-11-06). You need Python 3, Node 20+ (CI uses 20) and Flutter 3.44 (two workflows still pin 3.29.3).

**Catalog quality gate** (Python only, nothing to install):

```bash
python3 scripts/catalog_qa.py audit       # full check — "zero blocking errors"
python3 scripts/catalog_qa.py selftest    # proves every rule actually fires
python3 scripts/test_catalog_qa.py        # the engine's unit tests — 12/12
python3 scripts/catalog_qa.py truthcheck  # compare against source_truth.json (report)
python3 scripts/catalog_qa.py coverage    # image/size coverage per brand (report)
python3 scripts/catalog_qa.py report      # KPIs: 923 products · 68 categories · 0 errors
```

**The app (Flutter):**

```bash
bash scripts/gen_version.sh               # required before a build — writes lib/version.g.dart
cd app_flutter
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --concurrency=4              # the full suite — 6,034 tests
flutter build web --release               # output in build/web/
cd build/web && python3 -m http.server 8765   # open http://localhost:8765 → demo mode, no account
```

**The previous version (Preact):**

```bash
cd app
npm ci
npm run build
```

## Status and versions

- **App version:** `1.5.2+14` (from `app_flutter/pubspec.yaml`). The build label shown in the app is `v7.02` (from `app_flutter/knowledge/STATUS.md`, via `scripts/gen_version.sh`).
- **Release tags:** none yet. Milestones are recorded in [`CHANGELOG.md`](CHANGELOG.md).
- **Live now:** [GitHub Pages](https://meir7651231-ui.github.io/buildsmart/) (Preact version) and a [Flutter preview](https://meir7651231-ui.github.io/buildsmart/flutter/).
- **CI on `main`:** Deploy to GitHub Pages ✅ · Protocol Enforcement ✅ · Atom Tools ❌ (agent dev tooling, separate from the main CI — [run](https://github.com/meir7651231-ui/buildsmart/actions/runs/32666555496)).
- **In progress:** preparing the App Store and Google Play launch. New features are frozen until launch.

## FAQ

<details><summary><b>Why are there two apps in the repo?</b></summary>

`app/` (Preact) is the version live on the web today. `app_flutter/` is the new one, with a single codebase for iPhone and Android too.
Once the Flutter version is stable it takes over; until then `app/` gets bug fixes only.
</details>

<details><summary><b>What does "what connects to what" mean?</b></summary>

Fittings in the catalog carry a spec (for example diameter and connection type). The engine builds a graph from those specs and works out which items connect,
which connection route is possible, and what to order to complete it.
</details>

<details><summary><b>Can I try it without an account?</b></summary>

Yes. The welcome screen has "continue without registering (sample)" — demo mode with sample data. That is how the screenshots and the demo here were made.
</details>

<details><summary><b>Why an edge proxy?</b></summary>

On filtered networks in Israel (such as NetFree or Rimon) Google services are sometimes blocked. The proxy routes traffic through one project domain. It only runs in "filtered internet" mode.
</details>

<details><summary><b>How do you know the catalog is clean?</b></summary>

`catalog_qa.py audit` runs in CI on every catalog-data change, and `selftest` proves each rule really checks something (a rule that doesn't fire fails).
</details>

## Security and license

- **Reporting a security issue:** see [`SECURITY.md`](SECURITY.md). Please don't open a public issue for it.
- **License:** the repo has no license file at the moment.
