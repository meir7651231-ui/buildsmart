// ─────────────────────────────────────────────────────────────────────────────
// Pillar 5 · Step 66 — COST-GUARDRAILS for the Studio scale surface (analytics +
// presence). The publish path's two ceilings — `maxInstances: 10` and the per-uid
// `_publishRate/{uid}` limiter — already live on `publishConfig` (studio.ts, built
// in Step 56; the detail's "maxInstances on publishConfig+rollups / rate-limit on
// _publishRate" is satisfied there). THIS module adds the remaining four guardrails
// the spec (detail/051-068.md "Step 66") names, all server-owned Admin-SDK work:
//
//   1. DISTRIBUTED COUNTERS — `incrementMetric(metric)` scatters a hot metric's
//      writes across `analyticsCounters/{metric}/shards/{0..N-1}` so no single doc
//      exceeds the ~1-write/sec soft limit (auto-id-scatter, §66.4).
//   2. DAILY ROLLUP — `rollupAnalyticsDaily` (scheduled) sums every metric's shards
//      and writes ONE `analyticsDaily/{day}` doc, so the owner reads ~1 doc/day
//      instead of counting 250K events (§66.1/§66.7).
//   3. PRESENCE ROLLUP — `rollupPresenceSummary` (scheduled) counts online clients
//      from `presence/*` SERVER-SIDE and writes the single `presenceSummary/current`
//      doc {count, byRole, sample, updatedAt}. The owner dashboard reads THAT ONE
//      doc — never a live listener over thousands of `presence/*` docs (R1-3: O(users)
//      not O(users×owners), + no "who's online" collection leak). Ghosts (a heartbeat
//      older than 2 min — a crashed/backgrounded client that never wrote online:false)
//      are NOT counted (§66 addition-a meta-clean).
//   4. HARD BILLING-CAP + KILL-SWITCH — documented below (infra, not code) + the
//      `STUDIO_LIVE` client flag that keeps every listener dark until owner GO.
//
// DORMANT / DEPLOY-GATED: these are new server functions in a SEPARATE deploy
// target — the shipped Flutter app build is byte-identical (it imports nothing
// here). Per the Step-68 deploy-ordering (R2-10) the functions bundle is not
// deployed until the Studio flags flip, and the scheduled rollups only WRITE the
// server-owned `analyticsDaily`/`presenceSummary`/`analyticsCounters` collections
// that the client only READS once `STUDIO_LIVE` is on. GOVERNANCE #84: the rollups
// run with the Admin SDK (rules-exempt); the matching rules (Step 65) are
// `allow write: if false` for all three collections + manager-only read — so the
// client can never forge a counter/summary, only read the rolled result.
//
// COST TABLE (R1-1 — egress is NOT free and IS included; ~5,000 online users):
//   line item                                    low / month     high / month
//   ── publish reads (pointer+snapshot, O(users)) ~$1            ~$8
//   ── snapshot + pointer EGRESS to clients        ~$15          ~$60   ← R1-1
//   ── presenceSummary egress (1 doc × owners)     ~$0           ~$2
//   ── analytics writes (250K/day, sharded)        ~$4           ~$14
//   ── daily + presence rollup reads               ~$3           ~$20
//   ── Cloud Functions invocations (rollups)       ~$1           ~$5
//   ── storage (events 90-day TTL + snapshots)     ~$1           ~$35
//                                                  ─────────     ─────────
//   TOTAL (order-of-magnitude, bounded not zero)   ~$25/mo       ~$144/mo  ← R1-1
//   The pointer+immutable-snapshot design turns publish from O(users×nodes) (~50M
//   reads/publish → ruinous) into O(users) (~10K reads → bounded). The free tier
//   (50K reads / 20K writes/day) is crossed at a few thousand users ⇒ Blaze is
//   mandatory; the guardrails make the bill BOUNDED, not zero (egress is real).
//
// HARD BILLING-CAP (§66 goal + improvement-a — INFRA, intentionally not code):
//   A true hard cap is a project-level Cloud Billing BUDGET with a Pub/Sub-triggered
//   disable-billing action + a budget-alert at (e.g.) 50/90/100% — configured in the
//   GCP console / `gcloud billing budgets create`, NOT inside a function (a function
//   cannot reliably cap the very billing that funds it, and wiring `@google-cloud/
//   billing` here would add a dependency + a self-referential kill path). The CODE
//   half of the cap is the `STUDIO_LIVE` kill-switch (default OFF, backend.dart): even
//   with everything deployed, every client listener stays dark until owner flips it,
//   so a runaway is stopped at the source. See knowledge/GATE_REGISTRY.md for the
//   budget-alert gate.
//
// STORAGE MODEL (assumptions — the Firestore shapes this module reads/writes):
//   analyticsCounters/{metric}/shards/{n}  — {count:number}; cumulative running total,
//                                            incremented on a RANDOM shard. Admin-SDK
//                                            write; manager-read; `if false` client-
//                                            write (Step-65 rules, already sealed).
//   analyticsDaily/{day}                   — {<metric>:number, day, rolledAt}; ONE doc
//                                            per UTC day, the cumulative snapshot the
//                                            daily rollup writes (per-day deltas are
//                                            derived read-side: todaySnap − yesterday).
//   presence/{uid}                         — the heartbeat Step 67 writes. CONTRACT
//                                            this rollup consumes: {role:string,
//                                            lastSeen:number /*epoch ms*/}. `lastSeen`
//                                            drives ghost-exclusion (a stale doc is a
//                                            crashed client, not counted) — freshness,
//                                            NOT a possibly-stuck `online:true` flag.
//   presenceSummary/current                — {count, byRole, sample, updatedAt}; the
//                                            single server-rolled doc the owner reads
//                                            (R1-3). `updatedAt` lets the Step-67 UI
//                                            show "עודכן לפני Xs / לא-זמין" (R2-12).
// ─────────────────────────────────────────────────────────────────────────────

import { FieldValue } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { db, REGION } from "./common";

// ── constants (exported so the offline harness asserts the guardrail values) ──

/** Distributed-counter shards per hot metric. 10 shards ⇒ a hot metric's writes
 * fan out ~10× under the per-doc ~1-write/sec soft limit, so it never hotspots a
 * single doc (§66 addition-b: raise this if contention ever appears). */
export const kNumShards = 10;

/** A presence heartbeat older than this is a GHOST — a client that crashed or
 * was backgrounded without writing `online:false` — and is NOT counted (§66
 * addition-a "heartbeat > 2min → not counted"). Freshness beats a stuck flag. */
export const kPresenceStaleMs = 120_000; // 2 minutes

/** `maxInstances` on the scheduled rollups — a hard CONCURRENCY ceiling on the
 * fan-out cost (the claude.ts:115 pattern; concurrency, NOT frequency — the
 * schedule bounds frequency). Matches `publishConfig`'s `maxInstances: 10`. */
export const kRollupMaxInstances = 10;

/** The single doc the presence rollup writes — the owner dashboard reads THIS ONE
 * doc, never the `presence/*` collection (R1-3). */
export const kPresenceSummaryDocId = "current";

/** Daily rollup schedule: 00:05 UTC, once a day (crontab). After the day boundary
 * so `dayKey(new Date())` names the day that just ended's cumulative snapshot. */
export const kDailyRollupSchedule = "5 0 * * *";

/** Presence rollup schedule: every minute (crontab) — keeps `presenceSummary`
 * fresher than the Step-67 staleness threshold (~90s) so the owner never sees a
 * stale count mislabeled as live (R2-12). One run serves ALL owners (O(users)). */
export const kPresenceRollupSchedule = "* * * * *";

// ── PURE cores (no I/O — offline-testable, like studio.ts `decidePublish`) ────

/**
 * Map a uniform random r∈[0,1) to a shard index in [0, numShards-1]
 * (`analyticsCounters/{metric}/shards/{n}`). Defensive clamp: r===1 (or any r≥1,
 * or a negative r) never yields an out-of-range shard. Deterministic given r, so
 * the "increment hits a valid random shard" invariant is testable without RNG.
 */
export function pickShard(r: number, numShards: number = kNumShards): number {
  const i = Math.floor(r * numShards);
  if (i < 0) return 0;
  if (i >= numShards) return numShards - 1;
  return i;
}

/**
 * Sum a metric's shard `count` values into its total (the daily rollup's core).
 * Tolerant: a never-incremented shard (missing/NaN/non-number `count`) contributes
 * 0, so a partial shard set still yields a correct sum.
 */
export function sumShards(values: Array<unknown>): number {
  let total = 0;
  for (const v of values) {
    if (typeof v === "number" && Number.isFinite(v)) total += v;
  }
  return total;
}

/** The UTC day-partition key (YYYY-MM-DD) — the `analyticsDaily/{day}` doc-id. */
export function dayKey(d: Date): string {
  return d.toISOString().slice(0, 10);
}

/** A `presence/{uid}` doc as the rollup reads it (Step 67 writes it; see the
 * STORAGE MODEL contract in the header). Fields are `unknown` — coerced here. */
export interface PresenceDoc {
  /** The client's persona/role, for the `byRole` breakdown. */
  role?: unknown;
  /** Epoch-ms of the last heartbeat — drives ghost-exclusion. */
  lastSeen?: unknown;
  /** The client uid (the doc id), for the bounded `sample`. */
  uid?: unknown;
}

/** The single-doc summary shape (minus the server `updatedAt` the wrapper stamps),
 * mirroring `presenceSummary/current` in the Step-65 rules. */
export interface PresenceSummary {
  /** Online clients (ghosts excluded). */
  count: number;
  /** Online counts grouped by role. */
  byRole: Record<string, number>;
  /** A bounded list of online uids — the owner sees WHO from ONE doc, without
   * reading the `presence/*` collection (R1-3). */
  sample: string[];
}

/**
 * PURE presence rollup (selftested like studio.ts's cores): fold the raw
 * `presence/*` docs into the single-doc summary {count, byRole, sample},
 * EXCLUDING ghosts — a doc whose `lastSeen` is older than `staleMs` is a
 * crashed/backgrounded client and is not counted (§66 addition-a, R1-3). `sample`
 * is capped so the summary stays a small doc regardless of how many are online.
 */
export function summarizePresence(
  docs: PresenceDoc[],
  now: number,
  staleMs: number = kPresenceStaleMs,
  sampleCap = 20
): PresenceSummary {
  let count = 0;
  const byRole: Record<string, number> = {};
  const sample: string[] = [];
  for (const d of docs) {
    const lastSeen = typeof d.lastSeen === "number" ? d.lastSeen : 0;
    if (now - lastSeen > staleMs) continue; // ghost → not counted
    count++;
    const role =
      typeof d.role === "string" && d.role.length > 0 ? d.role : "unknown";
    byRole[role] = (byRole[role] ?? 0) + 1;
    const uid = typeof d.uid === "string" && d.uid.length > 0 ? d.uid : null;
    if (uid !== null && sample.length < sampleCap) sample.push(uid);
  }
  return { count, byRole, sample };
}

// ── distributed-counter increment (Admin SDK) ────────────────────────────────

/**
 * Increment a hot metric by scattering the write across `kNumShards` shard docs
 * (`analyticsCounters/{metric}/shards/{n}`) — the standard Firestore distributed
 * counter, so no single doc takes more than ~1/N of the write rate. The daily
 * rollup sums the shards back. FIRE-AND-FORGET-SAFE: a counter blip must never
 * break a business flow, so a failure is logged, not thrown (audit גל-5 posture).
 */
export async function incrementMetric(
  metric: string,
  delta = 1
): Promise<void> {
  const shard = pickShard(Math.random());
  try {
    await db()
      .collection("analyticsCounters")
      .doc(metric)
      .collection("shards")
      .doc(String(shard))
      .set({ count: FieldValue.increment(delta) }, { merge: true });
  } catch (e) {
    logger.error("incrementMetric failed (ignored)", {
      metric,
      error: String(e),
    });
  }
}

// ── scheduled rollups (deploy-gated; Admin-SDK; write server-owned docs) ──────
//
// OPS NOTE — these two `onSchedule` functions require the Cloud Scheduler API
// (`cloudscheduler.googleapis.com`) to be ENABLED on the GCP project before the
// functions deploy can register their schedules. The CI service account cannot
// self-enable it (needs `serviceusage.services.enable`), so a project owner must
// enable it once in the console (or grant the SA that permission). Symptom when
// missing: `firebase deploy` fails with "Permissions denied enabling
// cloudscheduler.googleapis.com". See `.github/workflows/firebase-deploy.yml`
// "Required APIs" and `app_flutter/knowledge/STUDIO_GA.md`.

/**
 * DAILY rollup: sum every metric's distributed-counter shards and write ONE
 * `analyticsDaily/{day}` doc (the cumulative snapshot). The owner then reads ~1
 * doc/day instead of counting the raw event stream (§66.1). Idempotent: re-running
 * a day overwrites its snapshot with the same/updated totals. `maxInstances` caps
 * concurrency; the schedule caps frequency.
 */
export const rollupAnalyticsDaily = onSchedule(
  {
    schedule: kDailyRollupSchedule,
    timeZone: "Etc/UTC",
    region: REGION,
    maxInstances: kRollupMaxInstances,
  },
  async () => {
    const day = dayKey(new Date());
    const metricsSnap = await db().collection("analyticsCounters").get();
    const totals: Record<string, number> = {};
    await Promise.all(
      metricsSnap.docs.map(async (m) => {
        const shardsSnap = await m.ref.collection("shards").get();
        totals[m.id] = sumShards(shardsSnap.docs.map((s) => s.get("count")));
      })
    );
    await db()
      .collection("analyticsDaily")
      .doc(day)
      .set(
        { ...totals, day, rolledAt: FieldValue.serverTimestamp() },
        { merge: true }
      );
    logger.info("analyticsDaily rollup complete", {
      day,
      metrics: Object.keys(totals).length,
    });
  }
);

/**
 * PRESENCE rollup: count online clients from `presence/*` SERVER-SIDE (ghosts
 * excluded) and write the single `presenceSummary/current` doc. The owner reads
 * THAT ONE doc — never a listener over the whole collection (R1-3). `updatedAt`
 * (server timestamp) lets the Step-67 UI label freshness / "לא-זמין" (R2-12).
 */
export const rollupPresenceSummary = onSchedule(
  {
    schedule: kPresenceRollupSchedule,
    region: REGION,
    maxInstances: kRollupMaxInstances,
  },
  async () => {
    const snap = await db().collection("presence").get();
    const docs: PresenceDoc[] = snap.docs.map((d) => ({
      role: d.get("role"),
      lastSeen: d.get("lastSeen"),
      uid: d.id,
    }));
    const summary = summarizePresence(docs, Date.now());
    await db()
      .collection("presenceSummary")
      .doc(kPresenceSummaryDocId)
      .set(
        { ...summary, updatedAt: FieldValue.serverTimestamp() },
        { merge: true }
      );
    logger.info("presenceSummary rollup complete", { count: summary.count });
  }
);
