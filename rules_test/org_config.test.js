// ─────────────────────────────────────────────────────────────────────────────
// rules_test/org_config.test.js — the OWNER-publishes / EVERYONE-reads contract
// for `orgConfigLive/current`, pinned against /firestore.rules. Runs ONLY on the
// Firestore emulator (`npm run test:emulator` boots it via firebase.json →
// firestore.rules), never the live project. Written with
// @firebase/rules-unit-testing over node's built-in runner (`node --test`) — no
// mocha/jest, per rules_test/README.md; the harness/boilerplate mirrors
// approval.test.js verbatim (and the owner-email idiom mirrors studio.test.js) so
// it plugs into the same suite.
//
// THE RULE UNDER TEST (firestore.rules — the "org config that reaches ALL users"):
//   match /orgConfigLive/{docId} {
//     allow read:  if true;            // PUBLIC — every client renders the org shape
//     allow write: if isOwnerEmail();  // OWNER-ONLY publish (un-spoofable Google email)
//   }
//   function isOwnerEmail() {
//     return isSignedIn()
//         && request.auth.token.get('email', '') == 'meir7651231@gmail.com';
//   }
//
// The OWNER publishes it (the setup wizard → org_config_sink_firebase.dart);
// everyone — INCLUDING the pre-auth catalog visitor — reads it. Two questions
// this suite pins, deliberately NOT merged:
//   • PUBLISHING requires the OWNER, BY EMAIL — never a role. A manager, an admin,
//     any signed-in account with the WRONG email, a user with NO email claim, and
//     an unauthenticated session are ALL denied. Proving the deny for a
//     manager/admin is the load-bearing assertion: it shows the write gate is the
//     verified email, not a privilege level.
//   • READING requires NOTHING — a signed-in non-owner, an anonymous session, a
//     fully UNAUTHENTICATED visitor, and the owner all read the published doc.
//
// HOW THE `email` CLAIM IS INJECTED (mirrored from approval.test.js): the SECOND
// positional arg to `testEnv.authenticatedContext(uid, claims)` IS the decoded
// auth token — approval.test.js passes `{ role: 'contractor' }` there and the
// rules read it via `request.auth.token.get('role', '')`; by exact analogy a
// `{ email: '…' }` claim lands as `request.auth.token.get('email', '')`, which is
// precisely what isOwnerEmail() compares. studio.test.js already relies on this
// same idiom (`const asOwner = () => ({ email: OWNER_EMAIL })`, line 65) to drive
// the sibling owner-email rules, and approval.test.js proves the arg is the WHOLE
// token by passing `{ firebase: { sign_in_provider: 'anonymous' } }`.
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
// Per-file projectId — `node --test` runs the suite files CONCURRENTLY, so each
// file gets its own Firestore data namespace inside the shared emulator (exactly
// what studio.test.js does with 'demo-buildsmart-studio') and its beforeEach
// clearFirestore() can never wipe a sibling file's seeded state. The SDK-side
// projectId is independent of the emulator's `--project demo-buildsmart` boot.
const PROJECT_ID = 'demo-buildsmart-orgconfig';

// The app OWNER's verified email — must match firestore.rules isOwnerEmail() and
// functions/src/common.ts OWNER_EMAIL (the Google ID-token delivers it lower-cased,
// so the rule is a direct literal compare). Same constant as studio.test.js.
const OWNER_EMAIL = 'meir7651231@gmail.com';

// The doc every client renders and only the owner may publish.
const DOC_PATH = 'orgConfigLive/current';

/** The write the setup wizard makes when the owner PUBLISHES the org config. */
const publishedOrg = () => ({ json: '{"v":1}' });

// ── custom-token / claim shapes (the SECOND arg to authenticatedContext, i.e.
//    the decoded request.auth.token — see the header note) ──────────────────────
const asOwner = () => ({ email: OWNER_EMAIL });
const asOther = () => ({ email: 'someoneelse@gmail.com' });
// Wrong email but ALSO a privileged claim — proves the gate is the email, not the
// role/admin bit: both of these must STILL be denied the publish.
const asOtherManager = () => ({ email: 'someoneelse@gmail.com', role: 'manager' });
const asOtherAdmin = () => ({ email: 'someoneelse@gmail.com', admin: true });
// Signed in but carrying NO email claim → get('email','') yields '' != owner.
const asNoEmail = () => ({ role: 'contractor' });

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

/** The anonymous catalog guest (mirrors approval.test.js `anonDb`). */
function anonDb(uid) {
  return testEnv
    .authenticatedContext(uid, { firebase: { sign_in_provider: 'anonymous' } })
    .firestore();
}

/** A fully UNAUTHENTICATED visitor — request.auth == null (no sign-in at all;
 *  the same handle studio.test.js uses for its anon-read/-deny cases). */
function noAuthDb() {
  return testEnv.unauthenticatedContext().firestore();
}

// ── publishing — ONLY the owner, and BY EMAIL (not by role) ──────────────────
describe('orgConfigLive · publish is OWNER-only (by verified email)', () => {
  it('the OWNER (email == meir7651231@gmail.com) CAN publish orgConfigLive/current', async () => {
    await assertSucceeds(
      setDoc(doc(db('uid-owner', asOwner()), DOC_PATH), publishedOrg()),
    );
  });

  it('a signed-in NON-owner CANNOT publish (wrong email)', async () => {
    await assertFails(
      setDoc(doc(db('uid-other', asOther()), DOC_PATH), publishedOrg()),
    );
  });

  it('THE PROOF: a MANAGER with the WRONG email STILL cannot publish (the gate is the email, not a role)', async () => {
    await assertFails(
      setDoc(doc(db('uid-mgr', asOtherManager()), DOC_PATH), publishedOrg()),
    );
  });

  it('an ADMIN with the WRONG email STILL cannot publish', async () => {
    await assertFails(
      setDoc(doc(db('uid-admin', asOtherAdmin()), DOC_PATH), publishedOrg()),
    );
  });

  it("a signed-in user with NO email claim cannot publish (get('email','') → '' != owner)", async () => {
    await assertFails(
      setDoc(doc(db('uid-noemail', asNoEmail()), DOC_PATH), publishedOrg()),
    );
  });

  it('an UNAUTHENTICATED visitor cannot publish (isSignedIn() is false)', async () => {
    await assertFails(setDoc(doc(noAuthDb(), DOC_PATH), publishedOrg()));
  });
});

// ── reading — EVERYONE (the published org shape is public UI config) ──────────
describe('orgConfigLive · read is PUBLIC (every client renders the org shape)', () => {
  // The owner has already published — plant the doc with rules disabled, then
  // read it back through rules-bound clients of every principal class.
  beforeEach(async () => {
    await seed(DOC_PATH, publishedOrg());
  });

  it('an UNAUTHENTICATED (no-auth) visitor CAN read orgConfigLive/current', async () => {
    await assertSucceeds(getDoc(doc(noAuthDb(), DOC_PATH)));
  });

  it('a signed-in NON-owner CAN read orgConfigLive/current', async () => {
    await assertSucceeds(getDoc(doc(db('uid-other', asOther()), DOC_PATH)));
  });

  it('the ANONYMOUS catalog visitor CAN read it too (the pre-auth render path)', async () => {
    await assertSucceeds(getDoc(doc(anonDb('anon-1'), DOC_PATH)));
  });

  it('the OWNER can of course read their own published doc', async () => {
    await assertSucceeds(getDoc(doc(db('uid-owner', asOwner()), DOC_PATH)));
  });
});
