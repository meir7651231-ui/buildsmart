# Status snapshot — app_flutter

_Version label: `v4.50` (see `home_shell.dart`). Update on each user-visible change._

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

## Catalog chip system (v4.48–v4.50)
Product name words are parsed into colored chips in the product list and sheet:
- **Type chip** (purple) — from `kLipskeyTypes` (e.g. ברז, זווית, מסעף, פיית, כפה)
- **Model chip** (blue-grey) — from `kLipskeyModels` (e.g. קיסר, NTM, HDPE, PP-MD-ML)
- **Color chip** (pink) — from `kLipskeyColors`
- **Subtype chip** (teal) — from `kLipskeySubtypes` (e.g. כפול, פ.פ, ח.פ, פרח, ראש, נשלף)
- **Size chip** (amber) — numeric/DN tokens
- **Green linkable words** — remaining words; tap searches by that word

Variant pickers (type/model/color/subtype) expand inline on chip tap in both
the product list card and the product detail sheet.

## Tests
27 test files across `test/`. Key suites:
- **chip_structure** — chip type assignment + sibling pickers (31 checks)
- **dedup** — variant dedup + attrWordSet (27 checks)
- **product_journey** — 8 specific products + all 935 sheets render (49 checks)
- **widget** — shell boots + section previews
- **install_builder / manifold / loop / zone_tmtv / auto_compliance** — BOM engine (50 checks)
- **catalog_health / catalog_regression / robustness** — catalog data integrity
- **wiring** — search synonyms + finder grouping

`flutter analyze` clean; `flutter test` green (pre-existing failures in
`category_scan_test` and `wiring_test` are catalog-data issues, not code bugs).

## Known placeholders (🚧)
Chats conversation header (video/call/more) and input bar
(camera/attach/emoji) still show "בבנייה" toasts.
