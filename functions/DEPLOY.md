# Cloud Functions — deploy notes

Deployed by `.github/workflows/firebase-deploy.yml` whenever `functions/**` changes
(and the analyze + test + tsc gate passes), via the `FIREBASE_SERVICE_ACCOUNT` secret.

## Requirements (project buildsmart-b0b78) — all in place 06-10
- **Blaze** plan (active).
- SA IAM roles: Service Usage Consumer, Firebase Rules Admin, Cloud Functions Admin,
  Service Account User, Secret Manager Admin, Project IAM Admin
  (Project IAM Admin removable after the first successful deploy).
- Enabled APIs: cloudfunctions, cloudbuild, artifactregistry, secretmanager,
  pubsub, storage, run, eventarc, **cloudbilling**.
- Service-agent bindings: auto-granted by the deploy (secretAccessor on R2 secrets, etc.).
- R2 config from GitHub secrets → Secret Manager (keys) + functions/.env.<project> (params).

## Functions
- `orderFlow` / `orders` — server-side stage-transition validation
- `credit` / `creditCore` — contractor credit computed server-side
- `push` — FCM triggers on stage change / new message
- `audit` — audit log for sensitive actions
- `r2` — presigned R2 upload/download URLs
