# WIRING CONTRACT — app_flutter

What every interactive button / setting is expected to do, and its status.
**This contract is enforced by `test/wiring_test.dart`** (the wired-behavior rows
marked ✅ have an executable regression check). Keep this file and that test in
sync — if you change a behavior, update both.

Status legend: ✅ wired (real effect) · 🚧 בבנייה (placeholder toast) ·
⛔ blocked (needs price/rating/geo data, a server, or telephony that don't exist).

---

## Catalog settings (`catalog_settings_screen.dart` → `catalog_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| שמור היסטוריית חיפוש | gates recording recent searches; recents persist across launches via `recentSearchesProvider` (`addRecentSearch`, key `bs.recent-searches.v1`) | ✅ |
| סרגל מיון מהיר במוצרים | shows/hides the "מיון לפי" control | ✅ |
| גודל תמונות | product image size (small/med/large) — list rows (image column w/h) **and** grid cards (`gridCardImageMetrics`: image padding + emoji) | ✅ |
| מצב קומפקטי | product row height/margins (list) **and** grid card name-box/paddings | ✅ |
| הנפשות מופחתות | disables explode/diagram/pulse animations (app-wide) | ✅ |
| ניגודיות גבוהה | high-contrast theme (app-wide) | ✅ |
| גודל טקסט | global text scale (app-wide) | ✅ |
| סוג תצוגה (רשת/רשימה) | product grid ↔ list | ✅ |
| עמודות בתצוגת רשת | grid column count | ✅ |
| ניקוי היסטוריה / איפוס | clears recents / restores defaults | ✅ |
| מחירים/מע"מ/מטבע/מחיר-יחידה/השוואה | — | ⛔ no price data |
| דירוג/מרחק/ספקים מקומיים · AI×4 · יחידות/עשרוני · מיון-ברירת-מחדל · רדיוס | — | ⛔ no data/engine |

## Catalog search panel tools (`catalog_screen.dart` · `_SearchToolsRow`)

| Tool | Behavior | Status |
|---|---|---|
| 🎤 קולי | `VoiceService.listen` (browser speech) | ✅ |
| 📷 ברקוד | `openBarcodeScanner` | ✅ |
| ⚙️ פילטרים | sheet → `searchImageOnlyProvider`; live results filtered by `filterByImage` (הכל / עם תמונה בלבד) | ✅ |
| ↕️ מיון | sheet → `catalogProductSortProvider` (`_sortProducts`): ברירת מחדל / שם א-ת / שם ת-א / מק"ט, applied to live results | ✅ |
| ▦ קטלוג | closes the panel + jumps to the קטגוריות section | ✅ |
| filter "עם מחיר" / price sort | — | ⛔ no price data |

## Catalog search — product matching (`catalog_screen.dart` · `catalogProductMatchesQuery`)

| Behavior | Detail | Status |
|---|---|---|
| forgiving product search | matches across name + category + SKU + colour, word-by-word (order-independent); folds Hebrew gershayim/geresh (״ ׳ → " ') so a Hebrew-keyboard size query matches; expands everyday words via `kSearchSynonyms` (kept precise — e.g. שירותים → toilet fixtures only, not branch connectors); AND-match with a graceful any-word fallback (`requireAll:false`) so a reasonable query never dead-ends | ✅ |
| relevance ranking | default order sorts results by `searchRelevance` (name match > category-only > synonym/colour), so the product the user meant surfaces first; an explicit ↕️ sort overrides it | ✅ |

## Catalog מאתר finder (`finder_screen.dart`)

| Behavior | Detail | Status |
|---|---|---|
| type groups | `kFinderGroups` — 6 plain-language groups + אחר catch-all; groups are pairwise disjoint and every catalog product is reachable | ✅ |
| sub-types | curated `kFinderSubs` (ברזים · ניקוז) cover every group category that has products, with unique labels and no 1-item junk chips; other groups auto-derive sub-types from `categoryHe`, merged by cleaned label | ✅ |
| narrow chips | `_narrowOptions`: curated facets (`kFinderFacets`) → sizes (`_sizeRe` — incl. decimal/compound inch + cross sizes) → colours → distinguishing words | ✅ |
| results | render through the shared `LipskeyProductsList` (variant dedup + quantity wheel) | ✅ |

## Chat settings (`chat_settings_screen.dart` → `chat_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| בוט (botEnabled) | enables the canned auto-reply | ✅ |
| חיווי הקלדה | shows "מקליד..." before a bot reply | ✅ |
| אישורי קריאה | sent ticks blue ✓✓ vs grey ✓ | ✅ |
| רטט (chatVibration) | haptic on send | ✅ |
| ברכת פתיחה | seeds a greeting in a fresh chat | ✅ |
| זמן מקוון אחרון (lastSeenPrivacy) | nobody → hides "פעיל כעת" + online dot (`showOnlinePresence`) | ✅ |
| מדיה/גיבוי/שפה/שעות-עסקיות/פרטיות/lock-preview/auto-archive/spam | — | ⛔ media/server |

## Chats screen (`chats_screen.dart`)

| Button | Behavior | Status |
|---|---|---|
| חיפוש / פילטר צ'יפים | filter thread list | ✅ |
| לחיצה על שיחה | opens conversation | ✅ |
| החלקה לארכוב + ביטול | archive/restore (persistent) | ✅ |
| תפריט ⋮ → שיחה חדשה | opens an empty conversation with the contact | ✅ |
| תפריט ⋮ → ארכיון שיחות | opens the archive screen (restore per row) | ✅ |
| תפריט ⋮ → השתק הכל / בטל | mutes/unmutes all threads (persistent, toggles label) | ✅ |
| תפריט ⋮ → הגדרות | opens ChatSettingsScreen | ✅ |
| שליחת הודעה | adds bubble (+ auto-reply if bot on) | ✅ |
| וידאו/שיחה/עוד · מצלמה/צירוף/אמוג'י/מיקרופון | — | 🚧 |

## Notifications (`notifications_screen.dart` → `notif_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| סוגי התראות: הזמנות/משלוחים/מבצעים/ירידות-מחיר | hide that category from the list (`notifMutedSections`) | ✅ |
| חשיבות (importanceFilter) | important/critical → only high-priority rows (`passesImportance`) | ✅ |
| snooze banner | mutes notifications temporarily | ✅ |
| push/email/sms/whatsapp · שעות-שקט · סיכומים · צליל/רטט · lock-screen · לפי-תפקיד | — | ⛔ no notif engine |

## Store (`store_screen.dart` → `store_settings.dart`)

| Setting / button | Behavior | Status |
|---|---|---|
| defaultPayment | seeds the cart payment method | ✅ |
| selfPickupDefault | seeds delivery = pickup | ✅ |
| vatInclusive | VAT shown embedded vs added; total adjusts | ✅ |
| minOrderAmount | blocks checkout below the minimum | ✅ |
| confirmLargeOrder + largeOrderThreshold | confirm dialog at checkout | ✅ |
| cart stepper (+ / − / לעגלה) | `qtyForKey` / `setQtyForKey` | ✅ |
| saveCartToProject | show/hide the cart project selector | ✅ |
| summary chips (פריטים בסל / הזמנות פתוחות / הצעות ספקים) | derived live: `cartItemCount` (cart+smart lines), `isOrderOpen` over `_kOrders`, offers single-sourced from the מכרז ספקים row badge | ✅ |
| כתובות/חשבוניות/ספקים/השכרה/אחריות/ביומטרי/אשראי-יומי | — | ⛔ server/data |

## Install Studio (`install_studio_screen.dart` → `logic/install_engine.dart`)

| Button | Behavior | Status |
|---|---|---|
| הוסף מוצר | append a chain anchor from the dark catalog picker | ✅ |
| **השלם התקנה** | linear `buildInstallation`, or `buildTreeInstallation` when a manifold is mid-chain (trunk → branches); dark BOM sheet with quantities, ⑂ branch count + outlet warning, gaps; "החל על הקו" applies it | ✅ |
| מטראז׳ צינור (− / +) | per-pipe length in metres; header totals "X מ׳ צנרת" | ✅ |
| טמפ׳ הקו | cycles 20/60/80°C (material suitability) | ✅ |

---

## Verified by regression (`test/wiring_test.dart`)
- cart `qtyForKey` / `setQtyForKey` (sum, collapse, remove-at-0)
- store `cartPaymentProvider` / `cartDeliveryProvider` defaults from store settings
- `notifMutedSections` mapping (all-on → none; per-type off → matching section)
- chat mute notifier (`setAll`) and archive notifier (`archive`/`restore`)
- finder grouping: groups disjoint, אחר catch-all + no blank category, curated
  `kFinderSubs` cover every group category w/ products, unique labels, cats ⊆ group
- `catalogProductMatchesQuery`: category-word match, synonym expansion,
  `requireAll:false` graceful superset, colour searchable, שירותים precision
  (no connector match), `searchRelevance` ranks name-match above synonym-match

UI-only effects (theme/contrast/text-scale, grid layout, VAT display, image size)
are documented above but exercised through their underlying providers/helpers
rather than pixel rendering.
