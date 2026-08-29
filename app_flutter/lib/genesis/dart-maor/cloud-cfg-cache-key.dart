// חוט · cloud-cfg-cache-key — מפתח-מטמון לקונפיג-מהענן (maor_cloudcfg:<slug>). חוזה: cloud-cfg-cache-key.contract.md
// המרה מ-JS (new/atoms/cloud-cfg-cache-key.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// שרשור-מחרוזת פשוט: קידומת קבועה + ה-slug. אפס-import (dart-core בלבד).
String cloudCfgCacheKey(String slug) {
  return 'maor_cloudcfg:' + slug;
}
