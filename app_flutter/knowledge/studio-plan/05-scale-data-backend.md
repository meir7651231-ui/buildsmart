# Pillar #5 — Scale, Data Architecture, Backend & Publish-to-All

> **The integrating layer.** Pillars 1–4 (Studio config engine · domain/trade builder · live customer intelligence · AI) decide *what* the platform does. **This pillar owns how all of it PERSISTS, SYNCS, SEARCHES, SECURES and SCALES** — to **tens of thousands of products and thousands of customers** — without breaking the flags-OFF offline demo.
>
> **Branch:** `claude/whats-happening-LyY9G`. **Region:** `me-west1` (Tel Aviv), matching the Firestore DB + `kAuthFunctionsRegion` + every existing function (`functions/src/common.ts:17`).
>
> **Prime directive (non-negotiable, repeated from every backend flag):** with all server flags OFF the build is **byte-identical** to today. Every mechanism below ships *behind a flag/seam* exactly as `kUseFirebaseBackendFlag`, `kUidScopedQueries`, `kServerCallables`, `kCloudPhotos`, `kSeedFreshBackend`, `kClaudeAi`, `kAppCheckProd` already do (`lib/data/repositories/backend.dart:12–189`). Tests never initialise Firebase, so they stay on `_local` regardless.

---

## 0. Grounding — what already exists (cite-first, build-on-not-replace)

The stack is **decided**. Do not propose Algolia-the-service, Supabase, a GraphQL gateway, or a second datastore. Everything below extends these exact seams:

| Existing seam | File:line | What it gives us |
|---|---|---|
| **Backend master flags** (8) | `lib/data/repositories/backend.dart:12,35,66,102,127,138,170,188` | The compile-time `bool.fromEnvironment` + `Firebase.apps.isNotEmpty` gate pattern. Every new capability gets ONE more flag here, default OFF. |
| **Offline-first cache base** | `lib/data/repositories/firestore_cached_repo.dart:152` (`FirestoreCachedRepo<T>`) | The whole bridge: sync `cached()` reads (`:196`) over an async `snapshots()` listener (`:204`), optimistic `upsert` + guarded background `set` (`:258`), born-seeded cache (`:155`), per-doc corrupt-skip (`:236`), first-empty-snapshot seed hook (`:190`), scoped-vs-unscoped empty discrimination (`:222`). **LWW reconcile** = a later snapshot replaces the cache (`:241`). |
| **Injectable remote seam** | `firestore_cached_repo.dart:61` (`RemoteCollectionSource`) → `:85` (`FirestoreCollectionSource`) | Talks neutral `RemoteDoc` (id+map, `:50`), resolves `FirebaseFirestore.instance` **lazily** (`:117`), optional `scope` builder for uid-scoped listens (`:111`), `isScoped` (`:141`). Firebase-free + fake-testable. |
| **Repo pair pattern** | `*_repository.dart` (abstract) · `*_local.dart` (const/in-mem) · `*_firebase.dart` (cache base) ×6 | orders/customers/stock/finance/site/chat. Provider switch is the ONLY thing that changes (`orders_firebase.dart:44`). |
| **Cloud Functions** (gen2, me-west1) | `functions/src/index.ts` | `setRole` (`:41`), `advanceOrderStage`+`revertIllegalOrderStageWrite` (`orders.ts`), `computeCredit` (`credit.ts`), `askClaude` (`claude.ts`, w/ per-uid rate limit `:75` + model allowlist `:35`), `getUploadUrl` (`r2.ts`, presigned PUT, server-owned key `:127`), `reviewRoleRequest`, `deleteAccount`, push triggers. **Append-only `auditLog`** (`audit.ts:45`). All resolve Admin SDK **lazily** (`common.ts:20`). |
| **Security rules** (deny-by-default) | `firestore.rules` | RBAC by **custom claim** (`role`/`roles`/`admin`, `:75`), `isManager()` god-role (`:83`), per-collection ownership gates, "RULES ARE NOT FILTERS" doctrine (`:43`), catalog deliberately **NOT a collection** (`:514`). |
| **Composite indexes** | `firestore.indexes.json` | 7 indexes; `ts` is an **ISO-8601 string** (sorts lexicographically == chrono, see header). Deploy: `firebase deploy --only firestore:indexes`. |
| **Catalog (the scale problem)** | `lib/data/repositories/catalog_local.dart:44` over `kCatalogProducts` (`data/polyroll_catalog.dart:1521` — unified `[...kLipskeyCatalog, ...kPolyrollCatalog, ...kHuliotCatalog]`) | **~1,853 products** today (924 Lipskey + 758 Polyroll + 171 Huliot, three const Dart files: `lipskey_catalog.dart` 400 KB, `polyroll_catalog.dart` 262 KB, `huliot_smartlock_catalog.dart`; `catalog_repository.dart:13` says "1,877" — the live list is 1,853). **const-backed, PURE repo, no `Ref`, no `catalog_firebase.dart`, no Firestore rule** — intentionally bundled/CDN static (`firestore.rules:514`). `CatalogRepository` (`catalog_repository.dart:36`) is the swap seam already declared "a future product API drops in behind this contract." Curated `kSmartProducts` = 83 fixtures (`smart_tree.dart:153`). |
| **Product model** | `lib/data/lipskey_catalog.dart:4` (`LipskeyCatalogProduct`) | `sku, nameHe, nameEn, color, qtyPack, qtyPallet, categoryHe, categoryEn, categoryEmoji, page, dims:Map, imageFile, imageFiles, specImageFile(s), brand`. |
| **Search (today)** | `lib/data/fuzzy_search.dart:16` (`fuzzySearchProducts`) | In-memory scan of `kCatalogProducts`: every query word must `contains` in `nameHe`, ranked by whole-phrase substring (score 0) then word-proximity. Call-sites: `catalog_screen.dart:375,426`, `ai_finder_screen.dart:130`, `ai_assistant_screen.dart:146`. Nav search = `kSearchIndex` (`search_index.dart:45`, 509 entries) via `.matches()`. |
| **Image-at-scale (the template to copy)** | `lib/data/product_images.dart` | `kImageBaseUrl` = `--dart-define=IMAGE_BASE_URL` defaulting to a **live R2 bucket**; `resolveProductImage()` returns `CachedNetworkImageProvider` when set, `AssetImage` when empty (`:if kImageBaseUrl.isEmpty`); **LRU-bounded `CacheManager`** (700 objects, 60-day stale) explicitly designed "even with a 60k+ image catalog." **This is the exact shape Pillar 5 generalises to catalog DATA.** |
| **List virtualization (today)** | `catalog_screen.dart:2266,3064` | Already lazy: `ListView.builder` + `SliverList`. Pagination is the only missing piece. |
| **Telemetry seam** | `lib/state/telemetry.dart` (`TelemetrySink` → `FirebaseTelemetrySink`/`NoopTelemetrySink`), `lib/state/analytics_log.dart` (in-mem ring buffer, 500) | Gated on `useFirebaseBackend`; Noop on the demo path. **No event-stream collection, no presence yet** — Pillar 3's persistence is greenfield (this pillar builds it). |
| **Offline order queue** | `lib/logic/offline_order_queue.dart:164` | Explicit FIFO replay queue + `connectivity_plus` IS now a dep (`pubspec.yaml`); the "no connectivity_plus" comment at `:27` is stale. |
| **Gate** | `test/knowledge_protocol_test.dart`, `test/protocol_security_test.dart`, `scripts/audit_gates.sh` | The 100-gate protocol + governance #84 (owner/manager claim gates writes). |

**Packages already on hand** (no new deps unless flagged): `cloud_firestore ^6.5`, `cloud_functions ^6.3`, `firebase_auth ^6.5`, `firebase_messaging`, `firebase_app_check`, `firebase_analytics ^12`, `firebase_crashlytics ^5`, `cached_network_image ^3.4` + `flutter_cache_manager ^3.4`, `connectivity_plus ^6.1`, `http ^1.6`, `shared_preferences`.

---

## 1. Firestore data model — the four new/extended domains

**Conventions inherited (do not deviate — `knowledge/firestore-schema.md`, `offline-sync.md`):**
- doc-id = the natural key (uid for users, `BS-####` for orders) — never duplicate the id as a field.
- `ts` and all timestamps = **ISO-8601 strings** (`DateTime.toIso8601String()`), so string indexes sort chronologically.
- Field naming mirrors the model⇄doc mappers (e.g. `who→contractorId`, `site→siteAddress`).
- Local persist keys are versioned `bs.<feature>.v1`.
- Every collection MUST have an explicit rule (deny-by-default catches the rest, `firestore.rules:517`).

### 1.1 Pillar 1 — the no-code CONFIG tree (draft + published)

The config is a **tree of nodes** (categories → trades → products → leaves/settings), authored by the owner, that must (a) stay editable as a draft only the owner sees, (b) publish atomically to every client, (c) stay fast at 10Ks ids. **Two representations**, because they have opposite access patterns:

**A. `studioConfig/{channel}` — the PUBLISH POINTER (tiny, hot, read by everyone).**
```
studioConfig/published   { version: int, ref: "studioConfigSnapshots/v1287",
                           publishedAt: iso, publishedBy: uid,
                           checksum: "sha256…", schema: int }
studioConfig/draft       { version, ref: "studioConfigSnapshots/draft-<uid>",
                           updatedAt, updatedBy }
```
- doc-id is a fixed channel name (`published` / `draft`) so **every client listens to ONE known doc** — the cache-bust signal (§3). ~200 bytes.
- It points (`ref`) at an immutable snapshot doc; clients diff `version` to decide whether to re-pull the snapshot.

**B. `studioConfigSnapshots/{snapshotId}` — IMMUTABLE versioned blobs.**
- Each publish writes a **new** snapshot doc (`v1`, `v2`, …; draft = `draft-<uid>`), never mutates an old one → free rollback + audit history + no torn reads.
- The tree itself is stored **sharded by size**: a snapshot is a parent doc `{ version, nodeCount, shardCount, shards:["…/0","…/1"] }` plus `studioConfigSnapshots/{id}/shards/{n}` subcollection docs, each holding ≤ ~500 KB of serialized nodes (the 1 MiB Firestore doc ceiling; we cap at 500 KB for headroom).
  - At ≤ a few thousand nodes the whole tree fits in ONE shard doc → one read on publish. At 10Ks nodes it's a handful of shard docs read in parallel, cached locally, re-pulled only on `version` bump.
- **Why not one-doc-per-node?** 10K config nodes = 10K reads per cold start per user × thousands of users = ruinous (see §6 cost model). The tree is read-mostly and published atomically, so a **sharded blob** is read-amplification-optimal. Per-node docs are reserved for the *authored catalog* (§1.2), which needs query/pagination, not the config tree, which needs whole-tree atomic swap.

**Draft isolation:** the draft snapshot id is `draft-<ownerUid>`; rules grant read/write only to the owner/manager (§5). Publish = "freeze the draft into the next immutable `vN`, then flip `studioConfig/published.ref+version`" — a server callable (§3.2) so it's atomic and audited.

### 1.2 Pillar 2 — authored TRADES / catalog at 10Ks products

This is the **only** domain that needs query + pagination + search at scale, so it gets a real per-doc collection — the future foretold by `catalog_repository.dart:8` ("a future product API drops in behind this contract").

```
catalogProducts/{sku}    {                         // doc-id = SKU (natural key)
   sku, nameHe, nameEn, brand, color,
   categoryHe, categoryEn, categoryEmoji,
   tradeId,                    // Pillar-2 trade (electrician/plumber/…)
   qtyPack, qtyPallet, page, dims:Map,
   imageFile, imageFiles:[], specImageFile, specImageFiles:[],
   price:int?, active:bool, version:int,
   updatedAt:iso, updatedBy:uid,
   nameTokens:[ "ברז","aquatec",… ],   // §2 — lowercased prefix/word tokens for at-scale search
   catalogShard:int            // 0..N — bucket for shard-fanout listens (§1.6)
}
catalogTrades/{tradeId}  { nameHe, nameEn, emoji, order, active, productCount }
catalogCategories/{catId}{ nameHe, emoji, tradeId, order }
```
- **doc-id = SKU** ⇒ idempotent upserts, no dup detection, `productForSku` is a single `get`.
- The Dart `LipskeyCatalogProduct` model is **unchanged**; the `_firebase` mapper adds the new fields (`toDoc`/`fromDoc`) exactly like `orders_firebase.dart:70` adds `contractorUid`/`storeUid` only when non-empty — backward-compatible round-trip.
- `version` per product + a collection-level `catalogProducts` aggregate enables incremental sync (§7) and the search-index trigger (§2).

### 1.3 Pillar 3 — analytics event stream + presence

Append-only, write-amplification-aware, **owner-read-only**:

```
analyticsEvents/{autoId}  { name, props:Map, uid, role, sessionId,
                            at:iso, day:"2026-06-23", clientTs:iso }
   // write-only-from-client, read-only-owner. doc-id = auto (no hotspotting).
presence/{uid}            { online:bool, lastSeen:iso, screen, role, sessionId }
   // one doc per user, self-write, owner+self read. Heartbeat from client.
analyticsDaily/{day}      { counts:{order_placed:N,…}, uniques:int }
   // server-rollup (scheduled fn), so the owner reads ONE doc/day, not 100K events.
```
- **Sharding the write hotspot:** auto-ids already scatter writes across the keyspace (Firestore's recommended pattern) — no `day`-prefixed doc-ids that would hotspot a single date partition. High-volume counters (e.g. "products viewed today") use **distributed counter shards**: `analyticsCounters/{metric}/shards/{0..9}`, incremented at a random shard, summed by the rollup.
- **Presence** is the cheapest correct design: a single self-owned doc per user with a debounced heartbeat (§3.4), TTL-swept by a scheduled function (Firestore TTL policy on `lastSeen` or a daily cleanup). Owner's "מי מחובר" view = `where('online','==',true)` (indexed). At thousands of users this is thousands of small docs — fine; if it grows, shard presence by `presence_{bucket}` regions read in parallel.
- **Never** put raw event payloads in a doc-id or in a client-readable place — `analytics_log.dart` already documents "event payloads may carry sensitive context." The owner reads **rollups** by default; raw `analyticsEvents` are owner-only and queried, not streamed.

### 1.4 customers / orders (extend existing)

Already modelled (`firestore-schema.md`, rules `:181,:200`). For **thousands of customers** the only changes are:
- `customers/{id}` gains `ownerId` (already FORWARD-READY in rules `:194` + index `:75`) so the per-owner scoped list lights up; add `searchTokens` if customer search at scale is needed (same §2 mechanism).
- Orders already scope by `contractorUid`/`storeUid`/`courierUid` with indexes (`firestore.indexes.json:50–73`) — at 10Ks orders the **pagination** (§4) is the only addition; the data model is correct.

### 1.5 Collection summary + index plan (additions to `firestore.indexes.json`)

| New composite index | Serves |
|---|---|
| `catalogProducts (tradeId ASC, nameHe ASC)` | trade-scoped catalog list, paginated |
| `catalogProducts (categoryHe ASC, nameHe ASC)` | category browse, paginated |
| `catalogProducts (active ASC, updatedAt DESC)` | incremental sync + admin "recently edited" |
| `catalogProducts (nameTokens ARRAY_CONTAINS, nameHe ASC)` | at-scale token search (§2) |
| `analyticsEvents (day ASC, name ASC)` | owner daily drill-down |
| `analyticsEvents (uid ASC, at DESC)` | per-user trail (support) |
| `presence (online ASC, lastSeen DESC)` | "who's online now" |
| `customers (searchTokens ARRAY_CONTAINS, used DESC)` | customer search at scale (optional) |

`studioConfig*` need **no** composite index (fixed doc-id gets/listens only). Keep `fieldOverrides:[]` so every collection keeps its automatic single-field indexes (matching the existing file's note).

### 1.6 Sharding / pagination primitives
- **Catalog browse:** `query.orderBy(nameHe).startAfterDocument(last).limit(40)` cursor pagination (§4). Never `offset` (bills skipped docs).
- **Config tree:** sharded blob (§1.1B), read by `version`, not paginated.
- **Analytics:** auto-id scatter + distributed counters + daily rollups (§1.3).
- **`catalogShard`** field lets a non-owner role that must *listen* (rare) subscribe to one bucket at a time, but the default catalog path is **paginated query, not a listen** (§4) — a 10K-product live listener is forbidden (cost + memory).

---

## 2. Indexed SEARCH at scale (10Ks products)

**The constraint (from the prompt + `firestore.rules:514`):** current search is in-memory over the const catalog and the **flags-OFF offline demo must keep working byte-identically**. So search has **two layers behind one seam**, chosen at runtime by the same `useFirebaseBackend` gate.

### 2.1 The seam
Add `SearchRepository` (new abstract, mirrors `CatalogRepository`'s server-ready shape) with the local impl wrapping today's `fuzzySearchProducts` **verbatim** and a `_firebase` impl. UI calls the provider; nothing in `catalog_screen.dart`/`ai_finder_screen.dart` changes except the import target (the `catalog_repository.dart:8` swap-implementation-only promise).

```
abstract class SearchRepository {
  Future<List<LipskeyCatalogProduct>> search(String query, {int limit, Cursor? after});
}
```
Note the return is `Future` — but the **local** impl resolves synchronously (`SynchronousFuture`), so the demo path has zero latency change. The signature is async so the server impl can page.

### 2.2 Layer A — local fuzzy (flags OFF, the offline demo) — UNCHANGED
`fuzzy_search.dart:16` stays the body of `LocalSearchRepository.search`. Byte-identical behaviour, no network, works offline. **This is the zero-regression guarantee for search.** At 1,877 bundled rows it is instant; if the bundle ever shrinks (catalog moves server-side, §8), the local layer searches whatever is still bundled (the "starter" subset) so offline never shows an empty catalog.

### 2.3 Layer B — at-scale server search (flag `CATALOG_SERVER_SEARCH`, ON only with Firebase)
Firestore has **no full-text search**, so we use the **token-array + composite-index** pattern (Google's recommended no-extra-service approach), layered with the *existing* fuzzy ranker for quality:

1. **Index build (server, on write):** a Cloud Function `onCatalogProductWrite` (gen2, `onDocumentWritten catalogProducts/{sku}`, me-west1) derives `nameTokens` = lowercased, NFKD-folded **word tokens + 3-gram prefixes** of `nameHe`+`nameEn`+`brand`+`sku`, and writes them back to the doc (loop-guarded like `revertIllegalOrderStageWrite` via a `tokensVersion` stamp, `orders.ts:158`). Hebrew note: tokenize on whitespace + strip niqqud; RTL is data-safe (we store/compare lowercased strings, no bidi reshaping).
2. **Query (client):** `catalogProducts.where('nameTokens', arrayContains: firstToken).orderBy('nameHe').limit(N)` — Firestore returns the candidate set the composite index serves (`§1.5`). For multi-word queries, filter on the **rarest** token server-side (one `arrayContains`), then apply `fuzzySearchProducts(query, products: candidates)` **client-side over the small candidate page** to reproduce today's exact ranking. → server narrows 10Ks→tens; the existing ranker orders them; UX identical, ranking identical.
3. **Pagination:** cursor over the same query (`startAfterDocument`), so "load more" streams pages, never the whole 10K.

**Why not Algolia/Typesense?** The prompt says do not introduce a different stack and `firestore.rules:514` commits to "no extra service." The token-array path needs **zero new infra**, reuses our index file + functions runtime, and keeps the fuzzy ranker we already ship. If a future need for typo-tolerance beyond prefixes arises, it slots in behind the *same* `SearchRepository` seam (swap-impl-only) — but it is explicitly out of scope here.

### 2.4 Search cost guardrail
A token query reads only the returned page (≤ `limit` docs). With prefix tokens, a 3-char query returns a bounded candidate set; we cap `limit=40` (matching `catalog_screen.dart:375`). Recent searches (`recent_searches.dart`, `bs.recent-searches.v1`) stay client-side — no server round-trip for the dropdown.

---

## 3. PUBLISH-TO-ALL — real-time config push (the headline feature)

**Goal:** owner taps "פרסם" → config reaches **all** users in seconds; draft stays owner-only.

### 3.1 The mechanism (built on the cache base, not a new framework)
Every client opens **one** `snapshots()` listener on `studioConfig/published` (a single ~200-byte doc) via a new `StudioConfigRepository` extending `FirestoreCachedRepo` (so it gets the born-seeded cache, guarded attach, corrupt-skip for free). The cache seed = the **bundled** config (today's hardcoded tree) so flags-OFF and cold-start are non-empty.

Flow:
1. Owner edits draft (writes to `studioConfigSnapshots/draft-<uid>` shards + bumps `studioConfig/draft.version`). **No other client sees it** (rules §5).
2. Owner taps publish → `publishConfig` callable (§3.2) freezes draft→`vN`, flips `studioConfig/published {version:N, ref, checksum}`.
3. Firestore fans the single-doc change out to **every** listening client in ~1–2 s.
4. Each client's listener fires: compares incoming `version` to cached `version`. If newer → pulls `studioConfigSnapshots/vN` shards (cached by id; usually 1 read), validates `checksum`, atomically swaps the in-memory config + `notifyListeners()`. **Cache-bust** = the version bump itself; the old snapshot stays immutable so an in-flight reader is never torn.

This is exactly the LWW reconcile the cache base already does (`firestore_cached_repo.dart:241`) — a snapshot event replaces local state — just applied to a config pointer instead of a list.

### 3.2 `publishConfig` callable (new, `functions/src/studio.ts`, me-west1)
Mirrors `advanceOrderStage` (`orders.ts:50`): auth-gated, **manager/admin-only** (governance #84), runs in a transaction:
- reads `studioConfig/draft`, copies its shards into a new immutable `studioConfigSnapshots/vN` (N = `published.version+1`), computes `checksum`, writes `studioConfig/published {version:N, ref, checksum, publishedBy, publishedAt}`.
- `writeAudit({action:"config.publish", before:{version:N-1}, after:{version:N}})` (`audit.ts:45`).
- Returns `{ok, version:N}`. A `FirebaseFunctionsException` (not-deployed/denied) surfaces honestly (the `kServerCallables` posture).
- **`revertIllegalConfigWrite` trigger** (defense-in-depth, like `orders.ts:145`): any direct client write to `studioConfig/published` that didn't come from the callable (no matching audit/`publishGuard` stamp) is reverted — the callable is the only sanctioned publish path.

### 3.3 Why a pointer + immutable snapshots (not "edit the live doc")
- **Atomic for 10Ks nodes:** flipping one tiny pointer is atomic; rewriting a giant live tree is not, and would stream partial states to clients.
- **Rollback = re-point** to `v(N-1)` (one write).
- **Read-amplification:** clients re-pull the heavy snapshot **only on version change**, not on every unrelated field touch.
- **Draft never leaks:** it's a *different doc id* with owner-only rules; there is no "isPublished flag on the live doc" race.

### 3.4 Presence push (Pillar 3, same listener discipline)
Client writes `presence/{uid}` on foreground/route-change, **debounced** (≥30 s between heartbeats, coalesced) to bound writes; sets `online:false` on `dispose`/`AppLifecycleState.paused`. Owner's live view listens to `where('online','==',true)` (bounded by index). TTL/scheduled sweep flips stale `online:true` (no heartbeat > 2 min) to false so a crashed client doesn't linger.

---

## 4. Performance — virtualization, pagination, cache, cold-start

| Concern | Design | Grounding |
|---|---|---|
| **List virtualization** | Already lazy (`ListView.builder` `catalog_screen.dart:2266`, `SliverList :3064`). Keep. Add **paged** data source so `itemCount` grows as pages load (sentinel last row triggers next page — the `capped ? 1 : 0` row at `:2267` is already the hook). | existing |
| **Pagination** | Cursor (`startAfterDocument`/`limit(40)`) for `catalogProducts`, orders, customers, analytics. **Never** Firestore `offset` (billed). A small `PagedQuery<T>` helper wraps the `RemoteCollectionSource` seam; flags-OFF returns the full local list in one synchronous page. | `firestore.indexes.json` |
| **Catalog data cache** | Generalise the **image** template (`product_images.dart`): `CATALOG_BASE_URL` dart-define → when set, the `_firebase`/CDN catalog source is used and pages are cached in a bounded `CacheManager`; when empty → bundled const catalog (today). Same `kImageBaseUrl.isEmpty ? AssetImage : CachedNetworkImage` switch, applied to data. | `product_images.dart` (the proven pattern) |
| **Image cache** | Untouched — `productImageCache` LRU 700 / 60-day already "60k+ catalog" safe. | `product_images.dart` |
| **Config tree fast at 10Ks ids** | Sharded blob read **once** then cached; only re-read on `version` bump. In-memory tree is a `Map<id,node>` for O(1) lookup (mirrors `smartProductByKey` const-map access today). No per-node listener. | §1.1, §3 |
| **Cold-start** | Born-seeded caches (`firestore_cached_repo.dart:155`) keep **every** surface non-empty before the first snapshot — already the invariant. Config + catalog seeds = the bundled tree/starter products, so first paint never blocks on network. Firestore `persistenceEnabled:true` (`main.dart`, S0.4) serves the last-synced data offline on next launch. | existing |
| **Listener budget** | A device opens a *bounded* set of listeners: config-pointer (1), uid-scoped orders (1), chat threads (1), presence-of-self (write-only). **No** whole-catalog or whole-analytics listener. Everything 10Ks is **paged queries**, not streams. | §2, §4 |
| **Memory** | Paged catalog never holds 10K models in RAM (only loaded pages + LRU). Config tree is the only large in-memory structure; at 10Ks lightweight nodes (~a few MB) it's fine, and it's read-mostly. | — |

---

## 5. Security rules extensions (extend `firestore.rules`, keep deny-by-default)

Reuse the existing helpers verbatim — `isSignedIn()` (`:64`), `isAdmin()` (`:69`), `hasRole(r)` (`:75`), `isManager()` (`:83`). Roles are **custom claims** written only by `setRole`/`reviewRoleRequest` (the SSOT). Governance #84 = **owner/manager claim gates all config/catalog writes.** Add these match blocks before the `match /{document=**}` catch-all (`:517`):

```
// ── Pillar 1 · no-code config — owner/manager WRITE, world READ (published only)
match /studioConfig/{channel} {
  allow read: if channel == 'published'           // everyone reads the live config
              || isManager();                     // only owner sees the draft pointer
  allow write: if false;                          // ONLY via publishConfig callable (Admin SDK)
}
match /studioConfigSnapshots/{snap} {
  allow read: if !snap.matches('draft-.*') ? isSignedIn()   // immutable published vN: any signed-in
                                           : isManager();    // draft-* shards: owner-only
  allow read, write: if isManager();              // owner authors the draft (+ its /shards)
  match /shards/{n} {
    allow read: if isSignedIn() && !snap.matches('draft-.*') || isManager();
    allow write: if isManager();
  }
}

// ── Pillar 2 · authored catalog/trades — owner/manager WRITE, world READ
match /catalogProducts/{sku} {
  allow read: if isSignedIn();                    // catalog is readable by every persona
  allow write: if isManager();                    // owner authors products (governance #84)
}
match /catalogTrades/{tradeId}   { allow read: if isSignedIn(); allow write: if isManager(); }
match /catalogCategories/{catId} { allow read: if isSignedIn(); allow write: if isManager(); }

// ── Pillar 3 · analytics — WRITE-ONLY from client, READ-ONLY owner
match /analyticsEvents/{id} {
  allow create: if isSignedIn()
                && request.resource.data.uid == request.auth.uid   // no spoofing the actor
                && !('serverOnly' in request.resource.data);
  allow read:   if isManager();                   // owner reads the stream/drill-down
  allow update, delete: if false;                 // append-only, like auditLog
}
match /presence/{uid} {
  allow read:  if isManager() || (isSignedIn() && request.auth.uid == uid);
  allow write: if isSignedIn() && request.auth.uid == uid;  // self-presence only
}
match /analyticsDaily/{day}    { allow read: if isManager(); allow write: if false; } // rollup = Admin SDK
match /analyticsCounters/{m}   { allow read: if isManager();
  match /shards/{n} { allow read: if isManager(); allow write: if false; } }
```

**RBAC notes:**
- All config/catalog **writes go through the callable or a manager session** — `allow write: if isManager()` is the per-persona-read / owner-write split the governance ruling demands.
- `studioConfig/published` is `allow write: if false` so the *only* writer is `publishConfig` (Admin SDK, rules-exempt) — defense-in-depth pairs with `revertIllegalConfigWrite` (§3.2).
- Analytics mirrors `auditLog`'s end-to-end stance (`audit.ts:8`): client may only **append** its own event; only the owner reads; rollups are server-only.
- **"RULES ARE NOT FILTERS" (`:43`) still holds** — the catalog read is `isSignedIn()` (whole collection readable) so a paginated query is allowed; analytics/presence reads are owner-scoped so clients MUST query their own slice.
- **App Check** enforcement stays a console toggle (`:14`) — flip it for `catalogProducts`/`studioConfig` once `kAppCheckProd` ships, same all-callables-together hardening as `claude.ts:5`.

---

## 6. Cost / quota model + Blaze guardrails

The danger zone is **read-amplification of config-push** and **write-amplification of analytics** at thousands of users. Numbers (Firestore: $0.06/100K reads, $0.18/100K writes, $0.18/GiB egress, free tier 50K reads / 20K writes / day):

| Event | Naive cost | Designed cost | Saving |
|---|---|---|---|
| **Publish to 5,000 users** | per-node tree, 10K nodes → 5,000 × 10K = **50M reads** per publish | pointer-listen: 5,000 × 1 (pointer) + 5,000 × ~1 (one cached snapshot shard) ≈ **10K reads** | ~5000× |
| **Cold start, 5,000 users/day** | re-read whole tree each → 50M reads/day | pointer (cached) + snapshot only if version changed → ~**5K–10K reads/day** | huge |
| **Analytics, 5,000 users × 50 events/day** | 250K writes/day (+ counter contention) | auto-id scatter (no hotspot) = 250K writes ≈ **$0.45/day**; owner reads **1 rollup doc/day** not 250K events | bounded reads |
| **Catalog browse** | live 10K listener per user = 10K reads × users | paged 40/scroll, cached → tens of reads/session | ~250× |
| **Presence, 5,000 users** | per-keystroke heartbeat | debounced ≥30 s + on-change only → bounded; sweep is one scheduled fn | bounded |

**Guardrails (concrete):**
1. **Config = pointer + immutable snapshot** (§3.3) is the single biggest cost lever — it converts publish from O(users×nodes) reads to O(users) reads.
2. **No 10Ks live listeners** — catalog/analytics are paged queries; only tiny/bounded docs get `snapshots()`.
3. **Distributed counters** for hot metrics; **daily rollups** so the owner dashboard reads ~1 doc/day, not the raw stream.
4. **Callable concurrency caps** like `askClaude` (`maxInstances:10`, `claude.ts:115`) on `publishConfig` and any fan-out function → hard ceiling on burst spend. Per-uid rate-limit (`claude.ts:75` pattern) on analytics-heavy callables if any.
5. **Budget alert** (Cloud Billing budget at the project) + a **kill-switch flag**: `STUDIO_LIVE` default OFF means even with code deployed, the live config listener doesn't attach until the owner opts in — the same flag discipline that keeps everything else dark by default.
6. **Egress**: snapshot shards are JSON (text, gzip-friendly); cap shard at 500 KB; a 10K-node tree ≈ a few MB pulled **once per version** per user, cached thereafter.
7. **TTL** on `analyticsEvents` (e.g. 90 days) and stale `presence` so storage doesn't grow unbounded.

---

## 7. Offline degradation (everything must degrade gracefully)

The app is **offline-first demo with flags OFF** — that posture is preserved and extended:

| Capability | Offline behaviour |
|---|---|
| **Config tree** | Born-seeded with the bundled tree (`firestore_cached_repo.dart:155`); flags-OFF it IS the bundled const tree (byte-identical). With Firebase ON but offline, Firestore `persistenceEnabled:true` serves the last-synced `studioConfig/published` + cached snapshot from disk → the user sees the last published config, not a blank. On reconnect the listener catches up (LWW). |
| **Catalog** | `CATALOG_BASE_URL` empty (default) → bundled const catalog, fully offline. ON but offline → cached pages from `CacheManager` + Firestore disk cache; un-cached pages show the existing placeholder, never crash. Local fuzzy search (§2.2) always works offline over whatever is bundled/cached. |
| **Search** | Layer A (local fuzzy) is the offline path — **always available**, no network. Layer B degrades to Layer A when offline (the seam picks the local impl when `!useFirebaseBackend` or on a caught network error). |
| **Publish-to-all** | Owner offline → publish callable fails honestly (`FirebaseFunctionsException`), surfaced as "no connection," draft preserved locally; nothing half-publishes. Other users offline → keep last config, pick up the new version on reconnect. |
| **Analytics/presence** | Events buffer in the in-mem ring (`analytics_log.dart`) + Firestore's native write queue (offline writes replay on reconnect, like `offline_order_queue.dart:9` describes); presence simply shows the user offline. No analytics write ever blocks the UI (write-only, fire-and-forget, `guardWrite` stance). |
| **Golden rule** | Every remote touch goes through `guardWrite`/guarded `attach` (`firestore_cached_repo.dart:204,344`): a failure is caught + logged, **never thrown into the UI**; the optimistic/seed cache is what the user sees. This is already enforced by the base class — new repos inherit it. |

---

## 8. Migration local → server with ZERO regression

The catalog is the hard one (it's pure-const, no `_firebase` impl yet). Phased so each step is independently shippable and OFF-by-default:

**Phase 0 — seam parity (no behaviour change).** Add `SearchRepository` + a `catalogShard`/token-aware `CatalogRepository._firebase` skeleton + `StudioConfigRepository`, all wired behind providers, **all defaulting to the local/bundled impl**. `flutter analyze` clean, suite green, build byte-identical. (The `catalog_repository.dart:8` promise is now real but dormant.)

**Phase 1 — seed the server (dev/emulator only, `SEED_FRESH_BACKEND`).** A one-shot importer (reuse the `pushCacheToRemote` mechanism, `firestore_cached_repo.dart:327`, gated on `kSeedFreshBackend` so prod never auto-seeds) writes the ~1,853 const products (`kCatalogProducts`, the unified Lipskey+Polyroll+Huliot list) into `catalogProducts/{sku}`, and the bundled tree into `studioConfigSnapshots/v1` + `studioConfig/published`. doc-id=SKU makes this idempotent (re-runnable). Existing ingestion tooling (`scripts/harvest_lipski_site.py`, `scripts/match_lipskey_pdf.py`, `knowledge/LIPSKEY-INGESTION-PLAN.md`, `polyroll-ingest-spec.md`, snapshot tests `test/_polyroll_snapshot.g.dart`/`_huliot_snapshot.g.dart`) feeds the authored 10Ks set over time. The Dart const files remain the *bundled starter* (Phase 4); the server collection is the at-scale superset.

**Phase 2 — server search index.** Deploy `onCatalogProductWrite` to backfill `nameTokens`; verify token search returns the SAME top-results as `fuzzySearchProducts` on a fixture set (a golden test). Flag `CATALOG_SERVER_SEARCH` still OFF.

**Phase 3 — flip in a dev build.** `--dart-define=USE_FIREBASE_BACKEND=true --dart-define=CATALOG_BASE_URL=… --dart-define=CATALOG_SERVER_SEARCH=true --dart-define=STUDIO_LIVE=true`. The repo pair swaps the same way `ordersRepositoryProvider` does. Compare against the local build: same catalog, same search top-N, same card flow. The **flags-OFF build remains the shipped default** until the owner approves cutover (the `app/`→Flutter cutover discipline in CLAUDE.md).

**Phase 4 — keep a bundled "starter" subset.** Even after the 10Ks catalog is server-side, ship a small const subset so the offline/first-run demo is non-empty (the born-seeded invariant). The local fuzzy layer searches it offline.

**Reconciliation:** every server write path uses the cache base's optimistic-write + LWW-snapshot reconcile (`firestore_cached_repo.dart:258,241`) — no new conflict model. doc-id = SKU/uid/natural-key means no merge ambiguity (idempotent upserts).

**New files (all additive, dormant until flagged):**
- `lib/data/repositories/catalog_firebase.dart` (the long-foretold impl, extends `FirestoreCachedRepo` for the *authored* subset / or a paged query source for browse)
- `lib/data/repositories/search_repository.dart` + `search_local.dart` + `search_firebase.dart`
- `lib/data/repositories/studio_config_repository.dart` + `studio_config_local.dart` + `studio_config_firebase.dart`
- `lib/data/repositories/analytics_repository.dart` + `presence_repository.dart` (write-mostly)
- `lib/data/paged_query.dart` (cursor helper over `RemoteCollectionSource`)
- `lib/data/repositories/backend.dart` — add `kCatalogServerSearch`, `kStudioLive`, `kCatalogBaseUrl` flags (same `bool.fromEnvironment` shape, default OFF/empty)
- `functions/src/studio.ts` (`publishConfig` + `revertIllegalConfigWrite`), `functions/src/catalog.ts` (`onCatalogProductWrite` token indexer), `functions/src/analytics.ts` (daily rollup scheduled fn) — re-exported from `functions/src/index.ts:144` like every other module.
- `firestore.rules` — the §5 blocks. `firestore.indexes.json` — the §1.5 indexes.

**Existing seams touched (file:line):**
- `lib/data/repositories/backend.dart:189` — append new flags.
- `functions/src/index.ts:151` — add `export { publishConfig, revertIllegalConfigWrite } from "./studio"; …`.
- Provider switches in `catalog_local.dart:103`, plus new providers — same drop-in shape as `orders_firebase.dart:44`.
- `lib/data/product_images.dart` — `CATALOG_BASE_URL` is the *data* twin of `IMAGE_BASE_URL` (copy the pattern, don't modify the image one).

---

## 9. Risks & mitigations

1. **Config-push thundering herd** (5,000 clients re-pull on every publish). → pointer + cached immutable snapshot (§3.3); re-pull only on `version` change; cap publish rate via callable `maxInstances`.
2. **Firestore 1 MiB doc ceiling vs 10K-node tree.** → shard the snapshot at 500 KB (§1.1B); parent doc lists shard refs.
3. **No native full-text in Firestore.** → token-array + composite index + the existing fuzzy ranker over the candidate page (§2.3); seam keeps the door open for a dedicated index without a stack change.
4. **Regression risk flipping the catalog server-side.** → strict phasing (§8), golden test that server search == local fuzzy top-N, flags default OFF, bundled starter subset for offline.
5. **Analytics write hotspot / cost blowout.** → auto-id scatter, distributed counters, daily rollups, TTL, budget alert + `STUDIO_LIVE` kill-switch (§6).
6. **Draft leakage to non-owners.** → separate doc-id (`draft-<uid>`) with `isManager()` rules + `publishConfig` as the only published-write path + `revertIllegalConfigWrite` (§3.2, §5).
7. **Presence ghosts** (crashed clients stuck online). → heartbeat TTL + scheduled sweep (§3.4).
8. **Stale-config torn read** during publish. → snapshots are immutable; a reader on `vN` is never mutated; the pointer flip is atomic (§3.1).
9. **Custom-claim propagation lag** (≤1 h to refresh) could let a freshly-promoted owner be denied publish. → force `getIdTokenResult(true)` after role grant (already the documented pattern, `index.ts:18`); callable re-reads the live token anyway.
10. **Cache-base assumes whole-collection listen** (`firestore.rules:43`). → catalog/analytics use **paged queries**, not the cache-base listener, so they don't trip the "non-manager full-collection read denied" rule; only the tiny owner-readable / world-readable docs use `snapshots()`.

---

## 10. Gate / test strategy (100-gate protocol + governance #84)

Every commit on this pillar must pass, in order:
1. `flutter analyze` — **0 errors** (gate 31).
2. `flutter test` — **0 regressions**, including `test/knowledge_protocol_test.dart` and `test/protocol_security_test.dart` (the governance gates).
3. `flutter build web --release` — succeeds (≈2.0 MB main.dart.js budget per CLAUDE.md).
4. **Zero-regression proof:** a `backend_flag_test`-style test (`test/backend_flag_test.dart` exists) asserting that with all new flags OFF, the providers resolve to the local/bundled impls and outputs are byte-identical (mirror `app_check_providers_test.dart`'s pure-helper assertion of an ON branch *without* Firebase).
5. **Server-impl tests via fakes:** drive `_firebase` repos with a hand-rolled `RemoteCollectionSource` fake (the `firestore_cached_repo.dart:61` testability pattern) — the standard define-less suite exercises the ON branch with **no network, no Firebase** (the `kUidScopedQueries`/`uidScoped` precedent).
6. **Rules tests:** extend `rules_test/` (Firebase emulator) for the §5 blocks — owner-writes-config allowed, non-owner denied; analytics append-self allowed, read denied for non-owner; draft read denied for non-owner (the S5.8-style "blocked" assertions).
7. **Functions tests:** `publishConfig` happy-path + denial audit, `revertIllegalConfigWrite` reverts a forged publish, token-indexer golden (server tokens → fuzzy top-N == local fuzzy top-N).
8. **Search parity golden:** a fixture query set whose Layer-A and Layer-B results match (top-N identical ordering).
9. `scripts/audit_gates.sh` / `scripts/protocol_check.sh` clean; update `WIRING.md`, `knowledge/firestore-schema.md` (new collections), `firestore.indexes.json`, `GATE_REGISTRY.md` (any new gate), and this doc's "done" markers.
10. **No new runtime deps** without an explicit flag + doc (gate 50/58 — no hard-coded URLs except the documented dart-define defaults like `IMAGE_BASE_URL`/`CATALOG_BASE_URL`).
11. **Inspector / governance #84:** owner/manager claim gates every config/catalog/analytics-read write path — assert it in rules tests + a callable auth test; spawn the Explore/Inspector subagent before writing the markdown report, per CLAUDE.md.

**Coordination boundaries (this pillar owns persistence/sync/search/security/scale ONLY):**
- **Pillar 1** owns the config-engine UX and the node *schema semantics*; we own how that tree persists (sharded snapshots), publishes (pointer flip) and caches.
- **Pillar 2** owns the trade/domain *model*; we own `catalogProducts/{sku}` storage, indexes, pagination, search.
- **Pillar 3** owns the *event taxonomy* (which events, what props); we own `analyticsEvents`/`presence`/rollups storage, write-only rules, cost shape.
- **Pillar 4 (AI)** owns prompts/grounding; we own that it reads through the same repos and that `askClaude` (`claude.ts`) stays the only API egress — already built.

---

### One-paragraph north star
Publish is a **pointer flip** over **immutable sharded snapshots**, fanned out by a **single tiny listener** per client and reconciled by the **cache base's existing LWW**; the 10Ks-product catalog becomes a **per-SKU collection** browsed by **cursor pagination** and searched by **token-array + the existing fuzzy ranker**, with a **bundled starter subset** keeping the offline demo byte-identical; analytics are **append-only, owner-read-only, auto-id-scattered with daily rollups**; and **every** new capability ships behind a **default-OFF flag** on the proven `backend.dart` seam, so the flags-OFF build never changes a byte until the owner says go.

---

## 🔧 תיקוני Red-Team R1 (מחייב — מחליף סעיפים סותרים)

> מקור: `knowledge/studio-plan/RED-TEAM-R1.md` (תמות C/D/E + הכרעות-התיקון). כל פריט כאן **גובר** על הסעיף-המקורי שצוין. הניסוח בגוף-המסמך מעלה הוא ה-vision; **הסעיף הזה הוא החוזה-המחייב לבנייה.** עיקרון-על: כל טענת-עלות, כל מעקה ושער-בטיחות מקורקעים בקוד-החי (`functions/`, `firestore.rules`) — לא ב-prose-אופטימי.

### R1-1 · עלות כנה — טבלת-$/חודש מפורשת עם egress + rollup-reads + counter-writes (מחליף §6 הטבלה + הסעיף "Analytics … ≈ $0.45/day")
**§-מוחלף:** §6 (טבלת-העלות + שורת-האנליטיקה "$0.45/day") · **שלב מושפע:** Phase 3 (flip) + שער-עלות לפני cutover.

ה-§6 המקורי מודד **רק** את ה-write-של-האירועים (250K writes ≈ $0.45/יום) ו**משמיט** שלושה מקורות-עלות אמיתיים שהנחיל חשף: **egress** של פרסום-הסנאפשוט, **rollup-reads** של ה-dashboard, ו**counter-writes** של ה-distributed-counters. הטענה "$0.45/day" היא העלות-התחתונה של רכיב-אחד בלבד — לא העלות-הכוללת. להחליף בטבלת low/high מלאה (תמחור Firestore: reads $0.06/100K · writes $0.18/100K · egress $0.18/GiB · free-tier 50K read / 20K write / יום):

| רכיב | low (חודשי) | high (חודשי) | בסיס-החישוב |
|---|---|---|---|
| **egress — פרסום** | ~$3 (10 פרסומים) | ~$99 (150 פרסומים) | עץ 3MB gzip × 5,000 משתמשים = ~15GiB/פרסום × $0.18/GiB ≈ **$0.66/פרסום** (תואם D13). low=10/חודש · high=5/יום×30 |
| **egress — cold-start re-pull** | ~$5 | ~$30 | רק על version-bump; משתמש מושך סנאפשוט פעם-אחת-לגרסה אז cache. תלוי-תדירות-פרסום |
| **analyticsEvents writes** | ~$3 | ~$14 | 5,000×50 אירועים/יום = 250K writes/יום × $0.18/100K ≈ $0.45/יום → ~$13.5/חודש |
| **counter-writes (distributed)** | ~$2 | ~$11 | מטריקות-חמות; כל view = increment ל-shard אקראי (`analyticsCounters/{m}/shards/{0..9}`). high≈ 200K inc/יום |
| **rollup-reads (scheduled fn)** | ~$1 | ~$8 | ה-rollup קורא raw-events פעם-ביום לגלגול; ה-owner קורא `analyticsDaily/{day}` = doc-אחד/יום (זה הזול) |
| **presenceSummary reads** | ~$1 | ~$5 | ה-owner קורא doc-summary מגולגל (ראה R1-3), לא listener-לכל-מחובר |
| **catalog paged reads** | ~$2 | ~$7 | 40/scroll × sessions; cached |
| **סך-הכל מוערך** | **~$17/חודש** | **~$144/חודש** | הקצה-העליון **$144**, לא $0.45 — מספר ה-$0.45 הוא רכיב-יחיד מטעה |

- **Cloud-Billing-cap קשיח (לא רק alert):** מעבר ל-budget-alert הרך, להגדיר **תקרה-קשיחה** — Cloud Billing budget מחובר ל-Pub/Sub שמפעיל פונקציה שמכבה את חיוב-הפרויקט (`billingAccountName=''`) או מורידה את `STUDIO_LIVE` מעל-סף. ה-alert לבדו לא עוצר הוצאה; ה-cap עוצר. (`STUDIO_LIVE` default-OFF נשאר ה-kill-switch הראשון.)

### R1-2 · מעקות-פרסום — rate-limit/budget אמיתי על `publishConfig`, לא רק `maxInstances` (מחליף §6 guardrail #4 + §3.2 + §9 risk #1)
**§-מוחלף:** §6 guardrail #4 ("Callable concurrency caps … on `publishConfig`") · §3.2 · §9 risk #1 · **שלב מושפע:** `functions/src/studio.ts` (`publishConfig`).

הטענה ש-`maxInstances:10` חוסם תדירות-פרסום **שגויה** — `maxInstances` חוסם **concurrency** (כמה ריצות-במקביל), לא **frequency** (כמה פרסומים-ביום). מנהל לבדו יכול ללחוץ "פרסם" 50 פעמים ברצף סדרתי וכל אחת תעבור (כל egress ≈ $0.66). הנחיל מדד 10–50 פרסומים/יום → $6–33/יום egress ללא-מעקה. נדרש מעקה-תדירות אמיתי:
- **rate-limit פר-owner** ב-`publishConfig`, **מבוסס על אותו `enforceRateLimit`-pattern של `claude.ts:75`** (טרנזקציית-Firestore על `_publishRate/{uid}`, fixed-window, fail-open) — למשל ≤N פרסומים/שעה + ≤M/יום. חורג → `resource-exhausted` ידידותי.
- **coalescing + "stage-many-publish-once" UX:** המנהל **צובר** עריכות ל-draft (כמה-שהוא רוצה, זה זול — כתיבות-shard owner-only) ו**מפרסם פעם-אחת** בסוף. ה-UI מציג מונה-שינויים-ב-draft + "פרסם הכל" יחיד; **אין** auto-publish-on-edit. זה הופך 50-עריכות → פרסום-אחד → egress-אחד.
- **publish-budget רך:** סופר פרסומים-היום ומזהיר את ה-owner ("פרסמת 12 פעמים היום, כל פרסום מגיע ל-5,000 מכשירים") לפני שמרשה עוד — מעקה-מודעות מעל מעקה-קשיח.
- `maxInstances` נשאר (תקרת-burst נכונה), אבל **מתועד מפורש** שהוא חוסם concurrency-לא-frequency; ה-rate-limit הוא מה שחוסם spend-מצטבר.

### R1-3 · presence בלי read-storm — owner קורא summary מגולגל-שרת, לא listener-לכל-מחובר (מחליף §1.3 presence-read + §3.4 + §5 presence-rule + §6 presence-row)
**§-מוחלף:** §1.3 ("Owner's 'מי מחובר' view = `where('online','==',true)`") · §3.4 · §5 presence-rule · §6 presence-row · §9 risk #7 · **שלב מושפע:** `functions/src/analytics.ts` (rollup) + `firestore.rules`.

ה-§1.3/§3.4 המקוריים נותנים ל-owner **listener על `where('online','==',true)`** — בקצה-עליון אלפי-מחוברים = read-storm ($11/משמרת ב-D13: כל heartbeat שמשנה doc גורר re-read לכל-המאזינים). להחליף ב-rollup-שרת:
- **`presenceSummary/current` — doc-יחיד מגולגל-שרת.** scheduled-fn (כל ~30–60 שניות) סופר `where('online','==',true)` **בשרת** (Admin SDK) וכותב `{ count:int, byRole:{contractor:N,courier:M,…}, sample:[…≤50 uids], updatedAt }`. ה-owner קורא **doc-אחד** (read אחד ל-poll), **לא** מאזין לכל-doc-presence. (תואם D13: "presence דרך `presenceSummary` מגולגל-שרת, לא listener על כל-המחוברים".)
- **cap/paginate על raw-presence:** אם ה-owner חייב את הרשימה-המלאה (drill-down), זו **paged query** (`limit(50)` + cursor), **לא** listener-מתמשך. ה-`sample` ב-summary מספיק לרוב-המקרים; הרשימה-המלאה היא pull-מפורש.
- **rule:** `presence/{uid}` נשאר self-write; **קריאת-raw לכל-ה-presence מוסרת מ-owner-listener** — ה-owner קורא `presenceSummary/current` (rollup, Admin-SDK-write, `allow read: if isManager(); allow write: if false`). raw-presence-read נשאר owner אבל **כ-paged-query מוגבל**, לא stream. (תואם R1 C-11: presence-read מוגבל, default-OFF + TTL.)
- ה-TTL-sweep (§3.4) נשאר; ה-summary פשוט קורא את ה-state-הנקי-אחרי-sweep.

### R1-4 · concurrency — `publishConfig` עם compare-and-set (expected-version) + זיהוי "מנהל אחר עורך" (מחליף §3.2 + §1.1 draft-isolation + §9 — חדש)
**§-מוחלף/מורחב:** §3.2 (`publishConfig` transaction) · §1.1 draft-isolation · §9 (risk חדש) · **שלב מושפע:** `functions/src/studio.ts` + draft-UX. **(תמה E14.)**

ה-§3.2 המקורי מאמת auth+טרנזקציה אבל **לא** מגן מפני שני-מנהלים שעורכים-במקביל — publish של מנהל-א **דורס** את מנהל-ב לכל-המשתמשים (E14). להוסיף compare-and-set:
- **expected-version ב-`publishConfig`:** הקריאה נושאת `expectedBaseVersion` (הגרסה שעליה ה-draft נבנה). בטרנזקציה: אם `studioConfig/published.version != expectedBaseVersion` → **לדחות** עם `failed-precondition` ("פורסמה גרסה חדשה בזמן שערכת — רענן ומזג"), **לא** לדרוס. זה compare-and-set אטומי על מצביע-הפרסום.
- **`studioConfig/draft` נושא `draftOwnerUid` + `lockedAt`:** כשמנהל פותח עריכה, ה-UI קורא את ה-draft-pointer; אם `draftOwnerUid != me && now-lockedAt < TTL` → להציג **"מנהל אחר (X) עורך כעת"** (advisory-lock רך, לא נעילה-קשיחה — TTL פג-תוקף מונע draft-תקוע). מנהל-ב יכול עדיין-לכפות אבל מתריעים.
- ה-draft-isolation של §1.1 (`draft-<uid>`) משתנה: או **draft משותף-יחיד** עם owner-lock (פשוט יותר ל-coalescing R1-2), או draft-per-uid עם merge-מפורש בפרסום. R1 בוחר **draft-משותף + expected-version-CAS** כי זה מתיישר עם coalescing ("stage-many-publish-once").
- audit מתעד `before:{version:N-1, expectedBase}` + `after:{version:N}` כדי שדריסה-שנמנעה תהיה traceable (`audit.ts:45`).

### R1-5 · dual-control — פרסום-לכולם דורש `isOwnerEmail` או dual-control + revert-SLA + re-check live allow-flag (מחליף §3.2 "manager/admin-only" + §5 RBAC-notes + §10 gate #11)
**§-מוחלף:** §3.2 ("auth-gated, manager/admin-only") · §5 RBAC-notes (governance #84) · §10 gate #11 · §9 risk #9 · **שלב מושפע:** `functions/src/studio.ts` + `firestore.rules`. **(תמה C12.)**

ה-§3.2 המקורי שם publish מאחורי `isManager()` בלבד — אבל manager-claim = **publish-לכולם בלי dual-control** ב-supply-chain-in-app (C12); claim-יחיד שנפרץ/שגוי משדר-לכולם. נדרש שער-כפול:
- **`isOwnerEmail` או dual-control:** פרסום-לכולם דורש **או** `request.auth.token.email == OWNER_EMAIL` (gate חדש — `isOwnerEmail`, **לא קיים היום בקוד**; להוסיף ל-`functions/src/common.ts` + helper מקביל ב-`firestore.rules`) **או** dual-control: שני-מנהלים-נפרדים מאשרים (manager-א מגיש `publishRequest`, manager-ב-שונה מאשר → אז `publishConfig` מבצע). מנהל-יחיד לבדו **לא** משדר-לכולם.
- **re-check live allow-flag (לא רק claim):** `publishConfig` **קורא-מחדש את דגל-ההרשאה-החי בשרת** ברגע-הביצוע — בודק doc/claim-חי (`studioConfig/publishAllow` או claim-טרי דרך `getIdTokenResult`), **לא** מסתמך רק על ה-claim-ב-token (שמתעדכן עד שעה, §9 risk #9). זה מאפשר **revocation מיידי**: owner שמסיר הרשאה — הפרסום-הבא נחסם תוך-שניות, לא תוך-שעה.
- **revert-SLA:** rollback = re-point ל-`v(N-1)` (כתיבה-אחת, §3.3). ה-SLA מתועד: פרסום-שגוי ניתן-לביטול תוך **< דקה** ע"י owner (כפתור "החזר לגרסה קודמת" שקורא `publishConfig` עם הגרסה-הקודמת). הסנאפשוטים immutable → revert תמיד-בטוח.
- `revertIllegalConfigWrite` (§3.2) נשאר ה-defense-in-depth מול כתיבה-ישירה-עוקפת-callable.

### R1-6 · price scoped — `catalogProducts.price` בשדה role-scoped / sub-doc; קטלוג-ציבורי ללא-מחיר אלא-אם claim מתיר (מחליף §1.2 schema price-field + §5 catalog-read rule)
**§-מוחלף:** §1.2 (`catalogProducts/{sku}` שדה `price:int?` inline) · §5 (`match /catalogProducts/{sku} { allow read: if isSignedIn() }`) · **שלב מושפע:** schema + `firestore.rules` + `_firebase` mapper. **(תמה C12.)**

ה-§1.2/§5 המקוריים שמים `price` **inline** במסמך-המוצר עם `allow read: if isSignedIn()` — כלומר **כל חנות-מתחרה רשומה רואה את כל-המחירים** (C12: "catalogProducts חושף price למתחרים"). זו דליפה מסחרית. להפריד מחיר:
- **`price` יוצא מ-doc-המוצר-הציבורי** אל **sub-doc role-scoped:** `catalogProducts/{sku}/pricing/{audience}` (או שדה תחת `catalogPricing/{sku}` נפרד). ה-doc-המוצר-הציבורי (nameHe/dims/imageFile/…) נשאר `allow read: if isSignedIn()`; ה-מחיר נקרא **רק** אם `isManager()` **או** claim-תפקיד-קונה מתיר (למשל `hasRole('contractor')` רואה מחיר-קבלן, חנות-מתחרה לא רואה כלום). 
- **rule:** `match /catalogProducts/{sku}/pricing/{aud} { allow read: if isManager() || hasRole(aud); allow write: if isManager(); }` — קטלוג-ציבורי ללא-מחיר by default; חשיפת-מחיר מותנית-claim.
- ה-`_firebase` mapper (§1.2, "adds new fields") **לא** ממפה price ל-doc-הראשי; ה-search-token-index (R1-7) **לא** כולל price. ה-UI מושך מחיר ב-get-נפרד רק כשה-claim מתיר.

### R1-7 · search parity כן — token-index רק מ-`nameHe` (כמו ה-fuzzy היום) + token-frequency-map; למחוק "ranking identical" (מחליף §2.3 שלב-1/שלב-2 + §10 gate #8 + §9 risk #3)
**§-מוחלף:** §2.3 (token-index מ-`nameHe+nameEn+brand+sku` + "ranking identical") · §2.1 seam-note · §10 gate #8 · §9 risk #3 · **שלב מושפע:** `functions/src/catalog.ts` (`onCatalogProductWrite`). **(תמה D.)**

ה-§2.3 המקורי בונה `nameTokens` מ-`nameHe+nameEn+brand+sku` ואז טוען "ranking identical" ל-fuzzy-החי — **אבל ה-fuzzy-החי (`fuzzy_search.dart:16`) מתאים רק מול `nameHe`** (`contains` ב-`nameHe` בלבד). אם ה-token-index כולל גם en/brand/sku, ה-candidate-set **שונה** מה-fuzzy → התוצאות **לא** זהות. הטענה "ranking identical" over-claim. שתי דרכים-לגיטימיות (R1 בוחר את הראשונה):
- **(נבחר) tokenize `nameHe`-בלבד** — בדיוק כמו ה-fuzzy היום. אז Layer-B מצמצם 10K→עשרות מאותו-מרחב-התאמה, ו-`fuzzySearchProducts` מדרג client-side → **answer-equivalent מול fixtures** (לא "byte/ranking identical" — להחליף את הניסוח ל-"answer-equivalent מול `catalog_regression` fixtures", תואם תמה-B). en/brand/sku מצטרפים **רק** אם משדרגים-במקביל גם את ה-ranker (חלופה-ב, out-of-v1).
- **token-frequency map ל-"rarest-token":** §2.3 שלב-2 בוחר "rarest token" ל-multi-word query אבל **לא מגדיר איך** יודעים מי-הנדיר. להוסיף `catalogTokenFreq/{token} { count:int }` (מתוחזק ב-`onCatalogProductWrite` — increment/decrement פר-token). ה-client/שרת בוחר את ה-token עם ה-`count` הנמוך-ביותר ל-`arrayContains` → candidate-set מינימלי → reads מינימליים. בלי המפה, "rarest" הוא ניחוש.
- §10 gate #8 ("Layer-A == Layer-B top-N identical") מתעדכן: **"top-N answer-equivalent מול fixture-set"** (לא "identical ordering"), כי tokenize-nameHe-בלבד מבטיח אותו-מרחב אבל ה-golden נמדד מול fixtures לא מול הבטחת-byte.

### R1-8 · גיבוי — export/import JSON מלא של config+trades + restore-from-file (שלב חדש, מעבר ל-ring-30)
**§-מוחלף/מוסף:** §8 (Migration — שלב חדש) · §1.1/§1.2 (snapshots הם ring-30 בלבד) · **שלב מושפע:** `functions/src/studio.ts` (export/import callables) + Studio-UX. **(תמה E15.)**

כל-העסק היום ב-Firestore עם **ring-30 בלבד** (snapshots immutable אבל אין-ייצוא — אובדן-פרויקט/מחיקה-בטעות = אובדן-קונפיג). E15 דורש גיבוי-אמיתי:
- **export מלא:** callable `exportStudioConfig` (owner-only, `isOwnerEmail`/manager) שמרכיב **JSON-יחיד** של כל ה-config-tree-הנוכחי (snapshot `vN` deserialized) + `catalogTrades` + `catalogCategories` + (אופ') `catalogProducts` → מחזיר/מעלה ל-R2 (אותו `getUploadUrl`-pattern, `r2.ts:127`) או download-ישיר ב-client. כולל `schema:int` + `version` + `checksum` כדי שייבוא יוכל-לאמת.
- **import/restore-from-file:** callable `importStudioConfig` שמקבל JSON-מיוצא, **מאמת checksum+schema**, ומבצע **publish-as-new-version** (לא דורס-snapshot — יוצר `v(N+1)` מהקובץ, אז flip-pointer דרך אותו מסלול-CAS של R1-4). restore = ייבוא-קובץ → פרסום-גרסה-חדשה → reversible.
- זה **מעבר ל-ring-30:** הקובץ חי **מחוץ** ל-Firestore (R2/דיסק-של-owner), אז מחיקת-פרויקט-שלם לא מאבדת אותו.

### R1-9 · archive fan-out — מחיקת-מוצר/תחום מנקה search-index + מסמנת tombstone; orders/carts מטופלים (מחליף §1.2 "active:bool" + §8 reconciliation + §9 — חדש)
**§-מוחלף/מורחב:** §1.2 (`active:bool` לבדו) · §8 reconciliation · §9 (risk חדש) · **שלב מושפע:** `functions/src/catalog.ts` (`onCatalogProductWrite` archive-branch). **(תמה E16.)**

ה-§1.2 המקורי שם `active:bool` אבל **לא** מגדיר מה-קורה ל-`nameTokens`/`catalogTokenFreq`/הזמנות-קיימות כשמוצר-נמחק → יתומים (E16: "מחיקת-תחום/מוצר משאירה יתומים — overrides · rules · search-index · orders/carts"). מודל tombstone + fan-out:
- **tombstone, לא delete-קשיח:** מחיקת-מוצר = `active:false` + `tombstone:true` + `tombstonedAt`. ה-doc **נשאר** (הזמנות-היסטוריות שמצביעות עליו עדיין-resolvable דרך `productForSku`), אבל מוסתר מ-browse/search.
- **fan-out ב-`onCatalogProductWrite` (archive-branch):** כשמוצר עובר ל-tombstone — (א) **מנקה search-index:** `nameTokens` מנוקה + `catalogTokenFreq` מ-decremented פר-token (R1-7), כך שלא יוחזר בחיפוש; (ב) `catalogTrades.productCount` מ-decremented; (ג) מחיקת-**תחום** שלם → tombstone-cascade לכל מוצריו (paged, batched — אותו `purgeMultiPartyReferences`-pattern של `deleteAccount.ts:40`, batches-של-400, capped-rounds).
- **orders/carts מטופלים:** הזמנות-קיימות שמצביעות על ה-SKU **נשארות** (כמו ה-deleteAccount-SCOPE: לא דורסים נתוני-עבר) — ה-snapshot-של-המחיר/שם בהזמנה כבר-מקובע; carts-פעילים שמכילים מוצר-tombstoned מסומנים ("פריט אינו זמין") ב-resolve, לא-נמחקים-בשקט. migrate-map ל-id-שנמחק (E16) = `catalogProducts/{sku}.replacedBy:sku?` כדי שניתן-להפנות לחלופה.
- **erasure-presence-gap (C12, השלמה ל-`deleteAccount.ts`):** באותה-רוח, ה-erasure-הקיים (`deleteAccount.ts:35`) מנקה orders/chat/customers אבל **משמיט `presence/{uid}` ו-`displayName`** (C12). להוסיף ל-`purgeMultiPartyReferences`: מחיקת `presence/{uid}` + סקראב `users/{uid}.displayName` (ה-doc-עצמו כבר נמחק ב-step-1, אבל אם נשמר mirror — לנקות) + סקראב `displayName` מ-`roleRequests` (`firestore.rules:477`). + טסט-שלמות-erasure שמאמת ש-presence/displayName אכן-נוקו.
