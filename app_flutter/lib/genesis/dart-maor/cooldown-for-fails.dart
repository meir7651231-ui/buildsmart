// חוט · cooldown-for-fails — כשלונות-PIN ⇒ מ״ש-קירור. חוזה: cooldown-for-fails.contract.md
// המרה מ-JS (new/atoms/cooldown-for-fails.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// מקור: maor/src/lib/lock.ts:167-170. אטום-טהור, אפס-שקעים. אפס-import (dart-core בלבד).
int cooldownForFails(int fails) {
  return fails >= 5 ? 30000 : fails >= 4 ? 15000 : fails >= 3 ? 5000 : 0;
}
