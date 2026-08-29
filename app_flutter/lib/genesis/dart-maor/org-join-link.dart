// חוט · org-join-link — קישור-הזמנה לעובד/ת: ‏{origin}{base}?org={slug}&join={code}.
// המרה מ-JS (new/atoms/org-join-link.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// טהור, אפס שקעים. אפס-import (dart-core בלבד).
String orgJoinLink(String origin, String basePath, String slug, String code) {
  return origin + basePath + '?org=' + slug + '&join=' + code;
}
