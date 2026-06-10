# Cloud Functions — deploy notes

Deployed by `.github/workflows/firebase-deploy.yml` whenever `functions/**` changes
(and the analyze + test + tsc gate passes), via the `FIREBASE_SERVICE_ACCOUNT` secret.

## Requirements (project buildsmart-b0b78)
- **Blaze** plan (active) — Cloud Functions are not available on Spark.
- Service-account IAM roles (granted in GCP IAM):
  - Service Usage Consumer
  - Firebase Rules Admin
  - **Cloud Functions Admin**
  - **Service Account User**
- Required Google APIs enabled by the project owner (06-10): **artifactregistry**,
  **cloudfunctions**, **cloudbuild** ✅
- **R2 secrets** for `src/r2.ts` presign — set via
  `firebase functions:secrets:set <NAME>` (or GCP Secret Manager) before/at deploy.

## Functions
- `orderFlow` / `orders` — server-side stage-transition validation
- `credit` / `creditCore` — contractor credit computed server-side
- `push` — FCM triggers on stage change / new message
- `audit` — audit log for sensitive actions
- `r2` — presigned R2 upload/download URLs (needs the R2 secrets)
