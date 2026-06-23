// ─────────────────────────────────────────────────────────────────────────────
// rules_test/chat.test.js — launch A9 rules-emulator suite for the CHAT
// ownership rules in /firestore.rules (chatThreads + chatMessages). Runs ONLY
// against the Firestore emulator (`npm test` under `firebase emulators:exec`),
// never the live project. @firebase/rules-unit-testing v4 over node's built-in
// runner (`node --test`) — same harness as orders.test.js.
//
// WHY THIS FILE EXISTS: before A9 the chat rules had ZERO emulator coverage.
// A9 also aligns the rules to the dedicated `participantUids` (the auth-truth)
// instead of the role-name `participants` (display only) — this suite pins that:
//   • chatThreads read/create/update/delete key on `participantUids` (a display
//     ROLE in `participants` gates NOTHING);
//   • a legacy thread (empty/absent participantUids) matches no uid (forward-
//     ready — inert until per-user threads are populated);
//   • update FREEZES participantUids (refresh lastMsg ok; recruit/eject denied);
//   • chatMessages read/create scope to the PARENT thread's participantUids,
//     create is self-only (fromUid==auth.uid), messages are immutable;
//   • signed-out is denied everywhere.
//
// SEEDING uses withSecurityRulesDisabled (the admin escape hatch) so a doc can
// be planted regardless of rules, then asserted through a rules-bound client.
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
// A distinct project id ISOLATES this suite's emulator namespace from
// orders.test.js: `node --test` runs the test FILES in parallel, and a shared
// project would let one file's `beforeEach` clearFirestore() wipe the other's
// just-seeded docs mid-test — fatal for the cross-document get() the
// chatMessages rules do on the parent thread (a flaky "Service call error" on
// the seed-dependent positives). `demo-*` keeps it a credential-free demo
// project; the same firestore.rules are loaded into this namespace below.
const PROJECT_ID = 'demo-buildsmart-chat';

const asContractor = () => ({ role: 'contractor' });
const asStore = () => ({ role: 'store' });

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

/** A Firestore handle authed as the given uid + claims. */
function db(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

// ── chatThreads — membership keys on participantUids (NOT display roles) ──────

describe('chatThreads · membership keys on participantUids (A9)', () => {
  it('a uid MEMBER reads the thread (uid in participantUids)', async () => {
    await seed('chatThreads/th-1', {
      participants: ['contractor', 'store'], // display ROLES — must NOT gate
      participantUids: ['uid-alice', 'uid-bob'],
      names: 'ספק',
      lastMsg: 'שלום',
    });
    await assertSucceeds(
      getDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-1')),
    );
  });

  it('a NON-member is DENIED (uid not in participantUids)', async () => {
    await seed('chatThreads/th-1', {
      participants: ['contractor', 'store'],
      participantUids: ['uid-alice', 'uid-bob'],
    });
    await assertFails(
      getDoc(doc(db('uid-carol', asStore()), 'chatThreads/th-1')),
    );
  });

  it('a display ROLE in participants never gates — only participantUids does', async () => {
    // alice is a contractor and the thread lists the 'contractor' ROLE, but she
    // is NOT in participantUids → denied. Proves participants gates nothing.
    await seed('chatThreads/th-1', {
      participants: ['contractor', 'store'],
      participantUids: ['uid-bob', 'uid-carol'],
    });
    await assertFails(
      getDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-1')),
    );
  });

  it('a LEGACY thread (no participantUids) matches no uid — forward-ready inert', async () => {
    await seed('chatThreads/th-legacy', {
      participants: ['contractor', 'store'], // role-names only, pre-migration
      names: 'ספק',
    });
    await assertFails(
      getDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-legacy')),
    );
  });

  it('CREATE: author puts themself in participantUids → allowed', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-new'), {
        participants: ['contractor', 'store'],
        participantUids: ['uid-alice', 'uid-bob'],
        names: 'ספק',
      }),
    );
  });

  it('CREATE: author NOT in participantUids → denied', async () => {
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-new'), {
        participants: ['store', 'courier'],
        participantUids: ['uid-bob', 'uid-carol'], // alice absent
      }),
    );
  });

  it('UPDATE: a member refreshes lastMsg, participantUids unchanged → allowed', async () => {
    await seed('chatThreads/th-1', {
      participants: ['contractor', 'store'],
      participantUids: ['uid-alice', 'uid-bob'],
      lastMsg: 'old',
    });
    await assertSucceeds(
      updateDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-1'), {
        lastMsg: 'new',
        ts: '2026-06-13T10:00:00.000',
      }),
    );
  });

  it('UPDATE: changing participantUids (recruit/eject) is FROZEN → denied', async () => {
    await seed('chatThreads/th-1', {
      participants: ['contractor', 'store'],
      participantUids: ['uid-alice', 'uid-bob'],
    });
    await assertFails(
      updateDoc(doc(db('uid-alice', asContractor()), 'chatThreads/th-1'), {
        participantUids: ['uid-alice', 'uid-bob', 'uid-carol'], // recruiting
      }),
    );
  });

  // ── branch (b) — A14 empty-thread stamp, scoped by ROLE (swarm#3 authz fix) ──
  it('UPDATE branch(b): a PARTICIPANT-role user stamps an EMPTY thread (incl. self) → allowed', async () => {
    await seed('chatThreads/th-2', {
      participants: ['contractor', 'store'], // pre-migration: empty participantUids
      participantUids: [],
    });
    await assertSucceeds(
      updateDoc(doc(db('uid-carol', asContractor()), 'chatThreads/th-2'), {
        participantUids: ['uid-carol'], // a contractor IS one of the thread's roles
      }),
    );
  });

  it('UPDATE branch(b): a NON-participant-role user (worker) CANNOT stamp an empty thread → denied', async () => {
    await seed('chatThreads/th-2', {
      participants: ['contractor', 'store'], // a worker is NOT a party to this thread
      participantUids: [],
    });
    await assertFails(
      // self-stamp, but the wrong role → denied (closes the cross-persona read gap)
      updateDoc(doc(db('uid-mallory', { role: 'worker' }), 'chatThreads/th-2'), {
        participantUids: ['uid-mallory'],
      }),
    );
  });

  it('UPDATE branch(b): stamping an empty thread WITHOUT including self → denied', async () => {
    await seed('chatThreads/th-2', {
      participants: ['contractor', 'store'],
      participantUids: [],
    });
    await assertFails(
      updateDoc(doc(db('uid-carol', asContractor()), 'chatThreads/th-2'), {
        participantUids: ['uid-bob'], // stamping someone else, not self
      }),
    );
  });
});

// ── chatMessages — scoped to the parent thread's participantUids ─────────────

describe('chatMessages · scoped to parent thread participantUids (A9)', () => {
  /** Seed a thread alice+bob belong to (carol does not). */
  async function seedThread() {
    await seed('chatThreads/th-1', {
      participants: ['contractor', 'store'],
      participantUids: ['uid-alice', 'uid-bob'],
    });
  }

  it('a MEMBER reads a message in their thread', async () => {
    await seedThread();
    await seed('chatMessages/m-1', {
      threadId: 'th-1',
      fromUid: 'uid-bob',
      fromRole: 'store',
      text: 'hi',
      ts: '2026-06-13T10:00:00.000',
    });
    await assertSucceeds(
      getDoc(doc(db('uid-alice', asContractor()), 'chatMessages/m-1')),
    );
  });

  it('a NON-member is DENIED reading the message', async () => {
    await seedThread();
    await seed('chatMessages/m-1', {
      threadId: 'th-1',
      fromUid: 'uid-bob',
      fromRole: 'store',
      text: 'hi',
      ts: '2026-06-13T10:00:00.000',
    });
    await assertFails(
      getDoc(doc(db('uid-carol', asStore()), 'chatMessages/m-1')),
    );
  });

  it('CREATE as yourself (fromUid==uid) into your thread → allowed', async () => {
    await seedThread();
    await assertSucceeds(
      setDoc(doc(db('uid-alice', asContractor()), 'chatMessages/m-2'), {
        threadId: 'th-1',
        fromUid: 'uid-alice',
        fromRole: 'contractor',
        text: 'hello',
        ts: '2026-06-13T10:01:00.000',
      }),
    );
  });

  it('CREATE spoofing another sender (fromUid != uid) → denied', async () => {
    await seedThread();
    await assertFails(
      setDoc(doc(db('uid-alice', asContractor()), 'chatMessages/m-3'), {
        threadId: 'th-1',
        fromUid: 'uid-bob', // not the caller
        fromRole: 'store',
        text: 'spoof',
        ts: '2026-06-13T10:02:00.000',
      }),
    );
  });

  it('CREATE into a thread you are NOT in → denied', async () => {
    await seedThread();
    await assertFails(
      setDoc(doc(db('uid-carol', asStore()), 'chatMessages/m-4'), {
        threadId: 'th-1',
        fromUid: 'uid-carol', // is herself, but not a member of th-1
        fromRole: 'store',
        text: 'intrude',
        ts: '2026-06-13T10:03:00.000',
      }),
    );
  });

  it('messages are IMMUTABLE — update and delete denied even for a member', async () => {
    await seedThread();
    await seed('chatMessages/m-5', {
      threadId: 'th-1',
      fromUid: 'uid-alice',
      fromRole: 'contractor',
      text: 'fixed',
      ts: '2026-06-13T10:04:00.000',
    });
    await assertFails(
      updateDoc(doc(db('uid-alice', asContractor()), 'chatMessages/m-5'), {
        text: 'edited',
      }),
    );
    await assertFails(
      deleteDoc(doc(db('uid-alice', asContractor()), 'chatMessages/m-5')),
    );
  });

  it('signed-out is DENIED on threads AND messages', async () => {
    await seedThread();
    await seed('chatMessages/m-6', {
      threadId: 'th-1',
      fromUid: 'uid-alice',
      fromRole: 'contractor',
      text: 'x',
      ts: '2026-06-13T10:05:00.000',
    });
    const anon = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, 'chatThreads/th-1')));
    await assertFails(getDoc(doc(anon, 'chatMessages/m-6')));
  });
});
