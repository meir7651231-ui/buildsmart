# Preview build — `/buildsmart/flutter-preview/`

The integrated **manager + unified live-orders engine** build is published to
GitHub Pages at `/buildsmart/flutter-preview/`, rebuilt on every deploy from the
`claude/agent-network-live` branch (see `.github/workflows/deploy.yml`, the
`Build manager preview` step).

All four roles — 👷 contractor · 🏪 store · 🛵 courier · 👔 manager — now share ONE
live orders engine (`ordersEngineProvider`): advancing an order in any role is
reflected live in the manager's dashboard. `sysOrdersProvider` (store/courier)
is a live view of that same engine.

The live site (`/buildsmart/` and `/buildsmart/flutter/`) is unaffected by this
preview — it is an additional, isolated path.
