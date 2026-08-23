# 🔬 Red-Team סבב-1 — קריעת תוכנית-הסטודיו (9 עדשות) + הכרעות-תיקון

> 9 סוכנים אדברסריים קרעו את כל התוכנית (אב + 5 עמודים + 100 שלבים + 1,000 תת-שלבים), כל אחד עדשה אחרת,
> 2026-06-23. **~30 HIGH · ~35 MED · ~25 LOW.** המנוע-המכני, אפס-הרגרסיה וקנה-המידה (קריאות) **מקורקעים היטב**;
> הסדקים האמיתיים: **תפר P1↔P4, over-claiming, פרטיות-default-ON, ופערי-שלמות (רב-מנהלים/גיבוי/rollout).**
> מסמך זה = הרשומה הסמכותית של הממצאים + מה משתנה בתוכנית. תפוצה ל-leaf-docs = בזמן-הבנייה.

---

## חמש תמות-על (אישוש-צולב בין עדשות)

### A. 🔴 תפר Pillar-1 ↔ Pillar-4 שבור (ארכיטקטורה #1/6/8 · AI #1-4 · קוהרנטיות #4/5)
התשתית (רישום + מודל-פרסונה + draft-API של P1) **תת-מוגדרת**, ו-P2/P3/P4 בונים עליה ערבויות שלא קיימות:
1. **רישום:** P4 מקרקע מול `editableProps`/`allowedActions`/`allowedValues`/`kImmutable`/`kRoleFloor`/`ElementKind` — אך `ElementDescriptor` של P1 = `axes`/`critical`/`personas` בלבד → `validateSafe` **ירוק-ריק (vacuous)**.
   **הכרעה:** P1 Phase-0 חייב להרחיב את `ElementDescriptor` לכל השדות הללו; חוזה-הרישום קפוא לפני שלב-30. fail-closed כשחסר.
2. **מודל-פרסונה שבור ל-3:** חי=`roleProvider` (String?, null=קבלן) · P1=`BoardRole` enum (**בלי קבלן**) · P4=`BsRole` enum. עריכה פר-קבלן לא-ניתנת-למיפתוח → "נשמר, כלום לא קורה".
   **הכרעה:** מקור-אמת-יחיד = `roleProvider` (String?, null=קבלן). כל שכבת-פרסונה ורצפת-תפקיד מפותחות לפיו; enums ממופים ב-adapter.
3. **draft-API לא-תואם:** P4 מצפה `draft.apply(List<ConfigOp>)`+`revertLast()`; P1 חושף `editDraft(id, CfgNode Fn)`.
   **הכרעה:** P1 מוסיף API מבוסס-op (`applyOps`+undo-stack); `editDraft` נשאר primitive פנימי.

### B. 🟠 Over-claiming — להחליף טענות שקריות בכנות (אפס-רגרסיה · ארכיטקטורה · מאמץ)
4. **"byte-identical" שגוי** — `kCatalogProducts` הוא `final` (אין בייטים); תאימות=לוגיקת-galvanic לא זוגות; `CompatibilityRule` בלי שדה-material-family → לא ישחזר HDPE↔PVC.
   **הכרעה:** בכל מקום → **"answer-equivalent מול fixtures קיימים"** (`compat_50_samples`/`full_compliance_audit`/`catalog_regression`). למחוק "byte-identical".
5. **פיזיקת-אינסטלציה היא לוגיקה-מותנית** (if-חם · dissimilar · recirc · isolation-count), לא דאטה שטוחה.
   **הכרעה:** ענף-`'plumbing'` הקשיח **נשאר חי לנצח**; רק תחומים-חדשים משתמשים ב-`CompletionRule`/`CompatibilityRule` authored. למחוק "seeded verbatim".
6. **"2,361 Text" מנופח ×4** — רק ~532 הם `Text('ליטרל')`; 721 הם `const Text` (אימוץ הורס const → rebuilds); השאר מחושב/interpolated/`Text.rich` (אין fallback).
   **הכרעה:** ציר-תוכן-v1 = ~532 הליטרלים בלבד; מחושב/interpolated = templating נפרד (out-of-v1). לתעד const-loss + מדד-ביצועים.
7. **`CfgText` מפיל `maxLines`/`overflow`/`textAlign`/`softWrap`** → רגרסיות-חיתוך/יישור גם ב-OFF.
   **הכרעה:** העוטפן חייב להעביר את **כל** פרמטרי-ה-`Text` + לשמר composition.
8. **`nav.screen` לא יכול לבנות 11/49 מסכים עם typed-args.**
   **הכרעה:** `nav.screen` מוגבל ל-~38 מסכי-no-arg; typed-arg דורש arg-builders פר-מסך (out-of-v1). להצהיר במפורש.
9. **"100 שלבים שווים" = בדיה** — 5 ענקים (29/37-38/49/63/82-84) הם 3–25 commits כל-אחד; ריאלי ~**150–180 commits**.
   **הכרעה:** "100" = **task-taxonomy**, לא effort-estimate. לפצל את 5 הענקים ל-sub-commits מתועדים; הכותרת תצהיר זאת.

### C. 🔴 בטיחות-פרסום ופרטיות (ממשל #1-5 · AI #2 · קנה-מידה)
10. **publish מאמת רק auth+טרנזקציה, לא תוכן-diff** → `validateSafe` client-only ועקיף.
    **הכרעה:** `publishConfig` **מריץ מחדש את כל validateSafe בשרת** (role-floor · action-legality · critical-lock · contrast · batch-ceiling). client = advisory.
11. **פרטיות forward default ON** (`privAnalytics:true`, absent=true) + presence = מעקב-בשם.
    **הכרעה:** `privAnalytics` default **false** + opt-in מפורש; gate קורא `consentedPolicyVersion >= current`; `privPresence` **נפרד default-OFF** + TTL קצר + בסיס-חוקי מתועד. presence-read מוגבל ל-actors-לקוחות, לא צוות.
12. **manager-claim = publish-לכולם בלי dual-control** (supply-chain-in-app) · `catalogProducts` חושף price למתחרים · erasure מפספס presence/displayName.
    **הכרעה:** `publishConfig` דורש `isOwnerEmail` או dual-control + rate-limit + revert-SLA; price בשדה role-scoped; erasure על `actorKey`+`uid`+presence (עם טסט-שלמות).

### D. 🟠 קנה-מידה: עלות אופטימית (לא קליף-ארכיטקטוני)
13. **egress הושמט** (~$0.66/פרסום gzip ב-3MB×5K) · **תדירות-פרסום לא-חסומה** (10–50/יום → $6–33/יום) · **presence-listener = read-storm** ($11/משמרת) · אנליטיקה ~$144/חודש בקצה-עליון.
    **הכרעה:** להוסיף **מעקות:** publish-budget/coalescing + rate-limit על `publishConfig` · presence דרך `presenceSummary` מגולגל-שרת (לא listener על כל-המחוברים) · טבלת-$/חודש (low/high) + Cloud-Billing-cap קשיח. parity-חיפוש: tokenize nameHe-בלבד (או לשדרג ranker), למחוק "identical".

### E. 🟡 פערי-שלמות (העדשה ה-8) — להוסיף שלבים חסרים
14. **עריכה רב-מנהלים בלי concurrency** → publish של מנהל-א דורס את מנהל-ב לכל-המשתמשים.
    **הכרעה:** publish עם **compare-and-set (expected-version)** + "מנהל אחר עורך" detection.
15. **אין ייצוא/ייבוא/גיבוי** של הקונפיג/התחומים (כל העסק בדוק-Firestore, ring-30 בלבד).
    **הכרעה:** שלב חדש — export/import JSON מלא + restore-from-file.
16. **מחיקת-תחום/מוצר משאירה יתומים** (overrides · rules · search-index · orders/carts).
    **הכרעה:** מודל tombstone/archive + ניקוי-fan-out + migrate-map ל-id שנמחק.
17. **אין rollout-מדורג / preview-כמשתמש-אמיתי** — publish ל-100% תוך 2ש'.
    **הכרעה:** שלב — canary/אחוזים + "צפה כפי שקבלן/שליח יראה" לפני שידור.
18. **MED נוספים:** trade-schema `migrate()` · edit-mode perf-gate על מסכים-צפופים · onboarding לבעלים · undo first-class (tree/find-replace/theme) · E2E חוצה-עמודים + UAT · a11y לקונכיית-הסטודיו עצמה · אובזרבביליות לשימוש-בסטודיו · i18n/bidi של תוכן-authored (או להצהיר Hebrew-only).

---

## תיקוני-gate (קונקרטי, מיידי)
- **התנגשות gate-118** (P1/P3/P4 כולם תפסו 118; האב וה-100-steps ממפים הפוך).
  **הכרעה אחידה:** **118 = P1 config-registry (`id ⊆ registry`)** · **119 = P4 AI-grounded-config** · **120 = P3 analytics-PII**. לרשום מראש 3 שורות ב-`GATE_REGISTRY.md`. להפיץ ל-leaf-docs בבנייה.

## ✅ מה מחזיק (אל תיגע — מאומת ע"י הנחיל)
דגל-קומפילציה OFF=byte-identical (8× מאומת) · pointer+sharded-snapshot = חיסכון-קריאות ×5000 אמיתי · 1MiB-ceiling+shards · auto-id-scatter+cursor-pagination · catalog-לא-collection (paged) · anti-hallucination **parse**-layer (closed-set→drop) · forward-compat ל-clients-ישנים · malformed-tolerance · privacy-gate-86 קיים · erasure-בסיס · critical/nav/auth-lock · audit append-only · `setRole` admin-only.

---

## פסק-דין
התוכנית **מצוינת כ-taxonomy ומקורקעת בקוד**, אך **לא מוכנה-לבנייה כמות-שהיא**: חובה (1) להקשיח את תשתית-P1 (רישום-מורחב + מודל-פרסונה-יחיד + draft-op-API) **לפני** הקפאת-ה-seams · (2) להזיז את כל אכיפת-הבטיחות לשרת · (3) להחליף over-claims בטענות-כנות · (4) להוסיף ~12 שלבים-חסרים (concurrency/גיבוי/archive/rollout/onboarding/undo/E2E) · (5) מעקות-עלות + פרטיות-default-deny. **אומדן ריאלי ~150–180 commits.** סבב-2 (9 עדשות טריות) יקרע את הגרסה-המתוקנת.
