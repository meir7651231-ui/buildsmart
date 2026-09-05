// חוט · min-to-hm — דקות-מחצות ⇒ "HH:MM" (ההופכי של timeToMin ביומן-החדרים).
// המרה מ-JS (new/atoms/min-to-hm.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חולץ מ-maor/src/components/diary/lib.ts:45-47. השכן pad2 מוזרק כשקע (חוק-1 — אפס import פנימי).
// אפס-import (dart-core בלבד). JS Math.floor ⇒ (a/b).floor (סמנטיקת-floor, לא ~/); JS % ⇒ remainder (רול-9).
String minToHM(int min, String Function(int) pad2) {
  return pad2((min / 60).floor()) + ':' + pad2(min.remainder(60));
}
