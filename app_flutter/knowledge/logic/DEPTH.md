# DEPTH — phase S: the shallow helpers, deepened (steps 87-90)

> DECOMP-DEPTH phase S. The Phase-L sweep opened `lib/logic/`. Phase S runs the
> **same upgraded logic decomposer** on the decision/helper modules that had only
> a shallow (single-atom, name-only) view — so every helper is now opened at
> **full depth**: object · connections · algorithm(behaviour) · contract · floor.

Read-only: the decomposer opens the helper, it never changes it.

## Helpers deepened (`state/`)

| helper | atoms | what it decides |
|---|---|---|
| `tasks_engine` | 28 | the worker task state machine + `TaskItem` methods |
| `worker_attendance` | 15 | clock-in/out + work-log derivation |
| `rbac` | 7 | role → permission decisions (`hasPermission`, `roleFromClaim`) |
| `profession_mode` | 7 | profession → mode resolution |
| `required_docs_policy` | 6 | which docs a role/profession requires |
| `org_gates` | 6 | org-feature gating (`featureOn`) |
| `push_routing` | 5 | FCM payload → in-app destination |
| `docs_readiness` | 2 | doc-completeness computation |
| `default_brand_resolver` | 1 | the fallback brand resolver |
| `finder_front` | 1 | the finder front-door helper |

**78 atoms** deepened across 10 helpers — each with an input→output contract.
Method atoms (e.g. `TaskItem.copyWith`) are opened too, not just top-level fns.

## Residuals (step 90)

The `state/` tier holds ~100 provider/notifier modules. The set above is the
**decision/algorithm helpers** — the ones whose *logic* was name-only. The
remaining modules are thin state holders (a `StateProvider` + a getter) or
Firestore repos already covered by the **async** layer's provider/exception map;
they carry no hidden algorithm to open. They are a documented residual, not a
gap: re-run `--logic <file>` on any of them on demand.

**Guards:** read-only · zero app-code change · full-depth output pinned by
`test/depth_golden_test.dart` (rbac decisions pure + contracted, tasks_engine
deep not single-atom).
