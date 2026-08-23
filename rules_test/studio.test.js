// ─────────────────────────────────────────────────────────────────────────────
// rules_test/studio.test.js — Pillar 5 · Step 65 rules-emulator suite for the
// STUDIO + AUTHORED-CATALOG blocks in /firestore.rules (studioConfig* /
// catalogProducts* / catalogPending* / catalog metadata / analytics* / presence*).
// Runs ONLY against the Firestore emulator (`npm test` under
// `firebase emulators:exec`), never the live project. @firebase/rules-unit-testing
// v4 over node's built-in runner (`node --test`) — same harness as orders.test.js /
// chat.test.js.
//
// COVERS the Step-65 §5 matrix (detail 051-068.md "Step 65" + firestore-schema.md
// §"Pillar 5"), incl. the DoD branches the spec names explicitly:
//   • studioConfig/{channel} — signed-in world-READ (published + the co-located
//     publishAllow flag, uniform because the step-58 client listens to the WHOLE
//     collection and "rules are not filters"); WRITE `if false` for everyone
//     (callable-only, step 56) — even a manager/owner direct write is DENIED.
//   • studioConfigSnapshots — a published `v<N>` is world-READ + IMMUTABLE (no
//     client write); a `draft-<uid>` is OWNER read+write, manager-READable, and a
//     NON-owner is denied read AND write (owner-write config, R-spec §5); the
//     `/shards` subcollection inherits the parent gate, writes Admin-SDK-only.
//   • catalogProducts/{sku} — signed-in world-READ (priceless public doc),
//     manager/owner WRITE, non-manager denied; the price sub-doc
//     `pricing/{audience}` is CLAIM-GATED read (`isManager() || hasRole(audience)`)
//     so a competitor store reading the contractor price is DENIED (R1-6).
//   • catalogPending — manager/owner only. catalogTrades/Categories — signed-in
//     read, manager write. catalogTokenFreq — signed-in read, client write denied.
//   • analyticsEvents — create-as-SELF only (no actor spoofing), manager-READ,
//     immutable (update/delete denied). presence — self-write, manager/self read.
//   • presenceSummary / analyticsDaily / analyticsCounters — manager-READ,
//     `if false` write (server-rolled, R1-3).
//
// A DISTINCT project id isolates this suite's emulator namespace from the sibling
// suites (`node --test` runs files in parallel; a shared namespace would let one
// file's beforeEach clearFirestore() wipe another's seed). SEEDING uses
// withSecurityRulesDisabled (the admin escape hatch) to plant state a rules-bound
// client could not itself create, then asserts through a rules-bound client.
// ─────────────────────────────────────────────────────────────────────────────

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { after, before, beforeEach, describe, it } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'demo-buildsmart-studio';

// The app OWNER's verified email — must match firestore.rules isOwnerEmail() and
// functions/src/common.ts OWNER_EMAIL (the Google ID-token delivers it lower-cased,
// so the rule is a direct literal compare).
const OWNER_EMAIL = 'meir7651231@gmail.com';

/** Custom-claim / token shapes the setRole callable + Google auth deliver. */
const asContractor = () => ({ role: 'contractor' });
const asStore = () => ({ role: 'store' });
const asManager = () => ({ role: 'manager' });
const asAdmin = () => ({ admin: true });
// The OWNER-by-email: signed-in, carries the verified `email` token field, and —
// deliberately — NO role claim (owner authority is independent of role, step 56).
const asOwner = () => ({ email: OWNER_EMAIL });

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(join(__dirname, '..', 'firestore.rules'), 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

/** Plant a doc with rules DISABLED — seed state a rules-bound client couldn't. */
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

/** A Firestore handle authed as the given uid + claims/token. */
function db(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

// ── studioConfig/{channel} — publish pointer: signed-in READ, callable-only WRITE
describe('studioConfig · signed-in read, write if false (callable-only, step 56)', () => {
  it('any signed-in client READS the published pointer (the step-58 cache-bust signal)', async () => {
    await seed('studioConfig/published', { version: 7, schema: 1, ref: 'v7' });
    await assertSucceeds(getDoc(doc(db('uid-a', asContractor()), 'studioConfig/published')));
    await assertSucceeds(getDoc(doc(db('uid-s', asStore()), 'studioConfig/published')));
  });

  it('the co-located publishAllow flag is ALSO signed-in-readable (uniform gate — whole-collection listen)', async () => {
    await seed('studioConfig/publishAllow', { enabled: true });
    // Uniform read is what lets a non-manager listen to the WHOLE studioConfig
    // collection (rules are not filters) — a mixed gate would deny the fan-out.
    await assertSucceeds(getDoc(doc(db('uid-a', asContractor()), 'studioConfig/publishAllow')));
  });

  it('an UNAUTHENTICATED client is DENIED the published pointer', async () => {
    await seed('studioConfig/published', { version: 7, schema: 1 });
    const anon = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, 'studioConfig/published')));
  });

  it('NOBODY writes studioConfig/published from a client — manager DENIED (callable-only)', async () => {
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'studioConfig/published'), { version: 8 }),
    );
  });

  it('NOBODY writes studioConfig/published from a client — OWNER DENIED (callable-only)', async () => {
    // Even the authority-root owner publishes via the callable, never a direct write.
    await assertFails(
      setDoc(doc(db('uid-owner', asOwner()), 'studioConfig/published'), { version: 8 }),
    );
  });
});

// ── studioConfigSnapshots — immutable v<N> (world-read) + draft-<uid> (owner) ──
describe('studioConfigSnapshots · published v<N> immutable + draft owner-scoped', () => {
  it('a published v<N> snapshot is signed-in READ (any client pulls it)', async () => {
    await seed('studioConfigSnapshots/v7', { version: 7, frozenBy: 'uid-mgr' });
    await assertSucceeds(getDoc(doc(db('uid-a', asContractor()), 'studioConfigSnapshots/v7')));
  });

  it('a published v<N> snapshot is IMMUTABLE — manager/owner write DENIED', async () => {
    await seed('studioConfigSnapshots/v7', { version: 7 });
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'studioConfigSnapshots/v7'), { version: 7, x: 1 }),
    );
    await assertFails(
      setDoc(doc(db('uid-owner', asOwner()), 'studioConfigSnapshots/v7'), { version: 7, x: 1 }),
    );
  });

  it("the OWNER writes + reads their own draft (draft-<uid>, the step-55 sink target)", async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice', asContractor()), 'studioConfigSnapshots/draft-uid-alice'), {
        version: 0,
        schema: 1,
      }),
    );
    await assertSucceeds(
      getDoc(doc(db('uid-alice', asContractor()), 'studioConfigSnapshots/draft-uid-alice')),
    );
  });

  it('a NON-owner is DENIED reading another user\'s draft', async () => {
    await seed('studioConfigSnapshots/draft-uid-alice', { version: 0 });
    await assertFails(
      getDoc(doc(db('uid-bob', asContractor()), 'studioConfigSnapshots/draft-uid-alice')),
    );
  });

  it('a MANAGER may READ any draft (draft config is manager-scoped)', async () => {
    await seed('studioConfigSnapshots/draft-uid-alice', { version: 0 });
    await assertSucceeds(
      getDoc(doc(db('uid-mgr', asManager()), 'studioConfigSnapshots/draft-uid-alice')),
    );
  });

  it('a NON-owner CANNOT write another user\'s draft (owner-write only)', async () => {
    await seed('studioConfigSnapshots/draft-uid-alice', { version: 0 });
    // bob (even a manager) may not WRITE alice's working draft — the id encodes the owner.
    await assertFails(
      setDoc(doc(db('uid-bob', asContractor()), 'studioConfigSnapshots/draft-uid-alice'), {
        version: 1,
      }),
    );
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'studioConfigSnapshots/draft-uid-alice'), {
        version: 1,
      }),
    );
  });

  it('a published snapshot\'s /shards are signed-in READ + write-DENIED (Admin-SDK only)', async () => {
    await seed('studioConfigSnapshots/v7/shards/0', { n: 0, data: '{"global":{}}' });
    await assertSucceeds(
      getDoc(doc(db('uid-a', asContractor()), 'studioConfigSnapshots/v7/shards/0')),
    );
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'studioConfigSnapshots/v7/shards/1'), { n: 1 }),
    );
  });
});

// ── studioConfigApprovals — dual-control (manager/owner only) ─────────────────
describe('studioConfigApprovals · dual-control approval (manager/owner only)', () => {
  it('a manager WRITES + READS an approval; a contractor is DENIED', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-mgr2', asManager()), 'studioConfigApprovals/draft-uid-mgr1'), {
        approved: true,
        approvedBy: 'uid-mgr2',
      }),
    );
    await assertSucceeds(
      getDoc(doc(db('uid-mgr2', asManager()), 'studioConfigApprovals/draft-uid-mgr1')),
    );
    await assertFails(
      getDoc(doc(db('uid-c', asContractor()), 'studioConfigApprovals/draft-uid-mgr1')),
    );
    await assertFails(
      setDoc(doc(db('uid-c', asContractor()), 'studioConfigApprovals/draft-uid-mgr1'), {
        approved: true,
        approvedBy: 'uid-c',
      }),
    );
  });
});

// ── _publishRate — server-internal rate ledger (no client access) ─────────────
describe('_publishRate · Admin-SDK only (client read+write denied)', () => {
  it('a client (even a manager) can neither read nor reset its own rate window', async () => {
    await seed('_publishRate/uid-mgr', { count: 5, windowStart: 1 });
    await assertFails(getDoc(doc(db('uid-mgr', asManager()), '_publishRate/uid-mgr')));
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), '_publishRate/uid-mgr'), { count: 0 }),
    );
  });
});

// ── catalogProducts — priceless public doc + role-scoped price sub-doc (R1-6) ──
describe('catalogProducts · public read, manager/owner write, price sub-doc claim-gated (R1-6)', () => {
  it('any signed-in client READS the priceless public product doc', async () => {
    await seed('catalogProducts/SKU-1', { sku: 'SKU-1', nameHe: 'כבל', active: true });
    await assertSucceeds(getDoc(doc(db('uid-c', asContractor()), 'catalogProducts/SKU-1')));
    await assertSucceeds(getDoc(doc(db('uid-s', asStore()), 'catalogProducts/SKU-1')));
  });

  it('a MANAGER and the OWNER may author a product; a contractor is DENIED', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'catalogProducts/SKU-2'), {
        sku: 'SKU-2',
        nameHe: 'מפסק',
        active: true,
      }),
    );
    await assertSucceeds(
      setDoc(doc(db('uid-owner', asOwner()), 'catalogProducts/SKU-3'), {
        sku: 'SKU-3',
        nameHe: 'שקע',
        active: true,
      }),
    );
    await assertFails(
      setDoc(doc(db('uid-c', asContractor()), 'catalogProducts/SKU-4'), {
        sku: 'SKU-4',
        nameHe: 'זיוף',
        active: true,
      }),
    );
  });

  it('the contractor READS its OWN audience price (pricing/contractor)', async () => {
    await seed('catalogProducts/SKU-1/pricing/contractor', { price: 1200, currency: 'ILS' });
    await assertSucceeds(
      getDoc(doc(db('uid-c', asContractor()), 'catalogProducts/SKU-1/pricing/contractor')),
    );
  });

  it('a COMPETITOR store is DENIED the contractor price (R1-6 — price is not world)', async () => {
    await seed('catalogProducts/SKU-1/pricing/contractor', { price: 1200 });
    // A store holds no `contractor` role → cannot read the contractor-audience price.
    await assertFails(
      getDoc(doc(db('uid-s', asStore()), 'catalogProducts/SKU-1/pricing/contractor')),
    );
  });

  it('a MANAGER reads ANY audience price; only manager/owner WRITE a price', async () => {
    await seed('catalogProducts/SKU-1/pricing/contractor', { price: 1200 });
    await assertSucceeds(
      getDoc(doc(db('uid-mgr', asManager()), 'catalogProducts/SKU-1/pricing/contractor')),
    );
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'catalogProducts/SKU-1/pricing/store'), {
        price: 1500,
      }),
    );
    // A store cannot SET even its OWN audience price (authoring is manager/owner).
    await assertFails(
      setDoc(doc(db('uid-s', asStore()), 'catalogProducts/SKU-1/pricing/store'), { price: 1 }),
    );
  });
});

// ── catalogPending — seed staging (manager/owner only) ────────────────────────
describe('catalogPending · seed staging (manager/owner only, R2-9)', () => {
  it('a manager reads+writes the staging batch + items; a contractor is DENIED', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'catalogPending/seed'), { cursor: 'SKU-9' }),
    );
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'catalogPending/seed/items/SKU-9'), {
        sku: 'SKU-9',
      }),
    );
    await assertFails(
      getDoc(doc(db('uid-c', asContractor()), 'catalogPending/seed')),
    );
    await assertFails(
      setDoc(doc(db('uid-c', asContractor()), 'catalogPending/seed/items/SKU-9'), { sku: 'x' }),
    );
  });
});

// ── catalog metadata + token-freq ─────────────────────────────────────────────
describe('catalog metadata · signed-in read, manager write; tokenFreq server-only write', () => {
  it('catalogTrades/Categories — signed-in READ, manager WRITE, contractor write DENIED', async () => {
    await seed('catalogTrades/electric', { nameHe: 'חשמל', active: true });
    await assertSucceeds(getDoc(doc(db('uid-c', asContractor()), 'catalogTrades/electric')));
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'catalogCategories/cables'), { nameHe: 'כבלים' }),
    );
    await assertFails(
      setDoc(doc(db('uid-c', asContractor()), 'catalogTrades/electric'), { nameHe: 'x' }),
    );
  });

  it('catalogTokenFreq — signed-in READ, client WRITE denied (Admin-SDK indexer owns it)', async () => {
    await seed('catalogTokenFreq/כבל', { count: 42 });
    await assertSucceeds(getDoc(doc(db('uid-c', asContractor()), 'catalogTokenFreq/כבל')));
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'catalogTokenFreq/כבל'), { count: 0 }),
    );
  });
});

// ── analyticsEvents — append-only, create-as-self, manager-read ───────────────
describe('analyticsEvents · create-as-self, manager-read, immutable (S5.8 blocked)', () => {
  it('CREATE as yourself (uid == auth.uid) → allowed', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice', asContractor()), 'analyticsEvents/e-1'), {
        name: 'order_placed',
        uid: 'uid-alice',
        at: '2026-07-07T10:00:00.000',
        day: '2026-07-07',
      }),
    );
  });

  it('CREATE spoofing another actor (uid != auth.uid) → denied', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'analyticsEvents/e-2'), {
        name: 'order_placed',
        uid: 'uid-bob', // not the caller
        at: '2026-07-07T10:00:00.000',
      }),
    );
  });

  it('READ is manager-only — a contractor is DENIED, a manager allowed', async () => {
    await seed('analyticsEvents/e-3', { name: 'x', uid: 'uid-alice', day: '2026-07-07' });
    await assertFails(getDoc(doc(db('uid-alice', asContractor()), 'analyticsEvents/e-3')));
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'analyticsEvents/e-3')));
  });

  it('events are IMMUTABLE — update + delete denied even for a manager', async () => {
    await seed('analyticsEvents/e-4', { name: 'x', uid: 'uid-alice' });
    await assertFails(
      updateDoc(doc(db('uid-mgr', asManager()), 'analyticsEvents/e-4'), { name: 'edited' }),
    );
    await assertFails(deleteDoc(doc(db('uid-mgr', asManager()), 'analyticsEvents/e-4')));
  });
});

// ── presence — self-write, manager/self read ─────────────────────────────────
describe('presence · self-write, manager/self read (R1-3)', () => {
  it('a user writes ONLY its own presence doc; a foreign write is denied', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice', asContractor()), 'presence/uid-alice'), {
        online: true,
        lastSeen: '2026-07-07T10:00:00.000',
      }),
    );
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'presence/uid-bob'), { online: true }),
    );
  });

  it('READ is manager or self — a foreign non-manager is DENIED', async () => {
    await seed('presence/uid-bob', { online: true });
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'presence/uid-bob')));
    await assertSucceeds(getDoc(doc(db('uid-bob', asContractor()), 'presence/uid-bob')));
    await assertFails(getDoc(doc(db('uid-alice', asContractor()), 'presence/uid-bob')));
  });
});

// ── presenceSummary / analyticsDaily / analyticsCounters — manager-read, server-write
describe('server-rolled summaries · manager-read, if-false write (R1-3)', () => {
  it('presenceSummary/current — manager READ ok, contractor denied, client write denied', async () => {
    await seed('presenceSummary/current', { count: 12, updatedAt: '2026-07-07T10:00:00.000' });
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'presenceSummary/current')));
    await assertFails(getDoc(doc(db('uid-c', asContractor()), 'presenceSummary/current')));
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'presenceSummary/current'), { count: 0 }),
    );
  });

  it('analyticsDaily/{day} — manager READ ok, contractor denied, client write denied', async () => {
    await seed('analyticsDaily/2026-07-07', { counts: { order_placed: 3 } });
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'analyticsDaily/2026-07-07')));
    await assertFails(getDoc(doc(db('uid-c', asContractor()), 'analyticsDaily/2026-07-07')));
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'analyticsDaily/2026-07-07'), { counts: {} }),
    );
  });

  it('analyticsCounters/{metric}/shards/{n} — admin READ ok, client write denied', async () => {
    await seed('analyticsCounters/order_placed/shards/3', { count: 7 });
    await assertSucceeds(
      getDoc(doc(db('uid-root', asAdmin()), 'analyticsCounters/order_placed/shards/3')),
    );
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'analyticsCounters/order_placed/shards/4'), {
        count: 1,
      }),
    );
  });
});
