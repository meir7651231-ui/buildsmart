// ⚛️ אטום-Dart (דרגת-חוזה) · matchAssistantRecipeKey
// תפקיד: מקרקע [reply] למפתח-מתכון אמת (‏kSmartProducts.key) — מדויק גובר, אחרת המפתח-הארוך-המוכל; null אם אין.
// מוצא: buildsmart/app_flutter/lib/logic/assistant_intent.dart:82-98 (‏matchAssistantRecipeKey; חוק-4).
// אחים: הקבוע-האח `kSmartProducts` (רשימת-מוצרים) — במקור נסרק `p.key` בלבד; לכן קופל לשקע-נתון
//       `productKeys` (= `kSmartProducts.map((p) => p.key)` verbatim; חוק-3 — הזרקת-רשימת-מפתחות,
//       ההתנהגות זהה). אין private-אח נוסף.
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס-מוצר.

/// מקרקע [reply] למפתח מתוך [productKeys] (= מפתחות `kSmartProducts` verbatim).
/// מעבר-מדויק ראשון; אחרת המוכל-הארוך-ביותר (מפתחות מתנגשים ב-prefix: faucet⊂kitchenFaucet);
/// reply-ריק ⇒ null. verbatim assistant_intent.dart:82-98 (kSmartProducts.key ⇒ שקע-מפתחות).
String? matchAssistantRecipeKey(
  String reply, {
  required List<String> productKeys,
}) {
  final r = reply.trim();
  if (r.isEmpty) return null;
  for (final key in productKeys) {
    if (r == key) return key;
  }
  // Longest contained key — keys collide by prefix (faucet⊂kitchenFaucet,
  // basin⊂basinTrap), so first-match would propose the wrong kit on a wrapped reply.
  String? best;
  for (final key in productKeys) {
    if (r.contains(key) && (best == null || key.length > best.length)) {
      best = key;
    }
  }
  return best;
}
