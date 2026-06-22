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

import { REGION } from "./common";

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

// Default to the small/cheap model — the first features (grounded yes/no spec
// reasoning) don't need Opus. A caller may override with a known model id.
const kDefaultModel = "claude-haiku-4-5-20251001";
const kDefaultMaxTokens = 1024;
const kMaxPromptChars = 8000;
const kMaxTokensCap = 2048;

// Lazy, cached client — NEVER constructed at module scope (the load-order rule
// in common.ts; same lazy pattern as r2.ts `s3()`). The secret is only readable
// inside a request that bound it.
let cachedClient: Anthropic | null = null;
function client(): Anthropic {
  return (cachedClient ??= new Anthropic({ apiKey: anthropicKey.value() }));
}

interface AskClaudeData {
  prompt?: unknown;
  system?: unknown;
  model?: unknown;
  maxTokens?: unknown;
}

export const askClaude = onCall(
  { region: REGION, secrets: [anthropicKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
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
      typeof data.model === "string" && data.model.length > 0
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
