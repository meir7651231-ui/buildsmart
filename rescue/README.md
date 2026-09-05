# 🛟 rescue/ — נכסים שחולצו מענפים צדדיים (23.8.2026)

נכסים שחיו רק על ענפים בודדים והיו בסכנת אובדן. חולצו כלשונם (bit-identical),
למעט שני חריגים מתועדים למטה. מקור: דוח-הנחיל swarm-report §שכבה-ד׳.

| תיקייה | מקור (ענף) | תוכן |
|---|---|---|
| `catalog-exports/` | `claude/nice-volta-BSbVm` + `claude/mah-kora-udw964` | קטלוג מלא XLSX + ‏import-ready CSV ‏(1,868 שורות) + חוליות מפורק (1,752×26) + חוליות גולמי |
| `protocol-v10/` | `claude/agent-network-proto-build` | מנוע-האכיפה protocol_check.dart v10 ‏(3,157 שורות) + selftest + ‏protocol/ (gates+pins+regressions) + PROTOCOL_V10.md |
| `maor-mockups/` | `claude/phone-connection-opaerc` | 26 המוקאפים המאושרים-בעלים של מאור (4 ערכות-שלד + compare) — נמחקו ממאור ב-PR ‏#37 |
| `kiosk-v8/` | `claude/hebrew-greeting-qoCnG` (תג kiosk-v8) | אפליקציית-הקיוסק המלאה: Device-Owner, חיישן-אור, BootReceiver, PIN, CI |
| `owner-patches/` | `integrate/monster-live` | 2 קומיטי-בעלים (תיקוני-מקלדת, 46 שורות) שלא הגיעו לקו-האמת |

## ⚠️ חריגים מכוונים
1. **`kiosk.jks.b64` לא חולץ** — מפתח-החתימה והסיסמה נחשפו בהיסטוריית הענף המקורי.
   לפני שימוש מסחרי: keystore חדש + סיסמה חדשה. הענף המקורי לא ימוזג לעולם.
2. **`video.mp4` (94MB) לא חולץ** — תוכן חליפי; שמור בתג `kiosk-v8` אם יידרש.

קובצי `.disabled` = ‏workflows שחולצו כתיעוד — לא פעילים עד העברה מפורשת ל-`.github/workflows/`.
