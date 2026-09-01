// ⚛️ אטום-Dart (דרגת-חוזה) · isNavStructural
// תפקיד: האם אלמנט-סטודיו הוא מבני-ניווט — אזור 'nav', או מסוג-מיכל (container).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:213-225 (‏_isNavStructural; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
//        · הקריאה-לשדה d.area (מטיפוס-השכן ElementDescriptor הגדול) קופלה לשקע-מחרוזת `area` (חוק-3).
//        · ההשוואה d.kind == ElementKind.container קופלה לשקע-bool `isContainer` — קיפול השוואת-enum-השכן
//          (חוק-3); ElementKind/ElementDescriptor לא-inline. פרטי-במקור (`_`) ⇒ פורסם public.
//
// קלט:  area        — שקע: אזור-האלמנט (במקור d.area).
//        isContainer — שקע: האם d.kind == ElementKind.container (השוואת-enum מקופלת).
// פלט:  bool — area == 'nav' || isContainer.

/// True iff the studio element is nav-structural (a nav-area element or a container).
/// Verbatim of edit_safety.dart:213-225 with the area field and the kind-enum
/// comparison injected as sockets (law-3).
bool isNavStructural({required String area, required bool isContainer}) =>
    area == 'nav' || isContainer;
