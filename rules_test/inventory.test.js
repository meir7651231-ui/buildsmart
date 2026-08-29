// ─────────────────────────────────────────────────────────────────────────────
// rules_test/inventory.test.js — U3 (store-ownership) emulator suite for the
// LAUNCH-BLOCKING isolation in /firestore.rules. Runs ONLY against the Firestore
// emulator (`npm run test:emulator`). Same harness as orders/users.test.js:
// @firebase/rules-unit-testing over node's built-in runner (`node --test`).
//
// THE LAUNCH-BLOCKER (SPEC-user-system §U3, directive §6): a store owner manages
// its OWN inventory alone and can NEVER touch another store's rows. The live
// inventory rule keys write on the `storeId` custom claim (U3.1.1 stamps it via
// setRole) == the row's `storeId` field. This suite proves:
//   • a store writes/updates ONLY rows whose `storeId` == its claim (⭐ 403 on B);
//   • a store with NO storeId claim, and a contractor, cannot write inventory;
//   • manager/owner write any store's inventory (god-role); read is world (signed-in).
//   • stores/{id}: the OWNER edits its own doc but cannot transfer ownership
//     (`ownerUid` frozen) or touch another store's doc; manager transfers freely.
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
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'demo-buildsmart';

/** Claim shapes setRole (index.ts) writes. A store OWNER carries role:'store'
 *  PLUS the storeId claim (U3.1.1). */
const asStore = (storeId) => ({ role: 'store', storeId });
const asStoreNoId = () => ({ role: 'store' });
const asManager = () => ({ role: 'manager' });
const asContractor = () => ({ role: 'contractor' });

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

/** Plant a doc with rules DISABLED (admin escape hatch). */
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

/** A Firestore handle authed as the given uid + claims. */
function db(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

// ── inventory — a store writes ONLY its own rows ────────────────────────────────

describe('inventory · store writes ONLY its own rows (U3.2.3 ⭐ launch-blocker)', () => {
  it('store-A CREATES its own row (storeId field == claim)', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-a', asStore('store-a')), 'inventory/store-a_118220'), {
        storeId: 'store-a',
        sku: '118220',
        price: 38,
        stock: 12,
      }),
    );
  });

  it('⭐ store-A CANNOT write a row labelled store-B (field != claim) → DENIED', async () => {
    await assertFails(
      setDoc(doc(db('uid-a', asStore('store-a')), 'inventory/store-b_118220'), {
        storeId: 'store-b',
        sku: '118220',
        price: 1, // undercut attempt on a competitor's row
        stock: 999,
      }),
    );
  });

  it('store-A cannot UPDATE an existing store-B row', async () => {
    await seed('inventory/store-b_118220', {
      storeId: 'store-b',
      sku: '118220',
      price: 42,
      stock: 3,
    });
    await assertFails(
      updateDoc(doc(db('uid-a', asStore('store-a')), 'inventory/store-b_118220'), {
        price: 1,
      }),
    );
  });

  it('a store with NO storeId claim cannot write ANY inventory', async () => {
    await assertFails(
      setDoc(doc(db('uid-x', asStoreNoId()), 'inventory/store-a_118220'), {
        storeId: 'store-a',
        sku: '118220',
        price: 38,
        stock: 12,
      }),
    );
  });

  it('a contractor cannot write inventory', async () => {
    await assertFails(
      setDoc(doc(db('uid-c', asContractor()), 'inventory/store-a_1'), {
        storeId: 'store-a',
        sku: '1',
        price: 1,
        stock: 1,
      }),
    );
  });

  it('manager writes ANY store\'s inventory (god-role)', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-m', asManager()), 'inventory/store-a_1'), {
        storeId: 'store-a',
        sku: '1',
        price: 5,
        stock: 5,
      }),
    );
  });

  it('any signed-in user READS inventory (the store comparison)', async () => {
    await seed('inventory/store-a_1', {
      storeId: 'store-a',
      sku: '1',
      price: 5,
      stock: 5,
    });
    await assertSucceeds(
      getDoc(doc(db('uid-c', asContractor()), 'inventory/store-a_1')),
    );
  });
});

// ── stores — the owner edits its own doc, never transfers or touches others ─────

describe('stores · owner-scoped store-doc edits (U3.2.2)', () => {
  const storeA = {
    id: 'store-a',
    name: 'אחים כהן',
    area: 'צפון',
    ownerUid: 'uid-a',
  };

  it('the OWNER updates its own store doc (ownerUid == uid)', async () => {
    await seed('stores/store-a', storeA);
    await assertSucceeds(
      updateDoc(doc(db('uid-a', asStore('store-a')), 'stores/store-a'), {
        name: 'אחים כהן ובניו',
      }),
    );
  });

  it('a store CANNOT edit another store\'s doc', async () => {
    await seed('stores/store-b', {
      id: 'store-b',
      name: 'מרכז',
      area: 'מרכז',
      ownerUid: 'uid-b',
    });
    await assertFails(
      updateDoc(doc(db('uid-a', asStore('store-a')), 'stores/store-b'), {
        name: 'hacked',
      }),
    );
  });

  it('the owner CANNOT reassign ownership (ownerUid is frozen)', async () => {
    await seed('stores/store-a', storeA);
    await assertFails(
      updateDoc(doc(db('uid-a', asStore('store-a')), 'stores/store-a'), {
        ownerUid: 'uid-evil',
      }),
    );
  });

  it('manager transfers ownership freely (god-role)', async () => {
    await seed('stores/store-a', storeA);
    await assertSucceeds(
      updateDoc(doc(db('uid-m', asManager()), 'stores/store-a'), {
        ownerUid: 'uid-new',
      }),
    );
  });
});
