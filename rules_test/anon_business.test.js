// ─────────────────────────────────────────────────────────────────────────────
// rules_test/anon_business.test.js — the anonymous catalog guest vs business data
// (security pass 12.10.2026).
//
// WHAT WAS WRONG. Every visitor is signed in anonymously before the first frame
// (main.dart) so the catalog can be read, which makes `isSignedIn()` true for a
// total stranger. Several rules used `isSignedIn()` alone:
//   • siteNodes / projects reads — business data (project names, addresses,
//     contractor ids) open to anyone who minted an anonymous session;
//   • users/{uid} create/update — every anonymous uid could create its own users
//     doc, which fires the approval push to the owner and every manager and adds
//     a fake "contractor" row to the directory;
//   • roleRequests create — an anonymous session could file a role request, and
//     one mistaken approval handed a guest session a store/courier role.
// These now require `isRealUser()` (any provider except 'anonymous').
//
// DELIBERATELY UNCHANGED (pinned below as regression guards): the catalog
// collections, stores and inventory stay readable by guests (the product-sheet
// store comparison reads them), and stock / material_requests /
// siteStageProgress stay on `isSignedIn()` for now — a guest can reach their
// listeners, and a listener denied while anonymous never resubscribes after
// login (firestore_cached_repo `_sub ??=`). Closing those needs the Flutter
// providers to watch auth first.
//
// Own projectId: `node --test` runs the suite files concurrently and the other
// suites wipe 'demo-buildsmart' in beforeEach.
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
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'demo-buildsmart-anon';

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
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    const docs = {
      'stock/s1': { sku: '118220', name: 'ברז', qty: 4, projectId: 'p1' },
      'siteNodes/n1': { label: 'קומה 1', projectId: 'p1' },
      'projects/p1': { name: 'וילה', address: 'רחוב הדוגמה 1', contractorId: 'c1', members: ['c1'] },
      'material_requests/m1': { workerName: 'עובד', workerUid: 'w1', employerId: 'c1', items: [] },
      'catalogProducts/118220': { name: 'מתאם' },
      'catalogCategories/cat1': { name: 'אינסטלציה' },
      'catalogTrades/tr1': { name: 'אינסטלטור' },
      'catalogTokenFreq/tok1': { n: 1 },
      'catalogMeta/meta': { version: 1 },
      'verified_specs/118220': { od: 20 },
      'recipes/r1': { steps: [] },
      'stores/st1': { name: 'חנות' },
      'inventory/i1': { sku: '118220', storeId: 'st1', price: 12, qty: 3 },
    };
    for (const [path, data] of Object.entries(docs)) {
      await setDoc(doc(fs, path), data);
    }
  });
});

/** A real person. The library's default token provider is 'custom'. */
function realDb(uid, claims = { role: 'contractor' }) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

/** A real person who signed in with a specific provider. */
function providerDb(uid, provider) {
  return testEnv
    .authenticatedContext(uid, { firebase: { sign_in_provider: provider } })
    .firestore();
}

/** The anonymous catalog guest main() creates before the first frame. */
function anonDb(uid) {
  return providerDb(uid, 'anonymous');
}

function noAuthDb() {
  return testEnv.unauthenticatedContext().firestore();
}

// ── business reads closed to the anonymous guest ─────────────────────────────

for (const [col, id] of [['siteNodes', 'n1'], ['projects', 'p1']]) {
  describe(`${col} · read needs a real person`, () => {
    it('the anonymous guest cannot read a document', async () => {
      await assertFails(getDoc(doc(anonDb('anon1'), col, id)));
    });
    it('the anonymous guest cannot list the collection', async () => {
      await assertFails(getDocs(collection(anonDb('anon1'), col)));
    });
    it('an unauthenticated caller cannot read', async () => {
      await assertFails(getDoc(doc(noAuthDb(), col, id)));
    });
    it('a real person can read and list (custom, phone, google.com)', async () => {
      for (const fs of [realDb('u1'), providerDb('u2', 'phone'), providerDb('u3', 'google.com')]) {
        await assertSucceeds(getDoc(doc(fs, col, id)));
        await assertSucceeds(getDocs(collection(fs, col)));
      }
    });
  });
}

// ── stock / material_requests: deliberately unchanged for real people ────────

describe('stock + material_requests · real people still read them', () => {
  it('a real person reads stock and material_requests', async () => {
    const fs = providerDb('u1', 'password');
    await assertSucceeds(getDoc(doc(fs, 'stock', 's1')));
    await assertSucceeds(getDoc(doc(fs, 'material_requests', 'm1')));
  });
});

// ── users/{self}: no users doc for anonymous sessions ────────────────────────

describe('users/{self} · create/update needs a real person', () => {
  it('the anonymous guest cannot create its users doc (profile mirror)', async () => {
    await assertFails(setDoc(doc(anonDb('anon1'), 'users', 'anon1'), { displayName: 'מישהו' }));
  });
  it('the anonymous guest cannot create its users doc (push token only)', async () => {
    await assertFails(setDoc(doc(anonDb('anon1'), 'users', 'anon1'), { fcmToken: 'tok' }));
  });
  it('the anonymous guest cannot update a users doc that already exists', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users', 'anon1'), { displayName: 'ישן', status: 'pending' });
    });
    await assertFails(updateDoc(doc(anonDb('anon1'), 'users', 'anon1'), { fcmToken: 'tok' }));
  });
  it('a real person creates and updates their own users doc', async () => {
    const fs = providerDb('u1', 'phone');
    await assertSucceeds(setDoc(doc(fs, 'users', 'u1'), { displayName: 'אמיתי', status: 'pending' }));
    await assertSucceeds(updateDoc(doc(fs, 'users', 'u1'), { fcmToken: 'tok' }));
  });
});

// ── roleRequests: no role requests from anonymous sessions ───────────────────

describe('roleRequests · create needs a real person', () => {
  const req = { status: 'pending', requestedRole: 'store', displayName: 'חנות' };
  it('the anonymous guest cannot file a role request', async () => {
    await assertFails(setDoc(doc(anonDb('anon1'), 'roleRequests', 'anon1'), req));
  });
  it('a real person can file their own role request', async () => {
    await assertSucceeds(setDoc(doc(providerDb('u1', 'password'), 'roleRequests', 'u1'), req));
  });
});

// ── regression guards: guest catalog browsing keeps working ──────────────────

describe('guest browsing · the anonymous guest still reads the catalog', () => {
  it('catalog collections, stores and verified specs stay readable', async () => {
    const fs = anonDb('anon1');
    for (const [col, id] of [
      ['catalogProducts', '118220'],
      ['catalogCategories', 'cat1'],
      ['catalogTrades', 'tr1'],
      ['catalogTokenFreq', 'tok1'],
      ['catalogMeta', 'meta'],
      ['verified_specs', '118220'],
      ['recipes', 'r1'],
      ['stores', 'st1'],
    ]) {
      await assertSucceeds(getDoc(doc(fs, col, id)));
    }
  });
  it('the product-sheet store comparison query on inventory still works', async () => {
    const fs = anonDb('anon1');
    await assertSucceeds(getDocs(query(collection(fs, 'inventory'), where('sku', '==', '118220'))));
  });
});
