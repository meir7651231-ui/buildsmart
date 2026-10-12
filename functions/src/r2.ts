// ─────────────────────────────────────────────────────────────────────────────
// S7.2 bridge — `getUploadUrl` callable: a presigned PUT URL against the
// Cloudflare R2 bucket (aws-sdk v3 S3 client; R2 speaks the S3 API).
//
// SSOT warning honoured: "creds (R2/admin) בשרת/Functions בלבד — לעולם לא
// client". NOTHING here is hardcoded:
//   • R2_ACCESS_KEY_ID / R2_SECRET_ACCESS_KEY — Secret Manager
//     (`firebase functions:secrets:set …`), bound via `secrets:` below;
//   • R2_ACCOUNT_ID / R2_BUCKET — string params (functions/.env.<project> or
//     deploy-time prompt).
//   (`firebase functions:config:set r2.*` was the legacy v1 mechanism — the
//   Runtime Config API is decommissioned; this codebase is v2 and uses
//   params/secrets. Full setup steps: README.)
//
// The OBJECT KEY IS SERVER-OWNED:
// `{kind}/{uid}/{ts}-{uuid}-{sanitized-name}.{ext}` ({ext} always from the
// allowlisted contentType; the caller's own extension is dropped) — the
// client never chooses the path (no traversal, no cross-user overwrite), only
// an upload kind (POD / before-after photos per S7.2) + an image contentType.
// Every issued URL is audit-logged (S8.4).
// ─────────────────────────────────────────────────────────────────────────────

import { randomUUID } from "node:crypto";

import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { defineSecret, defineString } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { writeAudit } from "./audit";
import { asString, callerRoles, REGION } from "./common";

const r2AccountId = defineString("R2_ACCOUNT_ID");
const r2Bucket = defineString("R2_BUCKET");
const r2AccessKeyId = defineSecret("R2_ACCESS_KEY_ID");
const r2SecretAccessKey = defineSecret("R2_SECRET_ACCESS_KEY");

/** The two S7.2 upload surfaces (key prefixes). */
const UPLOAD_KINDS = ["pod", "before-after"] as const;
type UploadKind = (typeof UPLOAD_KINDS)[number];

/** Allowed image content types → default file extension. */
const CONTENT_TYPES: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/heic": "heic",
  "image/heif": "heif",
};

const EXPIRES_SECONDS = 300; // 5 minutes (the client PUTs immediately)
const MAX_UPLOAD_BYTES = 5 * 1024 * 1024; // optional declared-size ceiling

function isUploadKind(v: unknown): v is UploadKind {
  return typeof v === "string" &&
    (UPLOAD_KINDS as readonly string[]).includes(v);
}

/** Keep only a safe basename; never a path. The extension is ALWAYS the one
 *  derived from the allowlisted contentType (a caller's `.html` is dropped). */
function sanitizeFileName(name: string | null, ext: string): string {
  const last = (name ?? "").split("/").pop() ?? "";
  const base = (last.split("\\").pop() ?? "")
    .replace(/[^A-Za-z0-9._-]/g, "-")
    .replace(/^[.-]+/, "")
    .replace(/\.[^.]*$/, "") // drop the caller's extension
    .slice(0, 80);
  return `${base.length > 0 ? base : "upload"}.${ext}`;
}

// Lazy, cached S3 client — params/secrets are only readable at runtime.
let cachedClient: S3Client | null = null;
function s3(): S3Client {
  if (cachedClient === null) {
    const account = r2AccountId.value();
    if (account.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "R2_ACCOUNT_ID is not configured (functions env — see README)."
      );
    }
    cachedClient = new S3Client({
      region: "auto",
      endpoint: `https://${account}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: r2AccessKeyId.value(),
        secretAccessKey: r2SecretAccessKey.value(),
      },
      forcePathStyle: true,
      // Presign has no body: the default WHEN_SUPPORTED bakes
      // x-amz-checksum-crc32=AAAAAA== (CRC32 of an EMPTY payload) into every URL.
      requestChecksumCalculation: "WHEN_REQUIRED",
    });
  }
  return cachedClient;
}

interface GetUploadUrlData {
  kind?: unknown;
  contentType?: unknown;
  fileName?: unknown;
  size?: unknown;
}

export const getUploadUrl = onCall(
  { region: REGION, secrets: [r2AccessKeyId, r2SecretAccessKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    if (request.auth.token.firebase?.sign_in_provider === "anonymous") {
      // Guests keep the local base64 photo (client falls back on any error).
      throw new HttpsError("permission-denied", "A registered account is required.");
    }
    const data = (request.data ?? {}) as GetUploadUrlData;

    if (!isUploadKind(data.kind)) {
      throw new HttpsError(
        "invalid-argument",
        `kind must be one of: ${UPLOAD_KINDS.join(", ")}.`
      );
    }
    const contentType = typeof data.contentType === "string"
      ? data.contentType
      : "";
    const ext = CONTENT_TYPES[contentType];
    if (ext === undefined) {
      throw new HttpsError(
        "invalid-argument",
        `contentType must be one of: ${Object.keys(CONTENT_TYPES).join(", ")}.`
      );
    }
    // Optional declared byte size — when present it is SIGNED as Content-Length
    // (the PUT must carry exactly that many bytes). Absent = legacy (unbounded)
    // until the client sends it; then make it required.
    let size: number | undefined;
    if (data.size !== undefined && data.size !== null) {
      if (typeof data.size !== "number" || !Number.isInteger(data.size) ||
          data.size < 1 || data.size > MAX_UPLOAD_BYTES) {
        throw new HttpsError(
          "invalid-argument",
          `size must be an integer 1..${MAX_UPLOAD_BYTES}.`
        );
      }
      size = data.size;
    }
    const bucket = r2Bucket.value();
    if (bucket.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "R2_BUCKET is not configured (functions env — see README)."
      );
    }

    const uid = request.auth.uid;
    const key =
      `${data.kind}/${uid}/${Date.now()}-${randomUUID()}-` +
      sanitizeFileName(asString(data.fileName), ext);

    const url = await getSignedUrl(
      s3(),
      new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        ContentType: contentType,
        ...(size !== undefined ? { ContentLength: size } : {}),
      }),
      {
        expiresIn: EXPIRES_SECONDS,
        // The presigner marks content-type UNSIGNABLE by default — bind it (and
        // the declared length) into the signature so the PUT can't swap them.
        signableHeaders: new Set(
          size !== undefined ? ["content-type", "content-length"] : ["content-type"]
        ),
      }
    );

    await writeAudit({
      action: "r2.uploadUrl.issue",
      source: "getUploadUrl",
      actorUid: uid,
      actorRole: callerRoles(request.auth.token).join(",") || null,
      target: `r2://${bucket}/${key}`,
      before: null,
      after: { contentType, expiresIn: EXPIRES_SECONDS },
      ok: true,
    });

    return {
      ok: true,
      url,
      key,
      method: "PUT",
      headers: { "Content-Type": contentType },
      expiresIn: EXPIRES_SECONDS,
    };
  }
);
