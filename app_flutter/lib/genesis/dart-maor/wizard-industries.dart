// חוט · wizard-industries — תחומי-העסק לאשף מתוך חבילות-הוורטיקל (פורט-Dart ידני).
// זהה-ביט ל-new/atoms/wizard-industries.mjs: map⇒אובייקטים-חדשים בני-4-שדות
// בסדר-המקור (id·emoji·label·sub — סדר-מפתחות-הכנסה, אין דמויי-שלם); שדה-חסר ⇒
// ‏null ≡ undefined-בערך (קונבנציית-הריפו). שקע: packs (חוק-1 — אפס import פנימי).
List<Map<String, dynamic>> wizardIndustries(List<dynamic> packs) {
  return packs
      .map((p) => <String, dynamic>{
            'id': p['id'],
            'emoji': p['emoji'],
            'label': p['label'],
            'sub': p['sub'],
          })
      .toList();
}
