# 🏗️ BuildSmart Studio — תוכנית-הבנייה ב-100 שלבים (1→100, לא 99)

> 🚨 **100 = טקסונומיית-משימות, לא אומדן-מאמץ/commits. ריאלי ≈ 150–180 commits.** (Red-Team B9.)
> 5 השלבים המסומנים `⚠️ אפי` למטה מתפצלים כל-אחד למספר sub-commits; ראה `studio-plan/RED-TEAM-R1.md`.

> פירוק מוסכם של `STUDIO-BUILD-PLAN.md` ל-**בדיוק 100 שלבים** ע"י נחיל-פירוק (5 סוכנים, 2026-06-23),
> כל אחד מקורקע ב-file:line. הפירוט המלא לכל בלוק: `studio-plan/steps/0N-steps.md`.
> כל שלב: מגודר (`kStudio*`/`kMgr*` default OFF) · אפס-רגרסיה · עובר 100-שערים (analyze 0 + suite) · עברית/RTL/a11y · ממשל-#84 · server-ready.
>
> **ספירה:** 30 (1–30) + 20 (31–50) + 18 (51–68) + 17 (69–85) + 15 (86–100) = **100** ✓

---

## 🟢 פאזה 0–2 · יסוד + סטודיו + כיסוי-תוכן  [עמוד-1 · שלבים 1–30]
*פירוט: `studio-plan/steps/01-steps.md` · `studio-plan/01-config-engine-studio.md`*

**יסוד (data-model → store → wrappers → edit-mode → registry):**
1. `CfgNode`/`CfgStyle`/`CfgAction` value-objects + JSON סובלני
2. `ConfigDoc`/`ConfigLayer`/`ConfigVersion` + `schemaVersion` + `migrate()`
3. `mergeNode` טהור (default ⊕ published ⊕ persona ⊕ draft)
4. const `kStudioFlag` + שם-דגל-ריצה
5. רישום שם-הדגל ל-staging-בעלים בלי-rebuild
6. `ConfigStore` notifier + `ConfigSink`/`LocalPrefsSink` + editDraft/publish/rollback
7. `resolvedNodeProvider` family (פרסונת-צופה + edit-preview)
8. `EditModeController` גדור לבעלים+מנהל+דגל
9. `EditHandle.maybe(...)` + popover-עריכה-במקום
10. עוטפן-תוכן `CfgText(id, fallback)` (אמוג'י + style + Semantics)
11. עוטפנים `CfgVisible`/`CfgList`/`CfgBox`/`CfgAction`
12. `ElementDescriptor` + `kElementRegistry` const + provider
13. הזרקת `StudioOverlay` פעם-אחת ל-`main.dart`
14. אימוץ ~10 ids-פיילוט + שורות-רישום (כותרות-KPI + CTA-עגלה)
15. `zero_regression_test` + `cfg_wrappers_test`

**קונכיית-הסטודיו (טיוטה/פרסום/גרסאות):**
16. שלד `studio_screen` + panes (IndexedStack) + chrome-לבן-RTL
17. סרגל-עליון (badge-טיוטה · פרסם · בטל · toggle-עריכה) + שדה-הערת-פרסום inline
18. Pane-A עץ (registry-driven, וירטואלי) + בורר-פרסונה + חיפוש
19. Pane-B מפקח (R9 inline per-axis + תצוגה-חיה + reset + diff)
20. שורת-מנהל "🎨 סטודיו" + toggle-עריכה מאחורי `kStudioFlag`
21. Pane-D היסטוריית-גרסאות + diff + "שחזר" בלחיצה
22. `config_store_test` + `registry_contract_test` + שער-118

**עיצוב + בטיחות + אימוץ:**
23. override `CfgTheme` + glue ל-`ThemeExtension`
24. Pane-C עורך-ערכת-נושא (תצוגה-חיה כלל-אפליקציה + חסימת-ניגודיות AA)
25. Pane-D חיפוש-והחלפה גלובלי על תוכן → טיוטה
26. סט-ids-קריטיים + ולידטור-פרסום (אי-אפשר להסתיר קריטי)
27. reset-3-scopes + whitelist-התנהגות + ולידציה-בכתיבה
28. חבילת-בטיחות (קריטי-לא-נסתר · tokens חסומים · ניגודיות · reset)
29. פריסת-אימוץ-תוכן מסך-מסך + codemod לחילוץ-רישום  ⚠️ אפי — מפוצל ל-N sub-commits (אימוץ ~532 ליטרלים, רב-commits)
30. הקפאת 4 ה-seams לעמודים + עדכון ידע (WIRING/GATE/MAP)

## 🟡 פאזה 3 · בונה-התחומים ("חשמלאי מחר")  [עמוד-2 · שלבים 31–50]
*פירוט: `studio-plan/steps/02-steps.md` · `studio-plan/02-domain-vertical-builder.md`*

31. 3 דגלים default-OFF + const-helpers
32. סכמת trade/category/attribute/product/accessory/fixture
33. סכמת-חיבור (מטריצה-authored במקום enum-סגור)
34. חנות-תחומים-authored (deltas בלבד, SharedPreferences)
35. adapter `TradeProduct.toLegacy()`→`LipskeyCatalogProduct`
36. גנרטור: consts → מסמך-תחום-אינסטלציה + קטגוריות/מוצרים
37. commit ל-seed כולל `CompatibilityRules` מ-891 ה-specs  ⚠️ אפי — מפוצל ל-N sub-commits (גזירת-891 + seed)
38. **🔑 אבן-פינה — assert seed ≡ const answer-equivalent מול fixtures קיימים** (`compat_50_samples`/`catalog_regression`)  ⚠️ אפי — מפוצל ל-N sub-commits (answer-equivalent seed)
39. מנוע תחום-אגנוסטי טהור: canConnect/completion/coherence
40. parity-resolver — מנוע על-המטריצה מול התשובות-הישנות
41. עטיפת-מנוע מאחורי דגל, ענף-אינסטלציה נשמר
42. `tradeId` ל-repo reads, default 'plumbing'=seed
43. `activeTradeProvider` (בורר נסתר כש-count==1)
44. כניסת-מנהל גדורה + רשימת-תחומים + הגדרת-תחום (טיוטה)
45. עורכי עץ-קטגוריות + סכמת-תכונות
46. עורכי מוצרים + אביזרים
47. סטודיו חוקי-חיבור + גיליון-פרסום
48. ייבוא: תבנית + מיפוי-עמודות + dry-run + commit גדור
49. הפשטת פיזיקת-install-studio + brand-ladders ב-seams גדורים  ⚠️ אפי — מפוצל ל-N sub-commits (refactor install-studio + brand-ladders)
50. **✅ קבלת "חשמלאי" מקצה-לקצה — קטלוג+סטודיו עובדים**

## 🟡 פאזה 4 · קנה-מידה + שרת + פרסום-לכולם  [עמוד-5 · שלבים 51–68]
*פירוט: `studio-plan/steps/05-steps.md` · `studio-plan/05-scale-data-backend.md`*

51. דגלי `kCatalogServerSearch`/`kStudioLive`/`kCatalogBaseUrl` + docs
52. תיעוד 4 collections + 8 indexes
53. `PagedQuery<T>` cursor-helper מעל ה-seam
54. seam `StudioConfigRepository` (abstract + local + firebase)
55. `ConfigSink` Firestore דרך cache-base born-seeded
56. callable `publishConfig` (מנהל-בלבד, טרנזקציוני, audited)
57. trigger `revertIllegalConfigWrite` על published
58. listener publish-pointer יחיד + diff-גרסה
59. משיכת-shards לפי ref + checksum + swap אטומי
60. collection `catalogProducts/{sku}` + browse מדף
61. importer-seed default-OFF לקטלוג + עץ-bundled
62. seam `SearchRepository`; local עוטף `fuzzySearchProducts` verbatim
63. חיפוש-שרת + `onCatalogProductWrite` token-indexer  ⚠️ אפי — מפוצל ל-N sub-commits (חיפוש-שרת + indexer + parity)
64. data-cache מדף-קטלוג + `CATALOG_BASE_URL` (תאום דפוס-התמונות)
65. בלוקי-rules §5: owner-write/world-read config+catalog, analytics append-only
66. מעקות-עלות: `maxInstances:10` + מונים-מבוזרים + rollup יומי
67. repos analytics/presence write-only + buffering-offline
68. flip-פאזה-3 + חבילת-שערי-אפס-רגרסיה מלאה

## 🔵 פאזה 5 · עורך-AI + בונה-התנהגות  [עמוד-4 · שלבים 69–85]
*פירוט: `studio-plan/steps/04-steps.md` · `studio-plan/04-ai-coeditor-behavior.md`*

69. משפחת `ConfigOp` סגורה + JSON
70. `ElementRegistry` מזויף + ממשק-שאילתה קפוא (לבדיקות)
71. matchers סגורי-סט (exact→longest, null-on-miss)
72. קטלוג-פעולות סטטי על `route()`s + `open*Sheet`s אמיתיים
73. מחסן-רכיבים סטטי + סכמות-prop-נדרשות
74. בונה-prompt מקורקע (סטים-סגורים + דקדוק-JSON)
75. `parseConfigEdit` TOTAL — מאמת **כל שדה**, זורק מומצא
76. הרחבת `scope` סגור ל-ids קונקרטיים מהרישום
77. `validateSafe` — אי-שינוי ניווט/התחברות + חוקיות
78. רצפת-נראות-פרסונה + תקרת-batch (סיבות עברית)
79. `summarizeDiff` — preview עברית (broadcast/blocked)
80. דגל `kStudioCoEditor` + provider (enabled × ai)
81. כניסת-hero מנהל-בלבד + shell + off-states
82. בונה-ידני בלי-מודל: אלמנט→prop/visibility/component/action→preview→confirm→undo  ⚠️ אפי 82–84 — מפוצל ל-N sub-commits (3 מסכי-מנהל)
83. חיווט pane-NL: `gateway.ask`→parse→safe→preview→confirm + off-state כן
84. מודל-חוקים סגור + `parseRule` + מסך-חוקים ידני/NL
85. שער-#118 + נעיצות-injection + audit-#84 + עדכון-docs

## 🔵 פאזה 6 · מודיעין-לקוחות חי + נעילת-GA  [עמוד-3 · שלבים 86–100]
*פירוט: `studio-plan/steps/03-steps.md` · `studio-plan/03-live-customer-intelligence.md`*

86. **עדכון מדיניות-פרטיות** (חושף אנליטיקה-גדורה — תנאי-סף)
87. רישום `IntelEvents` + record `IntelEvent`
88. `IntelLogNotifier` ring-buffer (~1000, newest-first)
89. `IntelBus` seam חד-שורתי (local + telemetry + sink-inert)
90. `IntelSink` גדור-הסכמה + batched flush + requeue
91. `actorKey` אנונימי-יציב (uuid per-install) + stitch-התחברות
92. `screen_view` דרך RouteObserver + listener-לשוניות
93. אירועי-קטלוג (search/no-result/view/cart)
94. אירועי-funnel-חנות (cart/checkout-start/step)
95. detectors דטרמיניסטיים: funnel + stuck/abandon/dead-end
96. segments + retention-cohorts טהורים
97. tracker-session + נוכחות-heartbeat (clone `connection_status`)
98. providers-מנהל + לשונית-5 `_IntelTab` (עברית/RTL)
99. ציר-מסע פר-לקוח + שער-פרטיות 118 + WIRING/docs
100. **🏁 נעילת-GA כלל-פלטפורמה — flip-forward ON + שער-מלא + APK-flags-ON + אישור-בעלים פר-מודול + docs ("מאה, לא 99")**

---

## הערות-איחוד
- **התנגשות-שערים:** עמודים 1/3/4 כל-אחד תפס "gate 118" (כולם רואים GATE_REGISTRY אחרון=117). **הקצאה-בפועל לפי-סדר-משלוח:** 118=config-registry (ע1) · 119=AI-grounded-config (ע4) · 120=analytics-PII (ע3).
- **תלות-מפתח:** עמוד-1 (1–30) הוא היסוד — 31–100 נבנים עליו (רישום + עץ-קונפיג + seams). עמוד-5 (51–68) הוא שכבת-הקיום שמשרתת את כולם.
- **תנאי-סף לפאזה-6:** שלב-86 (פרטיות) חייב לפני הפעלת-אנליטיקה.
- כל שלב = commit עצמאי, גדור, אפס-רגרסיה, עובר-שערים, ניתן-למשלוח.

---

## ➕ שלבים-חסרים (Red-Team R1) — להשתלב בפאזות

> 12 שלבים שהעדשה ה-8 (פערי-שלמות) + תמות C/E חשפו כחסרים מ-100 הבסיס. **תוספתי** ל-100 (לא מחליף),
> משולב לתוך הפאזה היעד. מקור: `studio-plan/RED-TEAM-R1.md` §E + תיקוני-gate. ספירת-הבסיס נשארת **בדיוק 100**.

| # | שלב חסר | פאזה-יעד | מקור Red-Team |
|---|---------|----------|---------------|
| **M1** | concurrency: publish עם compare-and-set (expected-version) + "מנהל אחר עורך" detection | פאזה-4 (P5, סביב 56–58) | E#14 |
| **M2** | export/import/backup JSON מלא + restore-from-file של קונפיג/תחומים | פאזה-1 (P1) | E#15 |
| **M3** | archive + ניקוי-יתומים (orphan-cleanup) של תחום/מוצר — tombstone + fan-out + migrate-map | פאזה-2 + פאזה-4 (P2/P5) | E#16 |
| **M4** | staged-rollout (canary/אחוזים) + preview-כמשתמש-אמיתי לפני שידור | פאזה-4 (P5) | E#17 |
| **M5** | `Trade.schemaVersion` + `migrate()` לתחומים-authored | פאזה-3 (P2) | E#18 |
| **M6** | edit-mode perf-gate על מסך-צפוף (תקציב-rebuild) | פאזה-1 (P1) | E#18 |
| **M7** | onboarding/first-run לבעלים (היכרות עם הסטודיו) | פאזה-1 (P1) | E#18 |
| **M8** | undo first-class — tree / find-replace / theme | פאזה-1 (P1) | E#18 |
| **M9** | E2E חוצה-עמודים + UAT-בעלים | פאזה-6 / שלב-100 | E#18 |
| **M10** | a11y לקונכיית-הסטודיו עצמה (RTL/textScaler/contrast למסכי-הניהול) | פאזה-1 (P1) | E#18 |
| **M11** | אובזרבביליות-שימוש-בסטודיו (telemetry על פעולות-עריכה/פרסום) | פאזה-3 (P3) | E#18 |
| **M12** | i18n/bidi של תוכן-authored — או הצהרת **Hebrew-only** מפורשת | פאזה-1 (P1) | E#18 |
