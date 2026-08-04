// 🎛️ דגל ה-CATALOG-CONFIG (הקטלוג-המגדיר) — **default-OFF** ⇒ כל graph של
// `features/catalog_config/` tree-shaken מ-build-הפרודקשן עד להדלקה מפורשת.
// שער #128 (GATE_REGISTRY). הפעלה: `--dart-define=CATALOG_CONFIG=true`.
//
// הפיצ'ר: כרטיס-הגדרה גנרי דאטה-מונחה (תמונה + גלגלים פר-מוצר) — `CATALOG-CONFIG-
// PLAN.md`. OFF ⇒ אפס-נגיעה בקטלוג החי · הדלקה-חיה = החלטת-בעלים מפורשת.

const bool kCatalogConfig = bool.fromEnvironment('CATALOG_CONFIG');
