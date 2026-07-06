// ─────────────────────────────────────────────────────────────────────────────
// Pillar 5 · Step 56 — `publishConfig`, THE single sanctioned publish-to-all
// path for the Studio config tree. Mirrors `advanceOrderStage` (orders.ts:50):
// an AUTH-gated onCall that does its mutation inside a `runTransaction`, stamps
// who/when, and writes an `auditLog` entry on BOTH success and denial. The
// publish itself is a POINTER FLIP over immutable snapshots — O(users), not
// O(users×nodes) — so a publish to thousands of clients is a ~200B pointer read
// each (§6, cost). Behind `kServerCallables` (client) + deploy-gated (the
// callable is not shipped until the Studio flags flip).
//
// CANONICAL (spec detail/051-068.md "Step 56", overrides the older "manager-only
// LWW" phrasing):
//
//  • COMPARE-AND-SET, not LWW. The caller carries `expectedBaseVersion` (the
//    published version its draft was branched from). Inside the transaction we
//    re-read `studioConfig/published.version`; if it has MOVED, the publish is a
//    CONFLICT (`failed-precondition` "פורסמה גרסה חדשה — רענן ומזג"), NEVER an
//    overwrite. Two managers publishing concurrently therefore cannot clobber
//    each other — the second one to land is rejected and must refresh + merge.
//
//  • AUTHORITY = owner OR dual-control, AND a LIVE allow-flag. Publishing to ALL
//    users is allowed only if the caller is the app owner (`isOwnerEmail`,
//    common.ts) OR a SECOND manager has approved this draft (two-person rule),
//    AND — re-checked at EXECUTION TIME inside the transaction — the live allow-
//    flag `studioConfig/publishAllow.enabled == true`. Re-reading the live flag
//    (not trusting only the ID-token claim) makes REVOCATION take effect in
//    seconds, not the ≤1h custom-claim propagation window: flip the flag off and
//    the very next publish attempt is denied.
//
//  • RATE-LIMIT + concurrency ceiling. A per-uid fixed-window limiter on
//    `_publishRate/{uid}` (the claude.ts:75 pattern, fail-open) bounds sustained
//    volume; `maxInstances: 10` bounds burst concurrency (not frequency — that's
//    the limiter's job). Publishing is rare (the owner coalesces many edits into
//    ONE "publish all"), so the window budget is deliberately small.
//
// STORAGE MODEL (assumptions — how the Firestore side is represented):
//   studioConfig/published            — the ~200B pointer {version, schema, ref,
//                                        checksum, publishedAt, publishedBy,
//                                        publishGuard}; callable-only-write (rules
//                                        `if false`, step 65). publishGuard is the
//                                        Step-57 audit-stamp (fresh each publish;
//                                        the revert trigger's legit-write marker);
//                                        version defaults 0 when absent.
//   studioConfig/publishAllow         — the LIVE allow-flag {enabled:bool}. Read
//                                        fresh in the tx. FAIL-CLOSED: an absent/
//                                        false doc DENIES (an explicit enable is
//                                        the kill-switch's "armed" state).
//   studioConfigApprovals/draft-<uid> — the DUAL-CONTROL approval a SECOND
//                                        manager writes {approved:bool,
//                                        approvedBy:<uid>}. Counts only when
//                                        approvedBy is a DIFFERENT uid than the
//                                        publisher (two-person rule).
//   studioConfigSnapshots/draft-<uid> — the caller's working draft (step 55 sink
//                                        writes ONLY here, owner-write §5).
//   studioConfigSnapshots/v<N>        — the IMMUTABLE frozen snapshot a publish
//                                        creates (never mutated; step 57 trigger
//                                        + rules protect it) → revert is a single
//                                        pointer flip back (always safe).
// ─────────────────────────────────────────────────────────────────────────────

import { FieldValue } from "firebase-admin/firestore";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { writeAudit } from "./audit";
import { asString, callerRoles, db, isOwnerEmail, REGION } from "./common";

// Per-uid publish rate limit (claude.ts:49-50 pattern). Publishing is a rare,
// deliberate act — the owner stages many edits and publishes ONCE (§56 addition-b
// coalescing) — so a small window budget is plenty; a runaway loop is hundreds/min.
const kPublishRateWindowMs = 60_000; // 1-minute fixed window
const kPublishRateMaxPerWindow = 12; // generous for a human; a loop trips it fast

interface PublishConfigData {
  expectedBaseVersion?: unknown;
}

/** The verdict of the PURE publish-authorization + CAS decision (below). A
 * denial carries the exact HttpsError code + Hebrew reason the handler throws. */
export type PublishVerdict =
  | { ok: true; fromVersion: number; toVersion: number }
  | {
      ok: false;
      code: "failed-precondition" | "permission-denied";
      reason: string;
    };

export interface PublishDecisionInput {
  /** `studioConfig/published.version` re-read LIVE inside the transaction. */
  publishedVersion: number;
  /** `request.data.expectedBaseVersion` — the base the draft branched from. */
  expectedBaseVersion: number;
  /** `isOwnerEmail(request.auth)` — the owner authority root. */
  isOwner: boolean;
  /** A SECOND, DIFFERENT manager has approved this draft (two-person rule). */
  dualControlApproved: boolean;
  /** `studioConfig/publishAllow.enabled` re-read LIVE (revocation-in-seconds). */
  liveAllow: boolean;
}

/**
 * PURE decision (no I/O — selftested like orderFlow/creditCore/mayReviewRoleRequest):
 * given the live state read inside the transaction, may this publish proceed, and
 * to what version? Order matters:
 *   1. AUTHORITY — owner OR dual-control, else `permission-denied` (don't even
 *      reveal version state to an unauthorized caller);
 *   2. LIVE allow-flag — `permission-denied` if revoked, EVEN for the owner with
 *      a valid token claim (this is the seconds-not-hours revocation);
 *   3. CAS — `failed-precondition` if `publishedVersion` has moved off
 *      `expectedBaseVersion` (a stale base is a CONFLICT, never an overwrite).
 * On success the new version is `publishedVersion + 1`.
 */
export function decidePublish(i: PublishDecisionInput): PublishVerdict {
  // 1 · authority root: the owner, or a two-person dual-control approval.
  if (!i.isOwner && !i.dualControlApproved) {
    return {
      ok: false,
      code: "permission-denied",
      reason:
        "פרסום-לכולם דורש חשבון-בעלים או אישור דו-בקרה של מנהל שני.",
    };
  }
  // 2 · LIVE allow-flag re-check — revocation takes effect in seconds, not the
  //     ≤1h claim-propagation window. A revoked flag denies even a valid owner.
  if (!i.liveAllow) {
    return {
      ok: false,
      code: "permission-denied",
      reason: "פרסום מושבת כרגע — דגל-ההרשאה החי (publishAllow) כבוי או נשלל.",
    };
  }
  // 3 · compare-and-set on expectedBaseVersion (NOT LWW).
  if (i.publishedVersion !== i.expectedBaseVersion) {
    return {
      ok: false,
      code: "failed-precondition",
      reason: "פורסמה גרסה חדשה — רענן ומזג",
    };
  }
  return {
    ok: true,
    fromVersion: i.publishedVersion,
    toVersion: i.publishedVersion + 1,
  };
}

/**
 * PURE fixed-window predicate (selftested): given the stored `_publishRate/{uid}`
 * doc, is this request OVER budget? A new window (or a missing doc) is never over
 * budget; within the window it is over once `count >= maxPerWindow`. Shared by
 * the transactional limiter below so the shipped path and the test exercise the
 * SAME rule (the claude.ts:75 limiter inlines this — extracted here to test it).
 */
export function rateLimitExceeded(
  cur: { windowStart?: unknown; count?: unknown } | undefined,
  now: number,
  windowMs: number,
  maxPerWindow: number
): boolean {
  const windowStart =
    typeof cur?.windowStart === "number" ? cur.windowStart : 0;
  const count = typeof cur?.count === "number" ? cur.count : 0;
  if (now - windowStart >= windowMs) return false; // fresh window → allowed
  return count >= maxPerWindow;
}

/**
 * Per-uid fixed-window rate limit on `_publishRate/{uid}` (server-only; admin SDK
 * bypasses rules). Throws `resource-exhausted` once the window budget is spent.
 * A transient Firestore error FAILS OPEN (logs + allows) — an infra blip must not
 * block a real publish. Mirrors `enforceRateLimit` (claude.ts:75).
 */
async function enforcePublishRateLimit(uid: string): Promise<void> {
  const ref = db().collection("_publishRate").doc(uid);
  try {
    await db().runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const cur = snap.exists ? snap.data() : undefined;
      const now = Date.now();
      const windowStart =
        typeof cur?.windowStart === "number" ? cur.windowStart : 0;
      const count = typeof cur?.count === "number" ? cur.count : 0;
      if (now - windowStart >= kPublishRateWindowMs) {
        tx.set(ref, { windowStart: now, count: 1 });
        return;
      }
      if (rateLimitExceeded(cur, now, kPublishRateWindowMs, kPublishRateMaxPerWindow)) {
        throw new HttpsError(
          "resource-exhausted",
          "יותר מדי בקשות פרסום — נסה שוב בעוד רגע."
        );
      }
      tx.set(ref, { windowStart, count: count + 1 }, { merge: true });
    });
  } catch (e) {
    if (e instanceof HttpsError) throw e; // the real limit — propagate
    logger.error("publishConfig: rate-limit check failed (allowing)", {
      error: String(e),
    });
  }
}

/**
 * Publish the caller's staged draft to ALL users — the ONE sanctioned publish
 * path. Returns `{ ok:true, version:N, ref }` on success. See the module header
 * for the full contract (CAS · owner/dual-control · live allow-flag · rate-limit).
 */
export const publishConfig = onCall(
  { region: REGION, maxInstances: 10 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    const uid = request.auth.uid;
    const roles = callerRoles(request.auth.token);

    // The CAS base the client branched from — required, non-negative integer.
    const { expectedBaseVersion } = (request.data ?? {}) as PublishConfigData;
    if (
      typeof expectedBaseVersion !== "number" ||
      !Number.isInteger(expectedBaseVersion) ||
      expectedBaseVersion < 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "expectedBaseVersion (non-negative integer) is required."
      );
    }

    // Live version captured inside the transaction for the deny-audit trail.
    let denyPublishedVersion: number | null = null;

    try {
      await enforcePublishRateLimit(uid); // resource-exhausted (audited below)

      const result = await db().runTransaction(async (tx) => {
        // ── ALL READS FIRST (Firestore transaction rule) ──────────────────────
        const pubRef = db().collection("studioConfig").doc("published");
        const allowRef = db().collection("studioConfig").doc("publishAllow");
        const apprRef = db()
          .collection("studioConfigApprovals")
          .doc(`draft-${uid}`);
        const draftRef = db()
          .collection("studioConfigSnapshots")
          .doc(`draft-${uid}`);
        const [pubSnap, allowSnap, apprSnap, draftSnap] = await Promise.all([
          tx.get(pubRef),
          tx.get(allowRef),
          tx.get(apprRef),
          tx.get(draftRef),
        ]);

        const pv = pubSnap.get("version");
        const publishedVersion = typeof pv === "number" ? pv : 0;
        denyPublishedVersion = publishedVersion;

        // LIVE allow-flag (fail-closed: absent/false ⇒ denied).
        const liveAllow = allowSnap.get("enabled") === true;

        // Dual-control: a SECOND, DIFFERENT manager approved this draft.
        const approvedBy = asString(apprSnap.get("approvedBy"));
        const dualControlApproved =
          apprSnap.get("approved") === true &&
          approvedBy !== null &&
          approvedBy !== uid;

        const verdict = decidePublish({
          publishedVersion,
          expectedBaseVersion,
          isOwner: isOwnerEmail(request.auth),
          dualControlApproved,
          liveAllow,
        });
        if (!verdict.ok) {
          throw new HttpsError(verdict.code, verdict.reason);
        }

        // Authorized + CAS-clean — there must be a draft to freeze.
        if (!draftSnap.exists) {
          throw new HttpsError(
            "failed-precondition",
            "אין טיוטה לפרסום (studioConfigSnapshots/draft-<uid> ריק)."
          );
        }
        const draftData: Record<string, unknown> = draftSnap.data() ?? {};

        // ── WRITES ────────────────────────────────────────────────────────────
        const toVersion = verdict.toVersion;
        const snapId = `v${toVersion}`;
        const snapPath = `studioConfigSnapshots/${snapId}`;
        const nowIso = new Date().toISOString();

        // Freeze the draft into an IMMUTABLE vN snapshot (created once).
        tx.set(db().collection("studioConfigSnapshots").doc(snapId), {
          ...draftData,
          version: toVersion,
          frozenAt: nowIso,
          frozenBy: uid,
        });

        // Flip the published pointer to the new immutable snapshot.
        tx.set(
          pubRef,
          {
            version: toVersion,
            ref: snapPath,
            ...(typeof draftData.schema === "number"
              ? { schema: draftData.schema }
              : {}),
            ...(typeof draftData.checksum === "string"
              ? { checksum: draftData.checksum }
              : {}),
            publishedAt: nowIso,
            publishedBy: uid,
            // Step-57 audit-stamp: a FRESH publishGuard on EVERY publish is what
            // marks this pointer write as the callable's own. `revertIllegal-
            // ConfigWrite` skips any update that CHANGES publishGuard and reverts
            // any pointer move that does NOT — so the callable stays the ONE
            // sanctioned writer. `nowIso` guarantees the stamp differs each publish
            // (so a legit publish is never mistaken for a forgery, and vice-versa).
            publishGuard: { publishedAt: nowIso, version: toVersion },
          },
          { merge: true }
        );

        return { fromVersion: verdict.fromVersion, toVersion, ref: snapPath };
      });

      // before→after versions so a prevented overwrite stays traceable (R1-4).
      await writeAudit({
        action: "config.publish",
        source: "publishConfig",
        actorUid: uid,
        actorRole: roles.join(",") || null,
        target: "studioConfig/published",
        before: { version: result.fromVersion, expectedBase: expectedBaseVersion },
        after: { version: result.toVersion },
        ok: true,
      });
      return { ok: true, version: result.toVersion, ref: result.ref };
    } catch (e) {
      if (e instanceof HttpsError) {
        await writeAudit({
          action: "config.publish",
          source: "publishConfig",
          actorUid: uid,
          actorRole: roles.join(",") || null,
          target: "studioConfig/published",
          before: {
            version: denyPublishedVersion,
            expectedBase: expectedBaseVersion,
          },
          after: null,
          ok: false,
          reason: `${e.code}: ${e.message}`,
        });
      }
      throw e;
    }
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// Pillar 5 · Step 57 — `revertIllegalConfigWrite`, defense-in-depth around the
// published pointer. Mirrors `revertIllegalOrderStageWrite` (orders.ts:145): an
// onDocumentUpdated trigger that REVERTS any DIRECT write to `studioConfig/
// published` that did NOT go through `publishConfig` above. The callable is the
// ONE sanctioned writer — paired with the rules `allow write: if false` (step 65),
// this trigger is the second layer for writes that slip past / precede the rules.
//
// AUTH NOTE (mirror orders.ts:16-17,193): Firestore triggers carry NO auth
// context, so "sanctioned" cannot be decided by CALLER identity here — it is
// decided by the callable's AUDIT-STAMP. `publishConfig` writes a FRESH
// `publishGuard` ({publishedAt, version}) on every publish, so a legitimate
// pointer move ALWAYS changes publishGuard; a pointer move whose publishGuard is
// UNCHANGED did not pass through the callable → forged → reverted to the prior
// pointer. Role enforcement for legal direct writes is not this trigger's job
// (there is none — the pointer is callable-only); this trigger guards the STAMP.
//
// LOOP GUARD (mirror orders.ts:158-160 stageGuard): the revert re-stamps
// `publishGuard.revertedAt = event.id`. Because ANY change to publishGuard (the
// callable's publish stamp OR the revert's revertedAt stamp) is skipped, the
// revert's own write never re-triggers a revert — no infinite loop.
//
// ACCEPTED HOLE (documented — step 57.6 addition-a): a forger who ALSO writes a
// DIFFERENT publishGuard evades the stamp check (guard "changed" → skipped). The
// stamp is defense-in-depth, not a cryptographic proof of origin; the stronger
// check (a matching `config.publish` audit-entry for version N) is a future add.
// ─────────────────────────────────────────────────────────────────────────────

/** The pointer fields the revert decision needs, coerced off the snapshot. */
export interface ConfigPointerState {
  /** `studioConfig/published.version` (0 when absent). */
  version: number;
  /** `studioConfig/published.ref` — the snapshot path (null when absent). */
  ref: string | null;
  /** The callable's audit-stamp — compared BY VALUE (stringify), not inspected. */
  publishGuard: unknown;
}

export interface RevertDecisionInput {
  /** Pointer state BEFORE the write (onDocumentUpdated `change.before`). */
  before: ConfigPointerState;
  /** Pointer state AFTER the write (onDocumentUpdated `change.after`). */
  after: ConfigPointerState;
}

export type RevertVerdict = { revert: boolean; reason: string };

/**
 * PURE decision (no I/O — selftested like `decidePublish` / orderFlow): given the
 * before/after pointer states of a `studioConfig/published` update, should this
 * write be reverted as an illegal direct write? Order mirrors orders.ts:155-164:
 *   1. LOOP-GUARD — publishGuard CHANGED ⇒ the write bears a fresh stamp (the
 *      callable's publish OR the revert's own revertedAt) ⇒ NOT a forgery, skip.
 *   2. FORGERY — publishGuard UNCHANGED yet the pointer (version|ref) MOVED ⇒ a
 *      direct write that bypassed the callable (which always re-stamps) ⇒ revert.
 *   3. otherwise nothing meaningful changed ⇒ nothing to revert.
 */
export function decideRevert(i: RevertDecisionInput): RevertVerdict {
  const guardBefore = JSON.stringify(i.before.publishGuard ?? null);
  const guardAfter = JSON.stringify(i.after.publishGuard ?? null);
  // 1 · loop-guard (orders.ts:158-160): a changed guard is the callable's publish
  //     stamp or the revert's own revertedAt stamp — never a forgery.
  if (guardBefore !== guardAfter) {
    return {
      revert: false,
      reason:
        "publishGuard changed — sanctioned publish or revert write (loop-guard)",
    };
  }
  // 2 · the pointer MOVED with a STALE (unchanged) guard ⇒ it never passed the
  //     callable ⇒ forged direct write. Revert to the prior pointer.
  if (i.before.version !== i.after.version || i.before.ref !== i.after.ref) {
    return {
      revert: true,
      reason:
        "illegal direct write to studioConfig/published " +
        "(pointer moved without a fresh callable publishGuard stamp)",
    };
  }
  // 3 · guard unchanged AND pointer unchanged ⇒ inert write, nothing to revert.
  return { revert: false, reason: "no pointer change" };
}

/**
 * PURE superseded-check (selftested; mirror orders.ts:171 `snap.stage !== toStage`):
 * inside the revert transaction the LIVE `published.version` is re-read; the revert
 * proceeds ONLY if it still equals the `toVersion` the forgery set. A newer version
 * means a real publish already landed after the forgery — don't clobber it.
 */
export function revertStillApplies(
  liveVersion: number,
  toVersion: number
): boolean {
  return liveVersion === toVersion;
}

/** Coerce a Firestore field to a number, defaulting 0 (studio.ts:250 pattern). */
function numOr0(v: unknown): number {
  return typeof v === "number" ? v : 0;
}

/**
 * Defense-in-depth: revert any DIRECT `studioConfig/published` write that did not
 * pass through `publishConfig` (see the section header). The callable is the ONE
 * sanctioned writer; this trigger + the rules `allow write: if false` (step 65)
 * are the two layers that enforce it.
 */
export const revertIllegalConfigWrite = onDocumentUpdated(
  { region: REGION, document: "studioConfig/{channel}" },
  async (event) => {
    const change = event.data;
    if (!change) return;

    // Only the published POINTER is callable-only. `publishAllow` (the live
    // allow-flag) lives in the SAME `studioConfig` collection and is legitimately
    // toggled by the owner — it must NOT be reverted.
    const channel = event.params.channel;
    if (channel !== "published") return;

    const before = change.before;
    const after = change.after;

    const decision = decideRevert({
      before: {
        version: numOr0(before.get("version")),
        ref: asString(before.get("ref")),
        publishGuard: before.get("publishGuard") ?? null,
      },
      after: {
        version: numOr0(after.get("version")),
        ref: asString(after.get("ref")),
        publishGuard: after.get("publishGuard") ?? null,
      },
    });
    if (!decision.revert) return;

    const toVersion = numOr0(after.get("version"));
    await db().runTransaction(async (tx) => {
      const snap = await tx.get(after.ref);
      if (!snap.exists) return;
      // Superseded by a newer (real) publish that landed after the forgery?
      // Don't clobber it (mirror orders.ts:171).
      if (!revertStillApplies(numOr0(snap.get("version")), toVersion)) return;
      // Restore each pointer field to its pre-forgery value + stamp the loop-guard.
      tx.update(after.ref, {
        version: before.get("version") ?? FieldValue.delete(),
        ref: before.get("ref") ?? FieldValue.delete(),
        schema: before.get("schema") ?? FieldValue.delete(),
        checksum: before.get("checksum") ?? FieldValue.delete(),
        publishedAt: before.get("publishedAt") ?? FieldValue.delete(),
        publishedBy: before.get("publishedBy") ?? FieldValue.delete(),
        publishGuard: {
          revertedAt: event.id,
          from: numOr0(before.get("version")),
          to: toVersion,
        },
      });
    });

    logger.warn("illegal direct config write reverted", {
      channel,
      from: numOr0(before.get("version")),
      to: toVersion,
      // Self-reported by the writer; may be absent or spoofed (no auth context).
      reportedBy: asString(after.get("publishedBy")),
    });
    await writeAudit({
      action: "config.revert",
      source: "revertIllegalConfigWrite",
      // Triggers carry no auth context; publishedBy is self-reported by the writer
      // and may be absent or spoofed — recorded as-is for forensics.
      actorUid: asString(after.get("publishedBy")),
      actorRole: null,
      target: `studioConfig/${channel}`,
      before: { version: numOr0(before.get("version")) },
      after: { version: toVersion },
      ok: false,
      reason: decision.reason,
    });
  }
);
