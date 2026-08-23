# Firestore seed — catalog-to-server (C1 slice → C2 full)

Writes the bundled catalog data to the **real** Firebase project so the app can read
it from the server. The bundle is produced by the Flutter exporter using the SAME
`toDoc` / `verifiedSpecToDoc` / store+inventory serializers the app reads with — so
what we seed is byte-for-byte what the app expects.

**Seeding is safe to do first:** the app only READS from the server when the
`useServerCatalog` switch is ON (still OFF). So the data sits there, unused, until we
deliberately flip the read — nothing users see changes.

## What the OWNER does (the part I can't — your credentials)

Pick ONE auth path:

**A — service-account key (simplest one-shot):**
1. Firebase console → `buildsmart-b0b78` → Project settings → **Service accounts** →
   **Generate new private key** → save the file locally (e.g. `~/sa.json`). Keep it secret.
2. Tell me the file path. I run the upload pointing at it — I never see the key contents.

**B — gcloud application-default:**
1. `gcloud auth application-default login` (browser sign-in — your credentials).
2. I run the upload with the ambient credentials.

## What I run (once you've done the above)

```bash
cd scripts/seed
npm install                       # installs firebase-admin (once)

# DRY RUN first — prints counts, writes NOTHING:
node upload_seed.js firestore_seed_slice.json --project buildsmart-b0b78 --dry-run

# Then the real write (path A shown):
GOOGLE_APPLICATION_CREDENTIALS=~/sa.json \
  node upload_seed.js firestore_seed_slice.json --project buildsmart-b0b78
```

Idempotent (doc-id keyed, merge) — a re-run updates, never duplicates.

## Bundles
- `firestore_seed_slice.json` — the 20-SKU slice + 2 stores + 40 inventory + specs
  (the safe first seed).
- The full-catalog bundle (all ~1,879) is regenerated the same way when we scale up.

## Security rules
Before the app READS this live, deploy rules that make `catalogProducts` /
`verified_specs` / `recipes` / `stores` world-readable and `inventory` writable only by
its owning store (C0.4 / C5.3). The admin seed above bypasses rules (server-side); the
CLIENT read needs them open.
