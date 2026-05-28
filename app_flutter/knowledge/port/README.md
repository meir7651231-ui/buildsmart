# port/ — ידע ההטמעה (מקור → Flutter)

תיקיית הידע למאמץ הטמעת ה-parity. מקור-האמת לתכנון הוא `../PARITY.md` (מפת-האב);
כאן יושב הידע המפורט: מה יש במקורות (פרוטוטייפ + Preact), ואיך מטמיעים כל תחום
ל-Flutter כ-dial (R2), verbatim (R6/R8).

## סקירות (overview)
| קובץ | מה מכיל |
|---|---|
| `prototype.md` | סקירת הפרוטוטייפ — אינדקס תחומים + תובנות-על |
| `preact.md` | סקירת Preact — מבנה-dial, נתונים, היסטוריה, R2 |
| `profile-rewards.md` | תחום E (Flutter port spec) — כרטיס-קבלן/דרגות/מועדון |

## ידע-עומק ממצה (5,211 שורות, מעוגן `[L#]`/`file:line`, verbatim)
### `proto/` — הפרוטוטייפ `/index.html` (ה"מה")
| קובץ | תחום |
|---|---|
| `proto/01-onboarding-shell-nav.md` | onboarding · splash/welcome/login/מקצוע · role-drawer · 5-טאבים · routing |
| `proto/02-catalog-product-model.md` | קטלוג · TREES (3 breeds) · VARIANTS · ATTR_SCHEMA · DIAGRAMS · ACC_* · pedagogy |
| `proto/03-commerce-b2b.md` | computeCheckout · ship-planner · RFQ/RMA/השכרה/פקדונות/MSDS · BULK/FX · אשראי · gov-XML · חתימה |
| `proto/04-contractor-projects-tasks.md` | בית · פרויקטים/אתרים · תקציב · מרכז-פיננסים(10) · site-hub(10) · משימות · smart-project · סריקה · מלאי |
| `proto/05-profile-hubs-settings-rbac.md` | כרטיס-קבלן · RANKS · הישגים · מועדון · AI/service hubs · הגדרות+applySettings · RBAC_MATRIX · i18n |
| `proto/06-personas-engine-selftest.md` | מנוע-SYS_ORDERS · 4 personas (חנות/שליח/עובד/מנהל) · BUTTON_REGISTRY(350) self-test |

### `preact/` — האפליקציה הקודמת `app/src/` (ה"איך תורגם ל-dial")
| קובץ | תחום |
|---|---|
| `preact/01-shell-dials-components-trees.md` | מעטפת · 5-FAB · 3 dials · SETTINGS_SUB(10/עומק4) · PROFILE_TREE · ~60 LEAF_BINDINGS · חיפוש-fuzzy · views |
| `preact/02-data-stores-history.md` | נתונים(catalog/variants/suppliers/tools/identity) · 7 stores · R1–R9 verbatim · ADRs · 43 ביקורות |

## שיטה (לכל מסמך-תחום מפורט תחת PARITY)
מקור (proto [L#] + Preact file:line) → סטטוס Flutter (✅/🟡/🔌/❌/⛔) → מבנה-dial להטמעה →
נתונים/helpers → קריטריוני קבלה. כל הטמעה: dial (R2) · verbatim (R6/R8) · helper+contract+test.

> **שימוש:** לתכנון-על → `../PARITY.md`. לדעת **מה** יש במקור ובאיזו שורה → `proto/`.
> לדעת **איך זה כבר תורגם ל-dial** (התבנית לחיקוי) → `preact/`. לתחום מוכן-ליישום → `profile-rewards.md`.
