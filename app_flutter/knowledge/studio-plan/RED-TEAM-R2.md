# 🔬 Red-Team סבב-2 — קריעת התוכנית-המוקשחת (9 עדשות טריות) + מסקנה

> סבב-2 (אחרי תיקוני-R1) קרע את הגרסה-המתוקנת מ-9 עדשות חדשות: state-machine · runtime-perf ·
> owner-DX · error-recovery · data-integrity · test-strategy · UX-flows · deploy-ops · docs-coherence.
> ~50 ממצאים · **~20 HIGH.** מסמך זה = ממצאי-המפתח + ההכרעות. (R1 = `RED-TEAM-R1.md`.)

---

## 🔴 תמת-העל של סבב-2 (אישוש ע"י 4 עדשות: docs-coherence · state-machine · test-strategy · UX-flows)
**תיקוני-R1 היו appendix-בלבד.** הוספנו מקטע `🔧 תיקוני Red-Team R1` ל-5 העמודים + עדכנו את האב/GATE_REGISTRY — אבל **לא מיזגנו אותם לגוף-המסמכים, ל-5 קבצי-`steps/0N`, ול-1,000 תת-השלבים ב-`detail/`** — שזה מה שהבונה מבצע בפועל. לכן ה-spec-הביצועי עדיין מקודד את העיצוב-הישן-השבור:
- `steps/04` + `detail/069-085` + `steps/03` עדיין כל-אחד "gate **#118** → bump 119" (התנגשות שהאב כבר פתר ל-118/119/120).
- `steps/01` + `detail/001-015` עדיין `BoardRole` (בלי-קבלן) + `editDraft` (לא `applyOps`) + `ElementDescriptor` 3-שדות (לא 6).
- `steps/02` + `detail/031-050` עדיין step-38 "byte-identical" (לא answer-equivalent).
- `steps/03` + `detail/086-100` עדיין `privAnalytics==true` default-ON.
- האב §3-Phase-2 + `detail` עדיין "2,361 Text" (לא ~532).

➡️ **הכרעה #1 (חוסמת-בנייה):** לפני כל בנייה — **להפיץ את הכרעות-R1 לתוך כל קבצי ה-`steps/` וה-`detail/` והגופים** (sed/rewrite ממוקד), כך שהתוכנית תיקרא כ-spec-אחד-קוהרנטי. ה-appendices + האב + GATE_REGISTRY כבר נכונים — צריך רק להחיל אותם על העלים.

---

## ממצאי-HIGH חדשים (מעבר להפצה — דברים ש-R1 פספס)
**A. עיצוב/state-machine:**
1. **runtime invalidation O(live-wrappers):** `resolvedNodeProvider` צופה ב-doc-השלם → כל wrapper מתחשב בכל-keystroke/publish; טענת-§11 "fine-grained" **שקרית**; ה-`select` לא-מימושי ל-family לפי-id-שרירותי. → restructure ל-per-id select (3 layer-slices).
2. **previewDraft = re-resolve-מסך-מלא לכל-תו** → debounce + נתק TextField-מקומי מה-doc עד commit.
3. **edit-mode = 150+ gesture-arenas + CustomPaint repaints/frame** → overlay-hit-test יחיד + RepaintBoundary.
4. **מפתח-פרסונה כפול:** contractor = `'contractor'` או `null` בלי-canonical → split-write. → `roleKeyOf(null)=='contractor'` קנוני, לאסור null-key.
5. **CfgStyle/CfgAction merge = whole-unit overwrite** → draft שמשנה fontScale מפיל colorToken מ-published. → field-level merge.

**B. אמינות/קיום:**
6. **publish = LWW בלי expectedVersion** (M1 נדחה אבל לא-מומש) → שני-מנהלים דורסים. → CAS עם expectedBaseVersion בטרנזקציה.
7. **ingestion-failure לא-מוגדר בצד-client:** checksum-mismatch · `migrate()`/`fromJson` throw מ-bricks-קונפיג-שלם · schema-חדש-על-client-ישן. → keep-last-good + retry + "עדכן אפליקציה".
8. **trade-publish לא-מתפזר:** `Trade.published` נכתב רק ל-`bs.trades.v1` מקומי → "חשמלאי" מופיע רק אצל הבעלים, ואין-listener mid-session. → לנתב trade-publish דרך `publishConfig`/pointer + reactive provider.
9. **bulk-import בלי-rollback-mid-batch** → קטלוג-חצי-ציבורי. → stage-to-pending, flip-on-full-success.

**C. שלמות-נתונים/אבטחה:**
10. **אין FK-validation** על `categoryId`/`tradeId`/`aTypeId` → רפרנסים-תלויים. → publish-time + onWrite referential-validator.
11. **gate-118 uniqueness עיוור ל-runtime-domain-ids** (סורק רק const) → התנגשות-id לא-נתפסת. → assertion ב-runtime על ה-provider-המאוחד + namespace-prefix.
12. **join-לקוחות לפי displayName** (`byBuyer[o.who]`) → שני-לקוחות-שם-זהה מתמזגים, double-count. → join לפי uid/actorKey.
13. **publish-לכולם בלי אישור-היקף** (discard כן מאשר!) + M4 preview-as-user לא-נחת כשלב. → confirm-sheet "ישפיע על כל המשתמשים" + view-as-persona.

**D. בדיקות/deploy:**
14. **keystone-fixtures דקות** (compat_50/full_compliance) לא-מכסות galvanic/Legionella/dielectric → engine-מוכלל יכול לסטות. + **G-newtrade בלי-CompletionRule-acceptance**. → לצנרר את full physics-suite + לאמת CompletionRule.
15. **validateSafe נבדק מול fake-registry של אותו-מחבר** (self-certifying) → ירוק-מובנה עד שה-P1-registry-אמיתי קפוא. → contract-test חובה fake↔real, fail-closed.
16. **indexes deploy=continue-on-error אבל functions נפרסים-ללא-תנאי** → token-indexer/rollup חי לפני האינדקס → FAILED_PRECONDITION. → לגדר functions על index-success.
17. **GA-lock flips ~12 דגלים בבת-אחת** → אין bisect. → רצף-תת-flips, כל-אחד deploy+soak.

---

## ✅ מה שמחזיק (אישוש סבב-2)
מסלול-הקונפיג end-to-end (edit→preview→publish→fan-out-pointer→rollback) · merge-precedence (default⊕global⊕persona⊕draft) נכון+unit-pinned · AI speak→confirm grounded · analytics↔Studio (route-keyed לא element-id) · flags-OFF אפס-עלות-frame · sparse-storage O(edits) · GATE_REGISTRY קנוני · 5 ה-appendices עקביים זה-עם-זה.

---

## פסק-דין סבב-2
הקריעה **התכנסה**: הממצא-הדומיננטי הוא **"החל את תיקוני-R1 כראוי על העלים"** (משימת-תיקון, לא גילוי-חדש) + חבילת-הקשחה-חדשה ממוקדת (17 פריטים מעל). שני סבבי-Red-Team על **תוכנית** (לא קוד) הם כיסוי יוצא-דופן. **המלצה:** לעצור את קמפיין-הקריעה (התשואה השולית יורדת — סבב-3 יחזור על "הפץ + הקשח"), ולעבור ל-**מעבר-הפצה+הקשחה אחד** שהופך את ה-spec לבר-בנייה, ואז להתחיל לבנות שלב-1. סבבים נוספים יניבו יותר ערך **על הקוד שייבנה** מאשר על המסמך.
