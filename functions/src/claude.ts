// ─────────────────────────────────────────────────────────────────────────────
// askClaude — a thin, AUTH-gated server proxy to the Anthropic API. Mirrors the
// `r2.ts` callable pattern exactly (auth-gated, no App-Check enforcement — the
// same posture as computeCredit/getUploadUrl/reviewRoleRequest; App-Check
// enforcement is a later, all-callables-together hardening once attestation is
// confirmed in the shipped build, NOT a one-off that breaks only this endpoint).
//
// SSOT / security: the API key lives ONLY in Secret Manager
// (`ANTHROPIC_API_KEY`, bound via `secrets:` below — `firebase functions:secrets:set
// ANTHROPIC_API_KEY`), NEVER in the client. The Flutter `ClaudeGateway` calls this
// with {system, prompt[, model, maxTokens]}; we forward to Claude and return {text}.
//
// GROUNDING IS THE CALLER'S JOB: every feature passes the relevant VERIFIED data
// (a VerifiedSpec, a compliance checklist, the closed recipe set…) inside `prompt`
// /`system`, so the model REASONS OVER TRUTH and never invents catalog parts. This
// proxy is deliberately generic + dumb — it adds auth, App Check, input bounds, a
// cheap default model, and neutral error mapping; it does no prompt-building.
// ─────────────────────────────────────────────────────────────────────────────

import Anthropic from "@anthropic-ai/sdk";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { db, REGION } from "./common";

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

// Default to the small/cheap model — the first features (grounded yes/no spec
// reasoning) don't need Opus. A caller may override with a known model id.
const kDefaultModel = "claude-haiku-4-5-20251001";
// Allowlist (swarm/cost-safety): a caller may only pin a KNOWN model id — an
// unknown/arbitrary string falls back to the cheap default, so a caller can't pin
// an expensive model or pass garbage. Extend deliberately if a feature needs a tier.
const kAllowedModels = new Set<string>([
  kDefaultModel, // haiku 4.5 — the cheap default
  "claude-sonnet-4-6", // the only stronger tier this app may opt into
]);
const kDefaultMaxTokens = 1024;
const kMaxPromptChars = 8000;
const kMaxTokensCap = 2048;

// Cost-safety (audit גל-5): this proxy is a deliberately generic, auth-gated LLM
// endpoint, so a single signed-in account could otherwise loop it to drain the
// Anthropic budget. Two backstops: a hard concurrency cap (`maxInstances`, in the
// onCall options) bounds the burst, and a per-uid fixed-window limiter (below)
// bounds sustained volume. Per-request cost is already bounded (model allowlist +
// 2048-token cap), so a generous window is fine — it only has to stop a runaway.
const kRateWindowMs = 60_000; // 1-minute rolling window
const kRateMaxPerWindow = 40; // generous for a human; a loop is thousands/min

// Fail-fast (audit גל-5): the Anthropic SDK defaults to a 10-MINUTE timeout with
// 2 retries — on a stuck upstream the callable would hang to the function ceiling
// and the app would sit on a dead spinner. Bound it so a stall maps quickly to the
// existing `internal`→retry path. Paired with `timeoutSeconds: 30` on the onCall.
const kClientTimeoutMs = 25_000;

// Lazy, cached client — NEVER constructed at module scope (the load-order rule
// in common.ts; same lazy pattern as r2.ts `s3()`). The secret is only readable
// inside a request that bound it.
let cachedClient: Anthropic | null = null;
function client(): Anthropic {
  return (cachedClient ??= new Anthropic({
    apiKey: anthropicKey.value(),
    timeout: kClientTimeoutMs,
    maxRetries: 1,
  }));
}

// Per-uid fixed-window rate limit, enforced in a Firestore transaction on
// `_claudeRate/{uid}` (server-only — clients never read/write it; admin SDK
// bypasses rules). Throws `resource-exhausted` once the window budget is spent.
// A transient Firestore error FAILS OPEN (logs + allows): the abuse case is rare,
// but an infra blip would otherwise block every real user.
async function enforceRateLimit(uid: string): Promise<void> {
  const ref = db().collection("_claudeRate").doc(uid);
  try {
    await db().runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const cur = snap.exists ? snap.data() : undefined;
      const now = Date.now();
      const windowStart =
        typeof cur?.windowStart === "number" ? cur.windowStart : 0;
      const count = typeof cur?.count === "number" ? cur.count : 0;
      if (now - windowStart >= kRateWindowMs) {
        tx.set(ref, { windowStart: now, count: 1 });
        return;
      }
      if (count >= kRateMaxPerWindow) {
        throw new HttpsError(
          "resource-exhausted",
          "Too many requests — try again shortly."
        );
      }
      tx.set(ref, { windowStart, count: count + 1 }, { merge: true });
    });
  } catch (e) {
    if (e instanceof HttpsError) throw e; // the real limit — propagate
    logger.error("askClaude: rate-limit check failed (allowing)", {
      error: String(e),
    });
  }
}

interface AskClaudeData {
  prompt?: unknown;
  system?: unknown;
  model?: unknown;
  maxTokens?: unknown;
}

export const askClaude = onCall(
  // maxInstances caps concurrency → a hard ceiling on parallel spend; timeoutSeconds
  // pairs with the SDK client timeout so a stuck upstream fails fast (audit גל-5).
  { region: REGION, secrets: [anthropicKey], maxInstances: 10, timeoutSeconds: 30 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    await enforceRateLimit(request.auth.uid);
    const data = (request.data ?? {}) as AskClaudeData;

    const prompt = typeof data.prompt === "string" ? data.prompt.trim() : "";
    if (prompt.length === 0) {
      throw new HttpsError("invalid-argument", "prompt is required.");
    }
    if (prompt.length > kMaxPromptChars) {
      throw new HttpsError(
        "invalid-argument",
        `prompt exceeds ${kMaxPromptChars} characters.`
      );
    }
    const system =
      typeof data.system === "string" && data.system.length > 0
        ? data.system
        : undefined;
    const model =
      typeof data.model === "string" && kAllowedModels.has(data.model)
        ? data.model
        : kDefaultModel;
    const maxTokens =
      typeof data.maxTokens === "number" &&
      Number.isFinite(data.maxTokens) &&
      data.maxTokens > 0
        ? Math.min(Math.round(data.maxTokens), kMaxTokensCap)
        : kDefaultMaxTokens;

    try {
      const msg = await client().messages.create({
        model,
        max_tokens: maxTokens,
        ...(system ? { system } : {}),
        messages: [{ role: "user", content: prompt }],
      });
      // Concatenate the text blocks (ignore any tool/thinking blocks).
      const text = msg.content
        .filter((b): b is Anthropic.TextBlock => b.type === "text")
        .map((b) => b.text)
        .join("");
      return { text, model };
    } catch (e) {
      logger.error("askClaude: request failed", { error: String(e) });
      throw new HttpsError("internal", "Claude request failed.");
    }
  }
);
