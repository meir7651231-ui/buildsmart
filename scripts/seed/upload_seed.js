#!/usr/bin/env node
// upload_seed.js — write a Firestore seed bundle (from the Flutter exporter) to the
// real project, via firebase-admin (server-side, bypasses security rules for a
// one-shot admin seed). Idempotent: doc-id keyed, merge:true → a re-run updates, never
// duplicates. Batched (≤400/commit).
//
// The bundle is the EXACT shape the app reads (produced by the proven Dart toDoc /
// verifiedSpecToDoc / store+inventory serializers) — top-level keys are collection
// names, each a { docId: fieldMap } object.
//
// AUTH (you provide — I never see the secret): either
//   A) a service-account key file:
//        GOOGLE_APPLICATION_CREDENTIALS=/path/serviceAccount.json \
//        node upload_seed.js <bundle.json> --project buildsmart-b0b78
//   B) application-default creds (after `gcloud auth application-default login`):
//        node upload_seed.js <bundle.json> --project buildsmart-b0b78
//
// Add --dry-run to print counts WITHOUT writing (a safe preview).

const fs = require('fs');

function argVal(flag) {
  const i = process.argv.indexOf(flag);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

const bundlePath = process.argv[2];
const projectId = argVal('--project') || process.env.GCLOUD_PROJECT;
const dryRun = process.argv.includes('--dry-run');

if (!bundlePath || bundlePath.startsWith('--')) {
  console.error('usage: node upload_seed.js <bundle.json> --project <id> [--dry-run]');
  process.exit(1);
}

const bundle = JSON.parse(fs.readFileSync(bundlePath, 'utf8'));

let admin;
if (!dryRun) {
  admin = require('firebase-admin'); // lazy — dry-run needs no install/creds
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: projectId,
  });
}
const db = dryRun ? null : admin.firestore();

(async () => {
  let total = 0;
  for (const [collection, docs] of Object.entries(bundle)) {
    const ids = Object.keys(docs);
    if (dryRun) {
      console.log(`[dry-run] ${collection}: ${ids.length} docs`);
      total += ids.length;
      continue;
    }
    let batch = db.batch();
    let pending = 0;
    let wrote = 0;
    for (const id of ids) {
      batch.set(db.collection(collection).doc(id), docs[id], { merge: true });
      pending++;
      wrote++;
      if (pending >= 400) {
        await batch.commit();
        batch = db.batch();
        pending = 0;
      }
    }
    if (pending > 0) await batch.commit();
    console.log(`${collection}: wrote ${wrote} docs`);
    total += wrote;
  }
  console.log(`${dryRun ? '[dry-run] would write' : 'DONE — wrote'} ${total} docs total`);
  process.exit(0);
})().catch((e) => {
  console.error('upload failed:', e.message);
  process.exit(1);
});
