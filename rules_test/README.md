# rules_test — S5.8 emulator suite for `/firestore.rules`

Unit tests for the BuildSmart Firestore Security Rules (server-connect §S5),
written with `@firebase/rules-unit-testing` v4 over node's built-in test runner
(`node --test` — no mocha/jest). They run ONLY against the **Firestore
emulator** — never against the live `buildsmart-b0b78` project.

## What is covered (the SSOT S5.8 matrix + extras)

| Suite | SSOT row | Asserts |
|---|---|---|
| users | S5.1 | read self/admin · `role`/`roles` mirror write = **admin-only** · self may update `fcmToken` (S6.1) · self-delete (S1.8) |
| chat | S5.2/S5.3 | thread read/write **participants-only** · S4.1 `arrayContains` query allowed, full-collection listen denied · message read via thread `get()` · create only as self (`fromUid == auth.uid`, no spoofing) · messages immutable · participants frozen on update |
| customers | S5.4 | credit read = manager/owner only · **store blocked** · write manager-only (owner cannot raise own limit) |
| store isolation | S5.8 | store cannot read customers/finance/foreign orders/foreign chat; CAN read its assigned order + shared stock |
| orders | S5.5 | contractor creates at `'new'` bound to self · store chain `new→preparing→ready` · courier chain `ready→pickup→transit→delivered` · stage-only diffs · assignment binding (`storeId`/`courierId`) · manager god-step (`setStage`) · bogus stage rejected · `roles:[…]` multi-claim works |
| S5.6 + finance + default | S5.6/S3.F | stock write = store/manager · tasks = worker/manager · siteStageProgress = contractor/worker/manager · projects bound to `contractorId` · finance writes manager-only · unmatched collection denied even for admin |

## Run (local / CI)

Prereqs: Node 18+ (uses `node --test`), Java 11+ (the emulator is a JAR),
network for the first `npm install` + emulator JAR download.

```bash
cd rules_test
npm install                      # @firebase/rules-unit-testing + firebase + firebase-tools
npm run test:emulator            # = firebase emulators:exec --only firestore --project demo-buildsmart "npm test"
```

`emulators:exec` boots the Firestore emulator (reading `../firebase.json` →
`firestore.rules`), exports `FIRESTORE_EMULATOR_HOST` (which
`initializeTestEnvironment` auto-discovers), runs the suite, and tears the
emulator down. Exit code ≠ 0 on any failing assertion — wire it as the CI gate.

Run from the repo root instead (global firebase-tools):

```bash
npm --prefix rules_test install
firebase emulators:exec --only firestore --project demo-buildsmart "npm --prefix rules_test test"
```

If the emulator is already running separately (`firebase emulators:start
--only firestore`), point the suite at it and run the tests directly:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm test
```

### CI (GitHub Actions) sketch

```yaml
- uses: actions/setup-node@v4
  with: { node-version: 22 }
- uses: actions/setup-java@v4
  with: { distribution: temurin, java-version: 21 }
- run: npm --prefix rules_test ci || npm --prefix rules_test install
- run: npx --prefix rules_test firebase emulators:exec --only firestore --project demo-buildsmart "npm --prefix rules_test test"
```

## Deploying the rules (after green tests)

```bash
firebase deploy --only firestore:rules --project buildsmart-b0b78
```

(`firebase.json` already points `"firestore": {"rules": "firestore.rules"}`.)

## S5.7 — App Check enforcement (console step, NOT code)

After the clients ship with the App Check provider (S0.5 — debug provider in
dev, Play Integrity / DeviceCheck in prod):

1. Firebase console → **App Check** → register each app (Android/iOS/Web).
2. App Check → **APIs** → **Cloud Firestore** → **Enforce**.

This blocks non-app clients at the transport layer, on top of these rules.
Do it only once real devices attest successfully — enforcement with no
registered provider bricks all clients.

## ⚠️ Operational notes (read before flipping production)

- **uid migration first** — `chatThreads.participants` currently carries ROLE
  NAMES and `chatMessages.fromUid` is omitted (pre-S1-join contract documented
  in `app_flutter/lib/data/repositories/chat_firebase.dart`); `orders.contractorId`
  carries display names. These rules implement the post-migration uid contract,
  so pre-migration chat/order writes are denied by design.
- **Rules are not filters** — `FirestoreCollectionSource` listens to whole
  collections today; non-manager listens on participant-scoped collections will
  be denied as a whole until queries are scoped (e.g. S4.1
  `where('participants', arrayContains: uid)`).
- The fresh-backend seed push (`onFirstSnapshotEmpty → pushCacheToRemote`)
  only succeeds from a session whose role may create those docs — seed from an
  admin/manager session or the emulator, not an arbitrary first client.
