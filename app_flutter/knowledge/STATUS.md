# Status snapshot — app_flutter

_Version label: `v3.79` (see `home_shell.dart`). Update on each user-visible change._

## Tabs & screens — all light-mode, readable
- **קטלוג** — overview blocks (categories / recent / compat / favorites / smart-tree),
  in-tab drill, grid↔list product view, smart-tree, **מאתר (finder)** — layman
  group→sub→narrow with relevance-ranked forgiving search, search panel.
- **שיחות** — thread list, conversation, archive screen, new-chat, mute-all.
- **התראות** — grouped list with per-type + importance filtering, snooze.
- **חנות** — sections all/cart/orders/services, full cart + checkout.
- **הגדרות** (×4: catalog/chat/notif/store) — light, count-badge headers.
- product sheet / detail / brand / suppliers / install-studio — light-mode.

## Wiring (≈26 settings/buttons wired to real effects)
See `../WIRING.md` for the full table. Highlights:
- **Catalog**: searchHistory, quickFilterBar, imageSize, compactMode,
  reducedMotion, highContrast, textSize, viewMode, gridColumns (+ clear/reset).
- **Chat**: botEnabled, typingIndicator, readReceipts, chatVibration,
  greetingEnabled, lastSeenPrivacy.
- **Notifications**: per-type filter (orders/shipments/deals/price-drops),
  importanceFilter, snooze.
- **Store**: defaultPayment, selfPickupDefault, vatInclusive, minOrderAmount,
  confirmLargeOrder/threshold, cart stepper, saveCartToProject.
- **Chats screen**: search/filter, open, swipe-archive (persistent), new-chat,
  archive screen, mute-all (persistent), settings, send.

## Persistent state
SharedPreferences: catalog/chat/notif/store settings, chat archived ids,
chat muted ids. Cart is in-memory (`smart_cart`).

## Blocked (⛔ — not locally wireable)
Prices/VAT-display/currency/unit-price/comparison · supplier rating/distance ·
AI recommendations · system notifications (push/email/sms/quiet-hours/summaries/
sound/lock-screen) · media/backup/telephony (video/call/camera/attach) ·
addresses/invoices/warranty/biometric. All need data, a server, or device APIs.

## Install Studio (v3.79 — BOM quality upgrade)
- **Progressive dock** — 3-state UX: empty / 1-item / 2+ items (D-013)
- **Zone-aware BOM** — "גזע" + "ענף א/ב/ג…" section headers with item counts
- **TMTV auto-per-branch** — one thermostatic mixing valve per hot branch, qty = branch count
- **Auto-compliance** — PRV + BladderTank + isolation ball valve auto-inserted for hot lines
- **Severity checklist** — 🔴 critical / 🟡 warning / 🔵 info; "N קריטי פתוח" badge in BomSheet
- **Gap hints** — each missing connection shows a suggested adapter to search
- **Temperature pill** — human labels (קר / חם / חם מאוד) with color coding

## Tests
~50 domain tests across `test/` (install_builder×10 + manifold×10 + loop×10 +
zone_tmtv×10 + auto_compliance×10). `flutter analyze` clean; `flutter test` green.

## Known placeholders (🚧)
Chats conversation header (video/call/more) and input bar
(camera/attach/emoji) still show "בבנייה" toasts.
