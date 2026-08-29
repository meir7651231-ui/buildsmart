// ─────────────────────────────────────────────────────────────────────────────
// rules_test/users.test.js — U0.4 rules-emulator suite for the `users/{uid}`
// AUTHORITY-FIELD hardening in /firestore.rules. Runs ONLY against the Firestore
// emulator (`npm run test:emulator`), never the live project. Same harness as
// orders.test.js: @firebase/rules-unit-testing over node's built-in runner
// (`node --test`) — no mocha/jest (rules_test/README.md).
//
// COVERS (the U0 rule + the all-by-approval decision it enforces):
//   • read — self or admin only; a signed-in NON-self user is denied.
//   • create — a self create may carry the display MIRROR (displayName/phone/…)
//     and `status: 'pending'` (or none → defaults pending), but is DENIED if it
//     carries `role`/`roles`/`storeUid`/`orgId`, or a `status` other than
//     'pending' (a user can NOT self-create as 'active' — all-by-approval).
//   • update — a self update may move mirror fields (displayName/lastSeen/…) but
//     is DENIED on `role`/`roles`/`storeUid`/`orgId`/`status` (the approval flip +
//     ownership + org are admin/callable-only). Admin bypasses.
//   • delete — self or admin.
//   • BACKWARD-COMPAT — the EXISTING profile mirror write
//     {displayName,phone,email,profession,address,businessId} still passes
//     (create + update), proving the new blocks never break today's client.
//
// SEEDING uses withSecurityRulesDisabled (the admin escape hatch) to plant state
// a rules-bound client could not itself create.
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
  deleteDoc,
  doc,
  getDoc,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'demo-buildsmart';

/** Custom-claim shapes the setRole callable writes + the bootstrap admin. */
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

/** Plant a doc with rules DISABLED (admin escape hatch). */
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

/** A Firestore handle authed as the given uid (+ optional claims). */
function db(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

// ── read ─────────────────────────────────────────────────────────────────────

describe('users · read is self-or-admin', () => {
  it('self READS own doc', async () => {
    await seed('users/uid-alice', { displayName: 'משה', status: 'pending' });
    await assertSucceeds(getDoc(doc(db('uid-alice'), 'users/uid-alice')));
  });

  it('a signed-in NON-self user is DENIED another user doc', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertFails(getDoc(doc(db('uid-bob'), 'users/uid-alice')));
  });

  it('admin READS any user doc', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertSucceeds(getDoc(doc(db('uid-root', asAdmin()), 'users/uid-alice')));
  });
});

// ── create (all-by-approval) ───────────────────────────────────────────────────

describe('users · self create — mirror + pending only', () => {
  it('self CREATES the display mirror (no status → defaults pending)', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), {
        displayName: 'משה',
        phone: '0501234567',
      }),
    );
  });

  it('self CREATES with status pending + timestamps', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), {
        displayName: 'משה',
        status: 'pending',
        createdAt: 1710000000000,
        lastSeen: 1710000000000,
      }),
    );
  });

  it('self CREATE with status active is DENIED (no self-approval)', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), {
        displayName: 'משה',
        status: 'active',
      }),
    );
  });

  it('self CREATE carrying role is DENIED', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), { role: 'manager' }),
    );
  });

  it('self CREATE carrying storeUid is DENIED', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), { storeUid: 'store-1' }),
    );
  });

  it('self CREATE carrying orgId is DENIED', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), { orgId: 'org-1' }),
    );
  });

  it('cannot create ANOTHER user\'s doc', async () => {
    await assertFails(
      setDoc(doc(db('uid-bob'), 'users/uid-alice'), { displayName: 'x' }),
    );
  });

  it('admin MAY create with role + active status (the approval path)', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-root', asAdmin()), 'users/uid-alice'), {
        role: 'store',
        status: 'active',
      }),
    );
  });
});

// ── update (mirror-only; authority fields frozen) ──────────────────────────────

describe('users · self update freezes authority fields', () => {
  it('self UPDATES displayName + lastSeen (mirror) → OK', async () => {
    await seed('users/uid-alice', { displayName: 'משה', status: 'pending' });
    await assertSucceeds(
      updateDoc(doc(db('uid-alice'), 'users/uid-alice'), {
        displayName: 'משה בונה',
        lastSeen: 1710000000000,
      }),
    );
  });

  it('self UPDATE of status is DENIED (approval is admin/callable-only)', async () => {
    await seed('users/uid-alice', { displayName: 'משה', status: 'pending' });
    await assertFails(
      updateDoc(doc(db('uid-alice'), 'users/uid-alice'), { status: 'active' }),
    );
  });

  it('self UPDATE of role is DENIED', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertFails(
      updateDoc(doc(db('uid-alice'), 'users/uid-alice'), { role: 'manager' }),
    );
  });

  it('self UPDATE of storeUid is DENIED', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertFails(
      updateDoc(doc(db('uid-alice'), 'users/uid-alice'), { storeUid: 'store-1' }),
    );
  });

  it('self UPDATE of orgId is DENIED', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertFails(
      updateDoc(doc(db('uid-alice'), 'users/uid-alice'), { orgId: 'org-1' }),
    );
  });

  it('admin MAY flip status pending→active (approval)', async () => {
    await seed('users/uid-alice', { displayName: 'משה', status: 'pending' });
    await assertSucceeds(
      updateDoc(doc(db('uid-root', asAdmin()), 'users/uid-alice'), {
        status: 'active',
      }),
    );
  });
});

// ── delete ─────────────────────────────────────────────────────────────────────

describe('users · delete is self-or-admin', () => {
  it('self DELETES own (S1.8 account deletion)', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertSucceeds(deleteDoc(doc(db('uid-alice'), 'users/uid-alice')));
  });

  it('a non-self user is DENIED deleting another', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertFails(deleteDoc(doc(db('uid-bob'), 'users/uid-alice')));
  });

  it('admin DELETES any', async () => {
    await seed('users/uid-alice', { displayName: 'משה' });
    await assertSucceeds(deleteDoc(doc(db('uid-root', asAdmin()), 'users/uid-alice')));
  });
});

// ── backward compatibility (the existing profile mirror must keep passing) ─────

describe('users · backward-compat — the existing profile mirror still works', () => {
  const mirror = {
    displayName: 'משה בונה',
    phone: '0501234567',
    email: 'moshe@example.com',
    profession: 'אינסטלטור',
    address: 'תל אביב',
    businessId: '123456789',
  };

  it('the mirror write CREATES fine (no authority fields)', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice'), 'users/uid-alice'), mirror),
    );
  });

  it('the mirror write UPDATES fine on an existing doc', async () => {
    await seed('users/uid-alice', { displayName: 'old', status: 'pending' });
    await assertSucceeds(
      updateDoc(doc(db('uid-alice'), 'users/uid-alice'), mirror),
    );
  });
});
