#!/usr/bin/env node
// backfill_user_status.js — the USER-SYSTEM ACTIVATION migration. Stamps
// status:'active' on every EXISTING users/{uid} that has NO status field, so
// pre-user-system accounts are NOT read as 'pending' once USER_SYSTEM is turned
// on. (BsUser.fromWire decodes a MISSING status as `pending` — the all-by-approval
// safe default — which is correct for NEW registrations, but would wrongly flag
// every grandfathered user. This backfill marks the existing users active so only
// genuinely-new registrations — which write status:'pending' EXPLICITLY — stay
// pending.)
//
// SAFE + IDEMPOTENT: only touches docs MISSING a status; never overwrites an
// explicit pending/active/suspended. merge:true. A re-run is a no-op.
//
// AUTH (owner-provided; never seen here): a service-account key via
// GOOGLE_APPLICATION_CREDENTIALS, or application-default creds. Run:
//   node backfill_user_status.js --project buildsmart-b0b78 [--dry-run]
// --dry-run touches NO credentials and neither reads nor writes — it only prints
// what the real run does (mirrors upload_seed.js's credential-free dry-run).

function argVal(flag) {
  const i = process.argv.indexOf(flag);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

const projectId = argVal('--project') || process.env.GCLOUD_PROJECT;
const dryRun = process.argv.includes('--dry-run');

if (!projectId) {
  console.error('usage: node backfill_user_status.js --project <id> [--dry-run]');
  process.exit(1);
}

(async () => {
  if (dryRun) {
    console.log('[dry-run] backfill_user_status would (no creds, nothing read/written):');
    console.log('  • read every users/{uid} doc;');
    console.log('  • set status:"active" (merge) on each doc that has NO status field;');
    console.log('  • leave any doc with an explicit status (pending/active/suspended) untouched.');
    process.exit(0);
  }

  const admin = require('firebase-admin');
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId,
  });
  const db = admin.firestore();

  const snap = await db.collection('users').get();
  let scanned = 0;
  let hadStatus = 0;
  let backfilled = 0;
  let batch = db.batch();
  let pending = 0;

  for (const doc of snap.docs) {
    scanned++;
    const data = doc.data() || {};
    if (typeof data.status === 'string' && data.status.length > 0) {
      hadStatus++;
      continue; // already carries an explicit status — never overwrite it
    }
    batch.set(doc.ref, { status: 'active' }, { merge: true });
    backfilled++;
    pending++;
    if (pending >= 400) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
  if (pending > 0) await batch.commit();

  console.log(
    `DONE — scanned ${scanned} users · already had status: ${hadStatus} · ` +
      `backfilled to active: ${backfilled}`
  );
  process.exit(0);
})().catch((e) => {
  console.error('backfill failed:', e.message);
  process.exit(1);
});
