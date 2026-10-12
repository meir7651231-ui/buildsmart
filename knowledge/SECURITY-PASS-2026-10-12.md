# Security pass · 12.10.2026 (anonymous guests, askClaude, getUploadUrl)

Owner approval (12.10.2026): "מאשר את תיקוני האבטחה במאור ובבילדסמארט".
Run: 9×9 fleet, flattened — 6 auditors (cross-role, state-leakage, edge-crash,
async-race, data-seed, money-numeric) → 2 adversarial validators → 4 fixers on
disjoint files → byte-verify → gates. Lenses not run (no UI/hot-path change):
navigation, performance, accessibility-rtl, text-parity.

Branch: `claude/security-fixes-261012` (from live `claude/whats-happening-LyY9G`
@8a4a768). **Not deployed.** A push to `claude/whats-happening-LyY9G` deploys the
rules and functions to production — merging there is an owner decision.

## What changed
**firestore.rules** — every visitor is signed in anonymously before the first
frame, so `isSignedIn()` alone means "anyone".
- `siteNodes`, `projects` read → `isRealUser()` (no guest reader exists).
- `users/{uid}` create/update (self) → `isRealUser()`: each anonymous uid used to
  create a users doc ⇒ approval push to the owner + every manager and a fake
  "contractor" directory row.
- `roleRequests` create → `isRealUser()`.
- Deliberately **unchanged**: `stock`, `material_requests`, `siteStageProgress`
  (a guest can open their listeners; a listener denied while anonymous never
  resubscribes after login — `firestore_cached_repo` `_sub ??=`), and `stores`,
  `inventory`, `catalog*` (guest product-sheet store comparison reads them).

**functions/src/reviewRoleRequest.ts** — approving a request whose Auth user has no
linked provider (anonymous) throws `failed-precondition` before any status flip.

**functions/src/claude.ts (askClaude)**
- anonymous callers → `permission-denied` (before the limiter);
- caller `system` trimmed and capped at 4000 chars (largest app prompt ≈484);
- limiter fails **closed** (`unavailable`) — contention used to fail open;
- per-uid 200/day on top of 40/min, same transaction/doc;
- `kMaxTokensCap` 2048 → 1024 (largest app request is 600);
- Sonnet removed from the allowlist (no caller uses it); `concurrency: 1`;
  `maxRetries: 0` (fits the 30 s limit); `maxTokens` ≥ 1.

**functions/src/r2.ts (getUploadUrl)**
- anonymous callers → `permission-denied` (client keeps the base64 photo);
- `content-type` is now a **signed** header and the key extension always comes
  from the allowlisted type — before, any bytes/type (e.g. text/html) could be
  hosted at cdn.buildsmart-il.com;
- optional `size` (1..5 MiB) → signed `ContentLength` (the app does not send it
  yet — see backlog); expiry 600 → 300 s; `randomUUID()` in the key;
  `requestChecksumCalculation: "WHEN_REQUIRED"` (drops the empty-body CRC32 the
  SDK added to every presigned PUT).

## Verification
- rules_test on the emulator: 154/154 serial (17 new in `anon_business.test.js`).
  Mutation: reverting the projects read rule turns the new suite red (2 fails),
  restoring turns it green.
- The default parallel run is **flaky** (before and after this change): four
  suites share projectId `demo-buildsmart` and wipe it in `beforeEach`, so 1–3
  unrelated tests fail at random; each passes alone and the serial run is green.
- functions: `tsc` exit 0; `selftest` 100/100.
- Not run: the real network PUT to R2. After deploying functions, PUT a real JPEG
  (expect 200) and a `text/html` body with an image URL (expect 403).

## Backlog (not done — needs a decision or a Flutter change)
- Flutter: providers for stock / material_requests / siteStageProgress must watch
  auth and clear `_sub` on error — then close those reads to anonymous too.
- Flutter: send `size: bytes.length` to getUploadUrl, then make `size` required.
- Flutter: guest-facing AI buttons should ask to sign in instead of failing.
- Flutter (pre-existing): `auth_state.dart` listens to `authStateChanges()` only,
  so an in-place link upgrade keeps `isAnonymous` true until restart.
- `credit.ts` computeCredit looks customers up by self-writable `displayName`.
- `hasRole()` without `isRealUser()`; anonymous creates in tasks / vacation /
  analytics / presence; audit-log flood via callables; global daily AI budget;
  fixed → sliding window; `studio.ts` publishConfig limiter also fails open.
- Clean up existing guest `users` docs and their `directory` rows (Admin script).
- rules_test is not run by any workflow, and `firebase-deploy.yml` deploys rules on
  push to the live branch — add the emulator suite before the deploy step.
- Stale comments elsewhere: studio.ts / analytics.ts line refs to claude.ts,
  `manager_copilot_screen.dart:109` (2048), `WIRING.md:3231`,
  `app_flutter/knowledge/backend/{claude,r2}` snapshots, `functions/README.md:99`.
