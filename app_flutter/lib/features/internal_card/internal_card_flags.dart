// 🎛️ דגל ה-INTERNAL-CARD (הכרטיס-הפנימי המלא · "המנוע חשוף").
// הכרטיס מרנדר 13 סקציות נתונים למוצר-אביזר (card-max-internal), כל סקציה מחווטת
// לפונקציית-מנוע קיימת (variantSiblingsOf · compatibleProductsFor · engineeringSpecFor
// · complianceTriggersFor · installKitFor · priceFor). ברירת-מחדל OFF ⇒ tree-shaken ⇒
// בייט-זהה ל-live עד שמדליקים. SSOT: app_flutter/knowledge/internal-card/WIRING-SSOT.md.
const bool kInternalCard = bool.fromEnvironment('INTERNAL_CARD');
