# Cloud Functions — deploy notes

Deployed by `.github/workflows/firebase-deploy.yml` whenever `functions/**` changes
(and the analyze + test + tsc gate passes), via the `FIREBASE_SERVICE_ACCOUNT` secret.

## Requirements (project buildsmart-b0b78)
- **Blaze** plan (active).
- Service-account IAM roles: Service Usage Consumer, Firebase Rules Admin,
  Cloud Functions Admin, Service Account User, **Secret Manager Admin**.
- Enabled APIs: cloudfunctions, cloudbuild, artifactregistry, **secretmanager** ✅ (06-10).
- R2 config injected by CI from GitHub secrets:
  - secrets → Secret Manager: `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`
  - params → `functions/.env.buildsmart-b0b78`: `R2_ACCOUNT_ID`, `R2_BUCKET=buildsmart-images`

## Functions
- `orderFlow` / `orders` — server-side stage-transition validation
- `credit` / `creditCore` — contractor credit computed server-side
- `push` — FCM triggers on stage change / new message
- `audit` — audit log for sensitive actions
- `r2` — presigned R2 upload/download URLs (needs the R2 secrets + params above)
