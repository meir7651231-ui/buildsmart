# Preview build — `/buildsmart/flutter-preview/`

The integrated **manager + unified live-orders engine** build is published to
GitHub Pages at `/buildsmart/flutter-preview/`, rebuilt on every deploy from the
`claude/agent-network-live` branch (see `.github/workflows/deploy.yml`, the
`Build manager preview` step).

**v6.12** — the preview now carries the full v6.11 catalog/parity track (Lipski
hierarchy chips + Polyroll/Huliot PDF-parity, 944 SKUs) merged onto the manager
branch (clean merge, 0 conflicts; analyze 0, +1536 tests green). So it is the
latest catalog AND the manager control-center in a single build.

All four roles — 👷 contractor · 🏪 store · 🛵 courier · 👔 manager — share ONE
live orders engine (`ordersEngineProvider`): advancing an order in any role is
reflected live in the manager's dashboard.

The live site (`/buildsmart/` and `/buildsmart/flutter/`) is unaffected by this
preview — it is an additional, isolated path.
