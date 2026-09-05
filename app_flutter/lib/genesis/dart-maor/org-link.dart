// חוט · org-link — קישור-לקוח {origin}{basePath}?org={slug}. חוזה: org-link.contract.md
// המרה מ-JS (new/atoms/org-link.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// שרשור-מחרוזות טהור, עיוור-לריק (חוק-5). אפס-import (dart-core בלבד).
String orgLink(String origin, String basePath, String slug) {
  return origin + basePath + '?org=' + slug;
}
