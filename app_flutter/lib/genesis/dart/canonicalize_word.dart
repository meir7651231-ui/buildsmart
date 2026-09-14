// ⚛️ אטום-Dart (דרגת-חוזה) · canonicalizeWord
// מוצא: buildsmart/app_flutter/lib/features/word_finder/word_extraction.dart:52 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור features__word_finder__word_extraction — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): אוסלו · איביזה · אל · חזור · אלפא · אקווה · ארון · ארונות · מחלק · ברז · ברזי · אמבטיה

/// Collapses a [token] onto its canonical form via [synonyms]; pass-through
/// when no mapping exists. With the EMPTY default `kWordSynonyms` this is the
/// identity — see the OWNER-REVIEW note there.
String canonicalizeWord(String token, Map<String, String> synonyms) =>
    synonyms[token] ?? token;
