# BuildSmart — מסמך ארכיטקטורה ועיצוב מערכת (SDD)

> מסמך הנדסי מקיף · אומת מהקוד (`app_flutter/` v6.99 · `claude/whats-happening-LyY9G`) · 14.7.2026 · קהל: מתכנת בכיר.
> **היקף מאומת:** 506 קבצי‑Dart · 269 providers · 13 CI‑workflows · 10 server‑callables · 30+ Firestore collections · קטלוג 1,879 מוצרים · ~4,700 טסטים.

---

## 1. תקציר
פלטפורמת B2B לשרשרת‑האספקה של אינסטלציה/בנייה (קבלן · חנות · שליח · עובד · מנהל), עברית RTL, iOS/Android/Web. הריפו מכיל 2 פרויקטים: `app_flutter/` (Flutter, פעיל — יעד‑חנויות) ו‑`app/` (Preact, legacy‑production ב‑GitHub Pages). המסמך מתאר את app_flutter. מיגרציית "קטלוג→שרת" (C1‑C5) הושלמה‑רדומה; מערך‑המשתמשים הוא הפרויקט‑הבא.

## 2. סטאק טכנולוגי
| שכבה | טכנולוגיה |
|---|---|
| שפה/פריימוורק | Flutter · Dart SDK ^3.7.2 (Flutter 3.44) |
| State | flutter_riverpod ^2.6.1 (269 providers) |
| Backend | Firebase — cloud_firestore ^6.5 · firebase_auth ^6.5 · cloud_functions ^6.3 · messaging · app_check ^0.4 · crashlytics · analytics |
| Auth | firebase_auth + google_sign_in (Google/מייל/טלפון‑OTP/אנונימי) |
| תמונות/CDN | Cloudflare R2 (קטלוג) · cached_network_image · flutter_cache_manager (LRU) |
| קלט‑שטח | mobile_scanner (ברקוד) · speech_to_text (קולי) · camera · geolocator |
| Functions | Node/TypeScript · @anthropic-ai/sdk |
| CI/CD | GitHub Actions (13 workflows) |

## 3. עקרונות‑ארכיטקטורה
- **Repository pattern:** כל נתון דרך interface; החלפת‑מקור (local↔firebase↔server) = drop‑in בלי לגעת ב‑UI/מנועים.
- **Flag‑gating byte‑identical:** כל פיצ׳ר מאחורי env dart‑define; OFF ⇒ tree‑shaken ⇒ זהה‑בייטים. שער‑בטיחות קבוע.
- **Strangler migration:** לוגיקה‑חדשה לצד‑הישנה, מחליפים רק בהפעלה (catalog→server נבנה‑לצד‑האפוי, מודלק בהדרגה).
- **Cache‑pattern:** sync‑reads מ‑cache · listeners/paged מ‑Firestore · optimistic‑writes · LRU → מהיר+אופליין+עלות‑DB נמוכה.
- **Owner‑gated:** Studio/Trade‑Builder מגודרים ל‑owner‑manager לא‑מזויף.
- **Baked‑engine:** הקטלוג bundled+R2‑CDN; חוקי‑המנוע אפויים — נשארים אפויים (IP + latency). ה"מה"→שרת, ה"איך"→אפוי.

## 4. ארכיטקטורת‑ניווט
```
Welcome → Onboarding(הרשאות) → בחירת‑תפקיד
  ├ 👷 קבלן  → 4 טאבים (בית·מחלקות·עדכונים·חנות) + תפריט‑נסתר
  ├ 🏪 חנות  → StoreDashboard (4 אזורים)
  ├ 🛵 שליח  → CourierDashboard (4 אזורים)
  ├ 🦺 עובד  → WorkerApp (3 אזורים)
  └ 👔 מנהל  → ManagerDashboard (4 טאבים · +5 kIntelLive רדום)
```
מסך‑מלא = `Navigator.push+Scaffold` · תוכן‑נקודתי = bottom‑sheet · אין go_router. מקלדת‑כרטיס צפה = Overlay גלובלי מעל ה‑Navigator (`main.dart:447`, KB_GLOBAL).

## 5. חלוקת Client/Server + מצב‑מיגרציה
**אפוי (bundled, בכוונה):** kCatalogTree (taxonomy) · חוקי‑המנוע (תאימות/תקנים/כלים) · מילוני‑סלנג · תמונות (R2).

**בשרת (מאחורי דגלים):**
| גל | דומיינים | דגל | מצב |
|---|---|---|---|
| קטלוג→שרת (C1‑C5) | catalogProducts·verified_specs·recipes·stores·inventory·pricing | useServerCatalog | ✅ בנוי·ירוק·רדום |
| SERVER‑SWAP | orders·chat·customers·material‑requests·finance·site·stock·projects·presence | USE_FIREBASE_BACKEND | ◑ ON ב‑APK · OFF ב‑web |
| Studio | studioConfigLive (shared‑sync) | STUDIO_SHARED_SYNC | ✅ חי |
| Intel/Analytics | analyticsEvents/Daily·presenceSummary | INTEL_LIVE | ◑ רדום |

דגלים שונים **per‑target:** web‑demo (מאתרים+מקלדת+חיפוש+studio, קטלוג‑אפוי, backend OFF) · test‑APK (backend+Claude ON) · dormant.

## 6. מודל‑הנתונים
**מוצר — 16 שדות** (`LipskeyCatalogProduct`):
```
{sku, nameHe, nameEn, color?, qtyPack?, qtyPallet?, categoryHe, categoryEn,
 categoryEmoji, page, dims:Map, imageFile?, imageFiles?, specImageFile?, specImageFiles?, brand}
```
+ getters נגזרי‑שם (לא‑נשמרים): productType·connectionSizes·connectionGender·connectionMethod·brandModel·colorVariant·typeEmoji.

**שכבות נלוות (keyed by sku):**
- `VerifiedSpec` (×890): ends[ConnectorEnd{type∈6,size}]·material(12)·pressureRating·pexType·maxTempC·systemOverride → מנוע‑התאימות.
- `SmartProduct` recipe: {stages, brands[rec/price/sku], acc[why/must/sku]} → מנוע‑עבודות.
- `Store{id,name,area,ownerUid}` · `Inventory{storeId,sku,price,stock,updatedAt}` → רב‑חנותיות (חדש).

**30+ collections:** catalogProducts·catalogCategories·catalogMeta·recipes·inventory·pricing·stores · orders·customers·chatThreads·chatMessages·projects·siteNodes·stock·financeApprovals/PaymentTerms/Penalties·roleRequests·presence·analytics*·users·shards.

## 7. מפת‑המודולים
| מודול | תיאור | היקף |
|---|---|---|
| קטלוג + מאתרים | 4 מאתרים מעל מנוע‑צלילה אחד + הזמנת‑רץ | catalog_screen + features/ring_dive |
| מקלדת | מקלדת‑כרטיס צפה = מנווט · live‑mirror · global overlay | floating_card_keyboard |
| חיפוש‑על | 7 דומיינים · fuzzy+ranking | features/global_search |
| Studio No‑Code | 861 CfgText · WYSIWYG · shared‑sync | state/studio |
| מנהל | 4 טאבים · god‑mode | manager_dashboard (4,018) |
| חנות/עובד/שליח | דשבורדים מלאים | 2,906 / 2,117 / 1,638 |
| מנוע‑הזמנות | מכונת‑מצבים 6‑שלבים חוצה‑תפקידים | state/orders_engine |

## 8. המנועים ⭐ (ליבת‑ה‑IP)
- **צלילה:** kRdAxes/kCatAxes (8→17 צירים) · בחירת‑ציר ב‑info‑gain (Shannon entropy) · קורא categoryHe·color·brand·dims+נגזרי‑שם.
- **תאימות:** `compatibleWith()` — לולאה ends×ends; מתאים אם directMates(type+size) או pipeShared+material‑compat. מזין תאימות·תקנים(ת"י)·כלים·מתאמים.
- **עבודות:** `smartProductForSku`→recipe; join לפי sku. מזין ערכות·עלות·סיכום.
- **חיפוש:** fuzzy(nameHe)+סלנג(~114)+מורפולוגיה+דו‑לשוני+ניבוי(nameAffinity/prominence/matesBoost/jobBoost)+דירוג. global=7 דומיינים round‑robin.
- **עיקרון:** מנועים אגנוסטיים‑למקור (מקבלים pool כפרמטר) — לכן מיגרציית‑הדאטה לא נגעה בהם.

## 9. ניהול‑מצב (Riverpod)
269 providers. StateNotifier למצב‑מורכב (cart·studio·auth) · Provider ל‑derived (roleProvider·currentUidProvider) · StreamProvider ל‑Firestore (via FirestoreCachedRepo). `featureFlagsProvider` (env + _forcedOnFlags + runtime enable()) שולט על כל הגידור.

## 10. Server Functions (10 callables)
`askClaude` (proxy Claude · Secret‑Manager · rate‑limit · haiku‑4.5) · `setRole` · `reviewRoleRequest` · `deleteAccount` (Apple) · `computeCredit` · `advanceOrderStage` · `onChatMessageCreated` (trigger ✓✓+push) · `getUploadUrl` · `publishConfig` · `rollupAnalyticsDaily`.

## 11. אבטחה
- Rules: deny‑by‑default · isSignedIn/isAdmin · per‑owner (uid) · per‑store (inventory←store.ownerUid).
- App Check פעיל · ANTHROPIC_API_KEY ב‑Secret Manager · service‑account כ‑CI‑secret (לא ב‑git).
- Auth: Google/מייל/טלפון/אנונימי · תפקידים מ‑custom‑claims. ⚠️ RBAC מפוזר → SPEC-user-system U1.
- פערים (חוסמי‑השקה): מערך‑משתמשים (directory/store‑ownership U3) · admin/5555 להסרה · keystore.

## 12. CI/CD (13 workflows)
android‑package (AAB+APK·שער‑טסטים) · android‑test‑build (APK, backend+Claude ON) · android‑google/emulator‑test · web‑deploy · firebase‑hosting/preview‑backend/deploy · seed‑catalog · catalog‑qa · bootstrap‑admin · protocol‑enforce · deploy. גידור‑דגלים per‑target.

## 13. מצב‑פרויקט + Roadmap
- ✅ **הושלם‑ואומת:** מנוע‑הזמנות · 5 פרסונות · 4 מאתרים · מקלדת · חיפוש‑על · Studio · Claude‑חי · **קטלוג→שרת (C1‑C5, CI‑ירוק, רדום)**.
- 🔲 **הבא:** מערך‑משתמשים (U0‑U5).
- **חוסמי‑השקה:** U3 (חנות↔בעלים) · U5.2 (מחיקת‑UI) · keystore · admin/5555 · Google‑OAuth ל‑web.

## 14. הערכה הנדסית (למתכנת)
**חזק:** משמעת‑גידור (byte‑identical dormancy) · Repository עקבי · מנועים אגנוסטיים‑למקור · כיסוי‑טסטים ~4,700 (חוק‑ברזל full‑suite) · strangler נקי · מנועי‑חיפוש/צלילה מתוחכמים אמיתית.

**דק / לתשומת‑לב:** מערך‑המשתמשים (directory/RBAC/store‑ownership) — תשתית קיימת אך לא‑שלמה, חוסמת את שכבת‑החנויות בייצור · backend דלוק רק ב‑APK (web=demo) — טרם הוכח תחת‑עומס · finance/site tools של הקבלן = proto · admin/5555 demo‑login.
