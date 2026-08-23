// ─────────────────────────────────────────────────────────────────────────────
// rules_test/orders.test.js — launch Phase G (G3) rules-emulator suite for the
// OWNERSHIP hardening in /firestore.rules. Runs ONLY against the Firestore
// emulator (`npm run test:emulator` boots it via firebase.json → firestore.rules),
// never the live project. Written with @firebase/rules-unit-testing v4/v5 over
// node's built-in runner (`node --test`) — no mocha/jest, per rules_test/README.md.
//
// COVERS (the Phase-G ask + the correctness fix it validates):
//   • orders ownership keys on the LANDED `contractorUid` (uid-A3), NOT the
//     display-name `contractorId`:
//       – a contractor reads/creates ONLY their own orders (contractorUid==uid);
//       – a manager reads ALL orders (god-role override);
//       – a NON-OWNER contractor is DENIED another contractor's order;
//       – an order whose contractorUid is a NAME / empty (pre-A3, seed) is owner-
//         unmatched but manager-readable (backward tolerance);
//       – create is bound to contractorUid==uid (no creating in another's name);
//         a create that puts contractorId (the name field) == uid but a foreign
//         contractorUid is STILL denied (proves the name field gates nothing).
//   • customers ownership: manager reads all + writes; owner (ownerId==uid) reads;
//     a non-owner / store is DENIED; non-manager write is denied.
//
// SEEDING uses withSecurityRulesDisabled (the v4/v5 admin escape hatch) so a doc
// can be planted regardless of rules, then asserted through a rules-bound client.
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
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'demo-buildsmart';

/** Custom-claim shapes the setRole callable writes (functions/src/index.ts):
 *  single `role`, multi `roles`, plus the bootstrap `admin`. */
const asContractor = (uid) => ({ role: 'contractor' });
const asStore = (uid) => ({ role: 'store' });
const asCourier = (uid) => ({ role: 'courier' });
const asManager = () => ({ role: 'manager' });
const asAdmin = () => ({ admin: true });

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

/** Plant a doc with rules DISABLED (admin escape hatch) — the only way to seed
 *  state a rules-bound client could not itself create. */
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

/** A Firestore handle authed as the given uid + claims. */
function db(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

// ── orders — ownership on contractorUid (the LANDED A3 field) ────────────────

describe('orders · ownership keys on contractorUid (not the display-name contractorId)', () => {
  it('contractor READS their own order (contractorUid == uid)', async () => {
    await seed('orders/BS-1', {
      contractorId: 'יוסי קבלן', // display name — must NOT be the gate
      contractorUid: 'uid-alice',
      stage: 'new',
      sum: 100,
    });
    await assertSucceeds(getDoc(doc(db('uid-alice', asContractor()), 'orders/BS-1')));
  });

  it('contractor is DENIED another contractor\'s order (foreign contractorUid)', async () => {
    await seed('orders/BS-2', {
      contractorId: 'יוסי קבלן',
      contractorUid: 'uid-alice',
      stage: 'new',
      sum: 100,
    });
    // bob is a real contractor but does not own BS-2.
    await assertFails(getDoc(doc(db('uid-bob', asContractor()), 'orders/BS-2')));
  });

  it('a NAME in contractorUid never matches a uid — owner-unmatched (backward tolerance)', async () => {
    // A pre-A3 / mis-stamped doc whose contractorUid carries a NAME, not a uid.
    await seed('orders/BS-3', {
      contractorId: 'יוסי קבלן',
      contractorUid: 'יוסי קבלן', // a name, not a uid
      stage: 'new',
      sum: 100,
    });
    await assertFails(getDoc(doc(db('uid-alice', asContractor()), 'orders/BS-3')));
  });

  it('an order with NO contractorUid (legacy/seed) is owner-unmatched but manager-readable', async () => {
    await seed('orders/BS-4', {
      contractorId: 'יוסי קבלן', // legacy: only the name, no uid field
      stage: 'new',
      sum: 100,
    });
    // No contractor owns it (no uid to match) …
    await assertFails(getDoc(doc(db('uid-alice', asContractor()), 'orders/BS-4')));
    // … but the manager still reads it (backward-tolerant — no hard break).
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'orders/BS-4')));
  });

  it('manager READS ALL orders (god-role override)', async () => {
    await seed('orders/BS-5', { contractorUid: 'uid-alice', stage: 'transit', sum: 9 });
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'orders/BS-5')));
  });

  it('admin (bootstrap claim) READS any order too', async () => {
    await seed('orders/BS-6', { contractorUid: 'uid-alice', stage: 'new', sum: 9 });
    await assertSucceeds(getDoc(doc(db('uid-root', asAdmin()), 'orders/BS-6')));
  });
});

describe('orders · create is bound to contractorUid == uid', () => {
  // APPROVAL IS NOW A PRECONDITION OF ORDERING, so this suite's contractor needs
  // an approved users doc before the ownership assertions below mean anything.
  //
  // This seed is the visible half of a deliberate contract change. The test
  // immediately below used to pass with no users doc at all, because the rule
  // asked only `isSignedIn()` — and that permissiveness WAS the bug: an
  // unapproved account's order reached the store and courier boards looking
  // exactly like an approved one. The old assertion is not being silenced; it
  // is being corrected, and its former behaviour is now pinned as a DENIAL in
  // approval.test.js ("a PENDING account may NOT place an order").
  beforeEach(async () => {
    await seed('users/uid-alice', { displayName: 'יוסי קבלן', status: 'active' });
  });

  it('contractor CREATES their own new order (contractorUid == uid, stage new)', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice', asContractor()), 'orders/BS-new-1'), {
        contractorId: 'יוסי קבלן',
        contractorUid: 'uid-alice',
        stage: 'new',
        sum: 250,
      }),
    );
  });

  it('and the SAME contractor is denied the moment approval is withdrawn', async () => {
    // Suspension has to bite immediately: the ceiling on a rules `get()` is the
    // write itself, not a token lifetime, which is the whole reason the status
    // is read from the document rather than mirrored into a claim.
    await seed('users/uid-alice', { displayName: 'יוסי קבלן', status: 'suspended' });
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'orders/BS-new-1b'), {
        contractorId: 'יוסי קבלן',
        contractorUid: 'uid-alice',
        stage: 'new',
        sum: 250,
      }),
    );
  });

  it('contractor CANNOT create an order in another uid\'s name (foreign contractorUid)', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'orders/BS-new-2'), {
        contractorId: 'יוסי קבלן',
        contractorUid: 'uid-bob', // someone else's uid
        stage: 'new',
        sum: 250,
      }),
    );
  });

  it('a create that puts the NAME field (contractorId) == uid but a foreign contractorUid is STILL denied', async () => {
    // Proves the gate is contractorUid, not contractorId: even if a client tried
    // to satisfy the old name-based rule, the uid binding blocks it.
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'orders/BS-new-3'), {
        contractorId: 'uid-alice', // the name field set to look like the uid
        contractorUid: 'uid-bob', // real owner field points elsewhere
        stage: 'new',
        sum: 250,
      }),
    );
  });

  it('contractor CANNOT create at a non-head stage', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'orders/BS-new-4'), {
        contractorUid: 'uid-alice',
        stage: 'delivered', // not the flow head
        sum: 250,
      }),
    );
  });

  it('manager may create at any legal stage', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'orders/BS-new-5'), {
        contractorId: 'יוסי קבלן',
        stage: 'ready', // god-create at any legal stage
        sum: 250,
      }),
    );
  });

  it('manager CANNOT create at a bogus stage', async () => {
    await assertFails(
      setDoc(doc(db('uid-mgr', asManager()), 'orders/BS-new-6'), {
        stage: 'teleported', // not in orderStages()
        sum: 250,
      }),
    );
  });
});

// ── customers — credit ownership (manager / owner only) ──────────────────────

describe('customers · ownership (manager-or-owner read, manager-only write)', () => {
  it('manager READS any customer + WRITES', async () => {
    await seed('customers/acme', { name: 'acme', creditLimit: 50000, used: 10000 });
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'customers/acme')));
    await assertSucceeds(
      setDoc(doc(db('uid-mgr', asManager()), 'customers/acme'), {
        name: 'acme',
        creditLimit: 60000,
        used: 10000,
      }),
    );
  });

  it('owner (ownerId == uid) READS their own customer record (forward-ready)', async () => {
    await seed('customers/bob-co', {
      name: 'bob-co',
      creditLimit: 30000,
      used: 5000,
      ownerId: 'uid-bob',
    });
    await assertSucceeds(getDoc(doc(db('uid-bob', asContractor()), 'customers/bob-co')));
  });

  it('a NON-owner is DENIED a customer record', async () => {
    await seed('customers/bob-co', {
      name: 'bob-co',
      creditLimit: 30000,
      used: 5000,
      ownerId: 'uid-bob',
    });
    await assertFails(getDoc(doc(db('uid-alice', asContractor()), 'customers/bob-co')));
  });

  it('a customer with NO ownerId is manager-only (store/contractor denied — backward tolerance)', async () => {
    await seed('customers/legacy', { name: 'legacy', creditLimit: 40000, used: 0 });
    await assertFails(getDoc(doc(db('uid-store', asStore()), 'customers/legacy')));
    await assertFails(getDoc(doc(db('uid-alice', asContractor()), 'customers/legacy')));
    await assertSucceeds(getDoc(doc(db('uid-mgr', asManager()), 'customers/legacy')));
  });

  it('a store/contractor CANNOT write a customer (credit is manager-only)', async () => {
    await assertFails(
      setDoc(doc(db('uid-store', asStore()), 'customers/x'), {
        name: 'x',
        creditLimit: 999999, // cannot raise own limit
        used: 0,
      }),
    );
  });
});

// ── orders — A4/A5 claim-on-first-advance + shared pool (no-steal) ────────────
//
// The launch multi-user core (SPEC-A4-A6-order-ownership): an un-claimed order
// in a store/courier stage is the SHARED POOL — readable by every store/courier
// of that role; the FIRST to advance it CLAIMS it (storeUid/courierUid = its
// auth.uid). After that the order leaves the pool: only the claimant (+ manager)
// reads/updates it, and NO other party can re-stamp the field (no-steal) — a
// manager may REASSIGN. These tests drive the real /firestore.rules through
// rules-bound clients; claims/advances use updateDoc (the app's set(merge:true)
// partial write — stage[+the claim field]).
describe('orders · A4 claim-on-first-advance + shared pool (no-steal)', () => {
  // (pool read) every store reads an UN-CLAIMED order in a store stage.
  it('a store READS an un-claimed pool order (storeUid=="" in a store stage)', async () => {
    await seed('orders/POOL-1', {
      contractorId: 'יוסי קבלן',
      contractorUid: 'uid-alice',
      stage: 'new', // a store pool stage, storeUid absent ⇒ ''
      sum: 100,
    });
    await assertSucceeds(getDoc(doc(db('uid-store-a', asStore()), 'orders/POOL-1')));
    await assertSucceeds(getDoc(doc(db('uid-store-b', asStore()), 'orders/POOL-1')));
  });

  // (claim-unclaimed ✓) a store CLAIMS an un-claimed pool order on first advance.
  it('a store CLAIMS an un-claimed order on first advance (new→preparing, storeUid:=self)', async () => {
    await seed('orders/CLAIM-1', {
      contractorUid: 'uid-alice',
      stage: 'new',
      sum: 100,
    });
    await assertSucceeds(
      updateDoc(doc(db('uid-store-a', asStore()), 'orders/CLAIM-1'), {
        stage: 'preparing',
        storeUid: 'uid-store-a', // the claim — empty→own
      }),
    );
  });

  // (steal-claimed ✗) a DIFFERENT store cannot advance/steal a claimed order.
  it('a different store CANNOT steal an order already claimed by another store', async () => {
    await seed('orders/CLAIM-2', {
      contractorUid: 'uid-alice',
      stage: 'preparing',
      storeUid: 'uid-store-a', // already claimed by store-a
      sum: 100,
    });
    // store-b tries to advance + re-stamp the claim to itself → DENIED (binding).
    await assertFails(
      updateDoc(doc(db('uid-store-b', asStore()), 'orders/CLAIM-2'), {
        stage: 'ready',
        storeUid: 'uid-store-b',
      }),
    );
    // …and even leaving storeUid untouched, store-b is not the owner → DENIED.
    await assertFails(
      updateDoc(doc(db('uid-store-b', asStore()), 'orders/CLAIM-2'), {
        stage: 'ready',
      }),
    );
  });

  // (owner read/update ✓) the claiming store reads + advances its own order.
  it('the owning store READS and ADVANCES its own claimed order', async () => {
    await seed('orders/CLAIM-3', {
      contractorUid: 'uid-alice',
      stage: 'preparing',
      storeUid: 'uid-store-a',
      sum: 100,
    });
    await assertSucceeds(getDoc(doc(db('uid-store-a', asStore()), 'orders/CLAIM-3')));
    await assertSucceeds(
      updateDoc(doc(db('uid-store-a', asStore()), 'orders/CLAIM-3'), {
        stage: 'ready', // preparing→ready, own claim unchanged
      }),
    );
  });

  // (non-owner read claimed ✗) a store NOT the claimant cannot read a claimed
  // order that has left the pool.
  it('a non-owner store is DENIED reading an order claimed by another store (left the pool)', async () => {
    await seed('orders/CLAIM-4', {
      contractorUid: 'uid-alice',
      stage: 'preparing', // claimed ⇒ NOT in the pool (storeUid != '')
      storeUid: 'uid-store-a',
      sum: 100,
    });
    await assertFails(getDoc(doc(db('uid-store-b', asStore()), 'orders/CLAIM-4')));
  });

  // (manager reassign ✓) a manager overrides the claim to a different store.
  it('a manager REASSIGNS a claimed order to a different store (override)', async () => {
    await seed('orders/CLAIM-5', {
      contractorUid: 'uid-alice',
      stage: 'preparing',
      storeUid: 'uid-store-a',
      sum: 100,
    });
    await assertSucceeds(
      updateDoc(doc(db('uid-mgr', asManager()), 'orders/CLAIM-5'), {
        storeUid: 'uid-store-b', // god-reassign to another store
      }),
    );
  });

  // A store may NOT touch the peer's courierUid while advancing (field isolation).
  it('a store CANNOT write courierUid while advancing (peer claim is frozen)', async () => {
    await seed('orders/CLAIM-6', {
      contractorUid: 'uid-alice',
      stage: 'new',
      sum: 100,
    });
    await assertFails(
      updateDoc(doc(db('uid-store-a', asStore()), 'orders/CLAIM-6'), {
        stage: 'preparing',
        storeUid: 'uid-store-a',
        courierUid: 'uid-store-a', // forging the courier claim → DENIED
      }),
    );
  });

  // ── the courier analogue ────────────────────────────────────────────────────
  it('a courier CLAIMS an un-claimed order on first advance (pickup→transit)', async () => {
    await seed('orders/CCLAIM-1', {
      contractorUid: 'uid-alice',
      stage: 'pickup', // a courier pool stage, courierUid absent ⇒ ''
      sum: 100,
    });
    await assertSucceeds(
      updateDoc(doc(db('uid-courier-a', asCourier()), 'orders/CCLAIM-1'), {
        stage: 'transit',
        courierUid: 'uid-courier-a',
      }),
    );
  });

  it('a different courier CANNOT steal an order already claimed by another courier', async () => {
    await seed('orders/CCLAIM-2', {
      contractorUid: 'uid-alice',
      stage: 'transit',
      courierUid: 'uid-courier-a',
      sum: 100,
    });
    await assertFails(
      updateDoc(doc(db('uid-courier-b', asCourier()), 'orders/CCLAIM-2'), {
        stage: 'delivered',
        courierUid: 'uid-courier-b',
      }),
    );
  });

  it('a courier READS an un-claimed ready pool order; a non-owner is DENIED a claimed one', async () => {
    await seed('orders/CCLAIM-3', {
      contractorUid: 'uid-alice',
      stage: 'ready', // courier pool entry stage, courierUid ''
      sum: 100,
    });
    await assertSucceeds(getDoc(doc(db('uid-courier-a', asCourier()), 'orders/CCLAIM-3')));
    await seed('orders/CCLAIM-4', {
      contractorUid: 'uid-alice',
      stage: 'transit',
      courierUid: 'uid-courier-a', // claimed ⇒ out of pool
      sum: 100,
    });
    await assertFails(getDoc(doc(db('uid-courier-b', asCourier()), 'orders/CCLAIM-4')));
  });
});
