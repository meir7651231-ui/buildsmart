# Cloud Functions — deploy notes

Deployed by `.github/workflows/firebase-deploy.yml` whenever `functions/**` changes,
via the `FIREBASE_SERVICE_ACCOUNT` secret. Deploy uses `--force` so the first
2nd-gen deploy auto-creates the Artifact Registry cleanup policy.

## Requirements (project buildsmart-b0b78) — all in place 06-10
- Blaze plan (active).
- SA roles: Service Usage Consumer, Firebase Rules Admin, Cloud Functions Admin,
  Service Account User, Secret Manager Admin, Project IAM Admin (removable later).
- APIs: cloudfunctions, cloudbuild, artifactregistry, secretmanager, pubsub,
  storage, run, eventarc, cloudbilling.
- R2 config from GitHub secrets → Secret Manager (keys) + functions/.env (params).

## Note on first deploy
Event-triggered functions (onChatMessageCreated, onOrderStageChanged,
revertIllegalOrderStageWrite) may fail the very first time with a transient
Eventarc service-agent propagation delay — a retry a few minutes later succeeds.

## Functions
- `orderFlow` / `orders` — server-side stage-transition validation
- `credit` / `creditCore` — contractor credit computed server-side
- `push` — FCM triggers on stage change / new message
- `audit` — audit log for sensitive actions
- `r2` — presigned R2 upload/download URLs
