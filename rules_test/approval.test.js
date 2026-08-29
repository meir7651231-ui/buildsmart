// ─────────────────────────────────────────────────────────────────────────────
// rules_test/approval.test.js — "all-by-approval", enforced where it counts.
//
// WHAT WAS WRONG. The approval lifecycle existed only on the client, and every
// layer of it was decorative:
//   • the amber strip calls itself, in its own source, "a non-blocking notice";
//   • the typed gate `requirePermission` (rbac.dart) has ZERO call sites;
//   • the checkout fence tested `userProfileProvider.registered`, a device-local
//     SharedPreferences bool that flips true from typed name+contact alone;
//   • and NO rule anywhere read `users/{uid}.status` — grep found it only in the
//     users-doc write freeze and the roleRequests create.
// So a registered-but-unapproved account, and even the anonymous catalog guest,
// could place an order that landed on the store and courier boards looking
// exactly like an approved one. main.dart states in prose that approval "is
// enforced by permitAction". Nothing called permitAction.
//
// THE SPLIT THESE TESTS PIN. Two different questions, deliberately not merged:
//   • ORDERING requires an APPROVED PERSON      → isActive()
//   • TALKING requires only a REAL PERSON       → isRealUser()
// Someone waiting for approval is exactly who needs to ask an admin "when?" —
// denying them the chat would close their last channel. The anonymous guest is
// neither: it is a browser session nobody can hold a conversation with.
//
// The anonymous contexts below are also the FIRST coverage of the
// `sign_in_provider != 'anonymous'` predicate at all — the `directory` rule has
// used it since the chat fix and was never exercised against a real anon token.
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
import { doc, getDoc, setDoc } from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = 'demo-buildsmart';

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

async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

/** A REAL signed-in person (the library's default sign_in_provider is 'custom',
 *  i.e. anything but 'anonymous'). */
function db(uid, claims = { role: 'contractor' }) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

/** The anonymous catalog guest `main()` creates before the first frame. */
function anonDb(uid) {
  return testEnv
    .authenticatedContext(uid, { firebase: { sign_in_provider: 'anonymous' } })
    .firestore();
}

/** Give `uid` a users doc with the given approval status. */
const withStatus = (uid, status) =>
  seed(`users/${uid}`, { displayName: 'בודק', status });

const newOrder = (uid) => ({
  contractorId: 'בודק',
  contractorUid: uid,
  stage: 'new',
  sum: 100,
});

// ── ordering — the approval must be the server's answer, not the client's ────

describe('orders · create requires an APPROVED person', () => {
  it('an ACTIVE contractor may place an order', async () => {
    await withStatus('uid-ok', 'active');
    await assertSucceeds(
      setDoc(doc(db('uid-ok'), 'orders/BS-1'), newOrder('uid-ok')),
    );
  });

  it('THE BUG: a PENDING account may NOT place an order', async () => {
    // This is the exact write that used to land on the store + courier boards
    // while the person was still waiting to be approved.
    await withStatus('uid-wait', 'pending');
    await assertFails(
      setDoc(doc(db('uid-wait'), 'orders/BS-2'), newOrder('uid-wait')),
    );
  });

  it('a SUSPENDED account may not place an order either', async () => {
    await withStatus('uid-susp', 'suspended');
    await assertFails(
      setDoc(doc(db('uid-susp'), 'orders/BS-3'), newOrder('uid-susp')),
    );
  });

  it('THE BUG: the ANONYMOUS catalog guest may NOT place an order', async () => {
    // The guest has no users doc at all — _UserDocSync skips !isRealUser — so
    // before this rule there was not even a status to consult.
    await assertFails(
      setDoc(doc(anonDb('anon-1'), 'orders/BS-4'), newOrder('anon-1')),
    );
  });

  it('a MISSING users doc is not approval (fromWire(null) must not read active)',
    async () => {
      // No seed at all: a real signed-in uid whose document was never written.
      await assertFails(
        setDoc(doc(db('uid-ghost'), 'orders/BS-5'), newOrder('uid-ghost')),
      );
    });

  it('a users doc with NO status field defaults to pending, not approved',
    async () => {
      await seed('users/uid-nostatus', { displayName: 'בלי סטטוס' });
      await assertFails(
        setDoc(doc(db('uid-nostatus'), 'orders/BS-6'), newOrder('uid-nostatus')),
      );
    });

  it('approval is not a substitute for ownership — active ≠ order in another name',
    async () => {
      await withStatus('uid-ok2', 'active');
      await assertFails(
        setDoc(doc(db('uid-ok2'), 'orders/BS-7'), newOrder('uid-someone-else')),
      );
    });

  it('a manager still creates orders mid-pipeline, with no users doc of their own',
    async () => {
      // The manager branch is `isManager() && stage in orderStages()` and was
      // deliberately left alone: approval is a gate on the person PLACING an
      // order, not on the staff recording one. Note there is no users doc for
      // uid-mgr — an admin acting through claims must not need one.
      await assertSucceeds(
        setDoc(doc(db('uid-mgr', { role: 'manager' }), 'orders/BS-8'), {
          contractorId: 'בודק',
          contractorUid: 'uid-somebody',
          stage: 'preparing', // must be one of orderStages()
          sum: 100,
        }),
      );
    });

  it('a manager may not create at a stage outside the pipeline', async () => {
    await assertFails(
      setDoc(doc(db('uid-mgr2', { role: 'manager' }), 'orders/BS-9'), {
        contractorId: 'בודק',
        contractorUid: 'uid-somebody',
        stage: 'assigned', // not in orderStages() — the value that caught me
        sum: 100,
      }),
    );
  });
});

// ── talking — deliberately a LOWER bar than ordering ─────────────────────────

describe('chat · a pending person may still speak; a session may not', () => {
  const thread = (uids) => ({ participantUids: uids, lastMsg: 'שלום' });

  it('a PENDING person CAN open a thread — this is how they ask "when?"',
    async () => {
      await withStatus('uid-wait2', 'pending');
      await assertSucceeds(
        setDoc(
          doc(db('uid-wait2'), 'chatThreads/t-1'),
          thread(['uid-wait2', 'uid-admin']),
        ),
      );
    });

  it('a PENDING person CAN post a message into their thread', async () => {
    await withStatus('uid-wait3', 'pending');
    await seed('chatThreads/t-2', { participantUids: ['uid-wait3', 'uid-adm'] });
    await assertSucceeds(
      setDoc(doc(db('uid-wait3'), 'chatMessages/m-1'), {
        threadId: 't-2',
        fromUid: 'uid-wait3',
        text: 'מתי אאושר?',
      }),
    );
  });

  it('the ANONYMOUS guest may NOT open a thread', async () => {
    await assertFails(
      setDoc(
        doc(anonDb('anon-2'), 'chatThreads/t-3'),
        thread(['anon-2', 'uid-admin']),
      ),
    );
  });

  it('the ANONYMOUS guest may NOT post a message, even inside a thread naming it',
    async () => {
      await seed('chatThreads/t-4', { participantUids: ['anon-3', 'uid-adm'] });
      await assertFails(
        setDoc(doc(anonDb('anon-3'), 'chatMessages/m-2'), {
          threadId: 't-4',
          fromUid: 'anon-3',
          text: 'שלום',
        }),
      );
    });

  it('membership is still the real fence — an active outsider cannot post',
    async () => {
      await withStatus('uid-out', 'active');
      await seed('chatThreads/t-5', { participantUids: ['uid-a', 'uid-b'] });
      await assertFails(
        setDoc(doc(db('uid-out'), 'chatMessages/m-3'), {
          threadId: 't-5',
          fromUid: 'uid-out',
          text: 'נכנסתי',
        }),
      );
    });
});

// ── the directory's anon predicate, exercised for the first time ─────────────

describe('directory · readable by people, not by sessions', () => {
  it('a real signed-in person reads the directory', async () => {
    await seed('directory/uid-a', { role: 'contractor', displayName: 'אבי' });
    await assertSucceeds(getDoc(doc(db('uid-reader'), 'directory/uid-a')));
  });

  it('the ANONYMOUS guest does NOT read the directory', async () => {
    // A catalog browser is not somebody anyone can message, and has no business
    // enumerating who is here.
    await seed('directory/uid-a', { role: 'contractor', displayName: 'אבי' });
    await assertFails(getDoc(doc(anonDb('anon-4'), 'directory/uid-a')));
  });

  it('a client cannot write its own role into the directory', async () => {
    await assertFails(
      setDoc(doc(db('uid-liar'), 'directory/uid-liar'), {
        role: 'manager',
        displayName: 'אני מנהל',
      }),
    );
  });
});
