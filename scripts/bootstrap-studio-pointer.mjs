// P5.68 (R2-10 deploy-ordering) — ONE-TIME, IDEMPOTENT bootstrap of the Studio
// publish pointer `studioConfig/published`, run in CI *before* the rules-lock so
// the very first client `get`/listen (step 58) never hits a MISSING doc.
//
// WHY THIS EXISTS (R2-10, the last Pillar-5 hardening):
//   • The step-58 listener + step-59 snapshot-puller treat a MISSING pointer as
//     "no published config yet" and fall back to the bundled born-seed — so the
//     app is byte-identical either way. This bootstrap makes the pointer REAL so
//     (a) the revert trigger (step 57) has a version-0 baseline to compare, and
//     (b) a cold-start client reads a well-formed `{version:0, ref:null}` pointer
//     instead of an absent doc.
//   • ORDERING (R2-10 a): it must run BEFORE `firestore.rules` locks
//     `studioConfig/{channel}` to `allow write: if false` (firestore.rules:562).
//     The Admin SDK bypasses rules, so this is defense-in-depth, but the deploy
//     workflow orders it first regardless (a non-Admin seed path would be blocked
//     by the lock — the documented failure mode).
//
// SAFETY: uses `.create()` — an ATOMIC create-if-absent. If `published` already
// exists (a real publish has happened, version > 0), ALREADY_EXISTS is caught and
// the live pointer is LEFT UNTOUCHED. This script can never clobber a published
// config; it only ever seeds the empty baseline.
//
// Runs in CI with GOOGLE_APPLICATION_CREDENTIALS pointing at the deploy service
// account JSON (Application Default Credentials) — same as bootstrap-admin.mjs.
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const projectId = (process.env.GCLOUD_PROJECT || 'buildsmart-b0b78').trim();

initializeApp({ credential: applicationDefault(), projectId });
const db = getFirestore();

// The ~200B publish pointer (functions/src/studio.ts STORAGE MODEL):
//   { version, schema, ref, checksum, publishedAt, publishedBy, publishGuard }
// version:0 + ref:null is the canonical "empty baseline" — the client stays on
// the bundled born-seed (byte-identical) until a real publish flips version>0.
const seed = {
  version: 0,
  schema: 1,
  ref: null,
  checksum: null,
  publishedAt: new Date().toISOString(),
  publishedBy: 'bootstrap',
  publishGuard: `bootstrap-${process.env.GITHUB_RUN_ID || Date.now()}`,
};

const ref = db.collection('studioConfig').doc('published');

try {
  await ref.create(seed); // atomic: throws ALREADY_EXISTS (code 6) if present
  console.log('======================================================');
  console.log(`✅ Seeded studioConfig/published baseline (version:0) on ${projectId}`);
  console.log('   Clients read a well-formed empty pointer → born-seed (byte-identical).');
  console.log('======================================================');
} catch (e) {
  const already =
    (e && (e.code === 6 || e.code === 'already-exists')) ||
    /ALREADY_EXISTS/i.test(String(e && e.message));
  if (already) {
    console.log('ℹ️  studioConfig/published already exists — live pointer left UNTOUCHED (idempotent).');
  } else {
    throw e;
  }
}
