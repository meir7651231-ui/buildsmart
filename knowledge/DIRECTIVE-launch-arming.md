# הנחיה: הדלקת-השקה — לזרוע את הבנוי-אבל-דורמנטי, נכון

> **אושר ע"י הבעלים** (2/8: "להדליק הכל במקום הנכון").
> **ביצוע:** `claude/whats-happening-LyY9G` · הצי · **אודיט→הדלק-בקבוצות→אמת→עצור-לדיווח.**
> ⚠️ **לא הדלקה-עיוורת.** זו ההדלקה-המכוונת (ההפך מ-default-off): כל דגל **מאומת-שלם + non-owner-safe + toggle-matrix ירוק** לפני שמדליקים.

---

## 2 ה"מקומות הנכונים" (מאומת בקוד)
1. **דגלי-קומפילציה** (`bool.fromEnvironment`) → מוזרמים ב-`--dart-define` בבנייה-החיה (`web-deploy.yml` / `vars.STUDIO_DART_DEFINES`).
2. **טוגלי org-config** (`featEnabled(ref,'module','feature')`) → נדלקים ב-**OrgConfig של חברת-ההשקה** (BuildSmart) — **ורק אם `ORG_CONFIG` דלוק** (שכבת-הריצה). **פה נדלקים ה-CRM/ייבוא/מסמכים** (`manager.customers` וכו').

## מטריצת-ההדלקה (הצי מאמת כל שורה לפני)
### ✅ להדליק (מוכן-להשקה)
- **כבר דלוק:** finders (word/ring/plain/axis) · keyboard (KB_GLOBAL/mirror) · GLOBAL_SEARCH · STORE_COMPARISON_UI · USE_FIREBASE_BACKEND · STUDIO_SHARED_SYNC · **ORDER_EMAIL** (הופעל 2/8) · **STUDIO** (owner-gated).
- **לארם (קומפילציה):** `ORG_CONFIG` (שכבת-הקונפיג — תנאי לכל השאר) · `USER_SYSTEM` (RBAC) · `UID_SCOPED_QUERIES`/`ORG_SCOPED_QUERIES` (בידוד-דייר) · `SERVER_CALLABLES` (אם ה-functions פרוסות) · `CATALOG_SERVER_SEARCH`.
- **לארם (org-config של BuildSmart):** `manager.customers` (**CRM/לקוחות**) · **ייבוא-לקוחות** · **מסמכים** (חשבונית/קבלה/תעודת-משלוח על מסילת-ההדפסה) · שאר הטוגלים-שהושלמו.

### 🟡 דורש-בעלים (לא לארם עד שהבעלים מספק)
- `CLOUD_PHOTOS` (מפתחות-R2) · `APP_CHECK_PROD` (רישום-מפתחות בקונסול).

### 🔴 אל תארם (מסוכן/debug)
- **`SEED_FRESH_BACKEND`** (זורע/מוחק דאטה — **סכנה**) · **`FS_DIAG`** (debug) · `SEED_*` כלשהו.

### ⏳ לא-מוכן (מחכה לשרת)
- **`store_documents_sheet`** (חשבוניות-ספק/דוח-חודשי) — דורש **שרת-חיוב**; להשאיר במצב-"יחובר-עם-שרת" עד שיעלה.

## סדר (בקבוצות · עצור-לדיווח)
1. **ORG_CONFIG + backend** (השכבה — תנאי לשאר) → אמת non-owner זהה-בייטים.
2. **org-config של BuildSmart:** הדלק CRM/לקוחות + ייבוא + מסמכים → אמת שמופיעים ועובדים.
3. **USER_SYSTEM + scoped-queries** (RBAC/בידוד) → אמת בידוד-דייר.
4. שאר-המוכנים אחד-אחד.
- כל קבוצה: **byte-verify · toggle-matrix · central-verify ירוק · non-owner לא-מושפע-לרעה.**

## 🛡️ בטיחות
- **non-owner** ממשיך לראות אתר-תקין (הדלקה = פיצ'רים-אמיתיים, לא באגים).
- debug/dangerous **נשארים כבויים.**
- כל הדלקה **הפיכה** (דגל) · `toggle-matrix` מתרחב.

## DoD
כל הפיצ'רים-הבנויים-המוכנים **דלוקים במקום-הנכון** (קומפילציה + org-config) על החי · CRM/ייבוא/מסמכים **מופיעים ועובדים** · debug/dangerous כבויים · owner-pending מסומנים לבעלים · non-owner זהה-חוויה-תקינה · שער ירוק.

## פעולות-בעלים
R2-keys (`CLOUD_PHOTOS`) · App-Check registration (`APP_CHECK_PROD`) · אישור שחברת-ההשקה = BuildSmart (איזה OrgConfig).
