// 🎛️ דגל ה-CATALOG-CONFIG (הקטלוג-המגדיר). ⚠️ מקטע-הבית מרנדר את `CatalogConfigScreen`
// **חי, ללא-תנאי** (החלטת-בעלים "תדליק"), אז `features/catalog_config/` כבר **לא**
// tree-shaken — הפיצ'ר חי בכל build. הדגל נותר **default-OFF** רק על **הראוט העצמאי**
// (`CatalogConfigScreen.route`) + שער #128 (GATE_REGISTRY).
// הפיצ'ר: כרטיס-הגדרה גנרי דאטה-מונחה (תמונה + גלגלים פר-מוצר) — `CATALOG-CONFIG-PLAN.md`.

const bool kCatalogConfig = bool.fromEnvironment('CATALOG_CONFIG');
