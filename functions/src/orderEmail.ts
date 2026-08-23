// Order-confirmation email — SSOT: knowledge/DIRECTIVE-order-confirmation-email.md.
//
// Firestore trigger on `orders/{orderId}` creation → a pretty RTL-Hebrew HTML
// confirmation email via Resend, to the CUSTOMER (when the order carries an
// email) and ALWAYS a copy to the business OWNER.
//
// GATED + default-OFF (byte-identical until the owner turns it on):
//   • `ORDER_EMAIL` (string param) must equal "true", AND
//   • `RESEND_API_KEY` (secret) must be set (`firebase functions:secrets:set
//     RESEND_API_KEY`).
// Missing either ⇒ the trigger returns immediately (no send, never throws), so a
// deploy without the key/flag is a safe no-op. No customer email ⇒ owner copy
// only (edge case per the directive — degrade, don't fail).

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret, defineString } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import { Resend } from "resend";
import { OWNER_EMAIL, REGION } from "./common";

/** Resend API key — bound as a secret (never in client / repo). */
const resendKey = defineSecret("RESEND_API_KEY");

/** Master flag. Default "" ⇒ OFF ⇒ the trigger no-ops (byte-identical). */
const orderEmailFlag = defineString("ORDER_EMAIL", { default: "" });

/** From-address. Uses the owner's VERIFIED Resend domain (buildsmart-il.com —
 *  DKIM + SPF confirmed), so the confirmation delivers to ANY customer, not just
 *  the Resend-account owner (the free-tier shared-sender restriction is lifted
 *  once a domain is verified). Deliberately a plain const, NOT a defineString
 *  param: under `firebase deploy --non-interactive` a *defaulted* string param
 *  is still reported as "no value" and aborts the deploy, so the sender lives in
 *  code. */
const fromAddress = "בנייה חכמה <noreply@buildsmart-il.com>";

/** Live brand icon (the deployed PWA icon) — used as the email logo. */
const kLogoUrl = "https://buildsmart-il.com/icons/Icon-192.png";
const kBrand = "#FF7A18";

function esc(v: unknown): string {
  return String(v ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function fmtDate(iso: unknown): string {
  const s = typeof iso === "string" ? iso : "";
  const d = s ? new Date(s) : new Date();
  if (isNaN(d.getTime())) return "";
  // dd/mm/yyyy — Israeli format, no locale dependency.
  const p = (n: number) => String(n).padStart(2, "0");
  return `${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()}`;
}

/** True when the string looks like an email — used to label the contact row
 *  ("אימייל" vs "טלפון") so an email address is never mislabeled as a phone. */
function looksLikeEmail(s: string): boolean {
  return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(s.trim());
}

type Line = { name?: unknown; emoji?: unknown; qty?: unknown; price?: unknown };

/** The pretty RTL confirmation email. Pure (testable). */
export function buildOrderEmailHtml(args: {
  orderId: string;
  customerName: string;
  dateStr: string;
  lines: Line[];
  sum: number;
  customerPhone: string;
  customerEmail: string;
}): string {
  const { orderId, customerName, dateStr, lines, sum, customerPhone, customerEmail } =
    args;
  const rows = lines
    .map((l) => {
      const name = `${esc(l.emoji ?? "")} ${esc(l.name ?? "")}`.trim();
      const qty = esc(l.qty ?? "");
      const price = Number(l.price ?? 0);
      return `<tr>
        <td style="padding:10px 12px;border-bottom:1px solid #eee;text-align:right">${name}</td>
        <td style="padding:10px 12px;border-bottom:1px solid #eee;text-align:center">${qty}</td>
        <td style="padding:10px 12px;border-bottom:1px solid #eee;text-align:left;white-space:nowrap">₪${price.toLocaleString()}</td>
      </tr>`;
    })
    .join("");

  // Contact rows: label by TYPE, never "טלפון" on an email. A phone row only for
  // a real phone value; an email row for either a dedicated customerEmail or a
  // contact that is itself an email.
  const phoneVal = (customerPhone ?? "").trim();
  const emailVal = (customerEmail ?? "").trim();
  const emailToShow = emailVal || (looksLikeEmail(phoneVal) ? phoneVal : "");
  const contactRows =
    (phoneVal && !looksLikeEmail(phoneVal)
      ? `<tr><td style="padding:4px 0;color:#888">טלפון</td><td style="padding:4px 0;text-align:left">${esc(phoneVal)}</td></tr>`
      : "") +
    (emailToShow
      ? `<tr><td style="padding:4px 0;color:#888">אימייל</td><td style="padding:4px 0;text-align:left">${esc(emailToShow)}</td></tr>`
      : "");

  return `<!doctype html>
<html lang="he" dir="rtl"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;background:#f5f5f7;font-family:'Heebo',Arial,Helvetica,sans-serif;color:#1b1b1f">
  <div style="max-width:600px;margin:0 auto;padding:24px 16px">
    <div style="background:linear-gradient(150deg,#FF8A2B,#F0620E);border-radius:18px 18px 0 0;padding:28px 24px;text-align:center">
      <img src="${kLogoUrl}" width="72" height="72" alt="בנייה חכמה" style="border-radius:16px;display:block;margin:0 auto 10px">
      <div style="color:#fff;font-size:24px;font-weight:800">בנייה חכמה</div>
      <div style="color:#fff;opacity:.92;font-size:15px;margin-top:4px">אישור הזמנה</div>
    </div>
    <div style="background:#fff;border-radius:0 0 18px 18px;padding:24px;box-shadow:0 6px 24px rgba(0,0,0,.06)">
      <p style="font-size:17px;margin:0 0 4px">שלום ${esc(customerName) || "לקוח יקר"},</p>
      <p style="font-size:15px;color:#555;margin:0 0 20px">קיבלנו את הזמנתך — תודה שהזמנת מבנייה חכמה! 🧡</p>

      <table style="width:100%;border-collapse:collapse;font-size:14px;margin-bottom:16px">
        <tr><td style="padding:4px 0;color:#888">מס' הזמנה</td><td style="padding:4px 0;text-align:left;font-weight:700">${esc(orderId)}</td></tr>
        <tr><td style="padding:4px 0;color:#888">תאריך</td><td style="padding:4px 0;text-align:left">${esc(dateStr)}</td></tr>
        ${contactRows}
      </table>

      <table style="width:100%;border-collapse:collapse;font-size:14px;border:1px solid #eee;border-radius:10px;overflow:hidden">
        <thead><tr style="background:#faf7f5">
          <th style="padding:10px 12px;text-align:right;color:#888;font-weight:600">מוצר</th>
          <th style="padding:10px 12px;text-align:center;color:#888;font-weight:600">כמות</th>
          <th style="padding:10px 12px;text-align:left;color:#888;font-weight:600">מחיר</th>
        </tr></thead>
        <tbody>${rows}</tbody>
        <tfoot><tr>
          <td colspan="2" style="padding:12px;text-align:right;font-weight:800;font-size:16px">סה"כ</td>
          <td style="padding:12px;text-align:left;font-weight:800;font-size:16px;color:${kBrand};white-space:nowrap">₪${Number(sum).toLocaleString()}</td>
        </tr></tfoot>
      </table>

      <p style="font-size:13px;color:#888;margin:22px 0 0;line-height:1.6">
        נחזור אליך עם עדכוני-סטטוס. לשאלות: <a href="mailto:${esc(OWNER_EMAIL)}" style="color:${kBrand}">${esc(OWNER_EMAIL)}</a>.
      </p>
    </div>
    <div style="text-align:center;color:#aaa;font-size:12px;padding:16px 0">בנייה חכמה · רכש וניהול לאתרי בנייה</div>
  </div>
</body></html>`;
}

export const onOrderCreatedEmail = onDocumentCreated(
  {
    region: REGION,
    document: "orders/{orderId}",
    secrets: [resendKey],
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (event) => {
    // ── Gate: default-off. No flag / no key ⇒ silent no-op (byte-identical). ──
    if (orderEmailFlag.value() !== "true") return;
    const apiKey = resendKey.value();
    if (!apiKey) return;

    const snap = event.data;
    if (!snap) return;
    const o = snap.data() ?? {};
    const orderId = event.params.orderId;

    // Recipients: owner ALWAYS; customer only when the order carries an email.
    const customerEmail =
      typeof o.customerEmail === "string" ? o.customerEmail.trim() : "";
    const isEmail = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(customerEmail);
    const to = isEmail ? [customerEmail, OWNER_EMAIL] : [OWNER_EMAIL];

    const lines = Array.isArray(o.lines) ? (o.lines as Line[]) : [];
    const html = buildOrderEmailHtml({
      orderId,
      customerName:
        typeof o.contractorId === "string" ? o.contractorId : "",
      dateStr: fmtDate(o.ts),
      lines,
      sum: Number(o.sum ?? 0),
      customerPhone:
        typeof o.customerPhone === "string" ? o.customerPhone : "",
      customerEmail,
    });

    try {
      const resend = new Resend(apiKey);
      await resend.emails.send({
        from: fromAddress,
        to,
        subject: `אישור הזמנה ${orderId} · בנייה חכמה`,
        html,
      });
      logger.info("order-email sent", { orderId, toCount: to.length });
    } catch (e) {
      // Never fail the trigger — email is best-effort (the order is already saved).
      logger.warn("order-email send failed (ignored)", { orderId, err: String(e) });
    }
  }
);
