# מצאי-Placeholders + תוכנית-מילוי להשקה

> נסרק ע"י נחיל-5-סוכנים (2026-06-11, ב-`fd1b9d9`). **מדיניות-בעלים:** לחבר/למלא את הכל — אין "בקרוב"/"בבנייה" גלוי (אפל דוחה).
> **חריגים (הסתר בלבד):** (א) מקצוע חשמלאי+שיפוצים. (ב) 5 מחלקות `live:false`. **i18n ערבית/אנגלית → לבנות (לתרגם).**

## 🔑 דורש מפתח/חשבון מהבעלים (8) — הנחיל מחבר ברגע שסופק
| # | פריט | שירות נדרש | מיקום |
|---|---|---|---|
| 1 | תשלום/סליקה | חברת-סליקה + חשבון-סוחר | `store_screen.dart:2478` · `legal_texts.dart:45` |
| 2 | OCR תעודת-משלוח | שירות OCR | `store_screen.dart:3918` |
| 3 | אוטומציית מזג-אוויר | Weather API | `ai_hub_screen.dart:323` |
| 4 | שיחות קוליות/וידאו | ספק WebRTC | `chats_screen.dart:1343-1364` |
| 5 | התראות אימייל | ספק email | `notif_settings.dart:32` |
| 6 | התראות SMS | ספק SMS | `notif_settings.dart:32` |
| 7 | התראות WhatsApp | WhatsApp Business API | `notif_settings.dart:32` |
| 8 | שערי-מטבע חיים | Currency API | `finance_hub_sheets.dart:1502` |

## 🙈 הסתר (חריגי-בעלים)
- **מקצועות:** חשמלאי · קבלן שיפוצים — `profession_screen.dart:11` (`kComingSoonTrades`)
- **5 מחלקות `live:false`:** חשמל · חומרי בניין · צבע · גבס · אספקה טכנית — `departments_screen.dart:107-113` (+ mirror ב-`smart_home_screen`, וקטגוריות-Lipskey ריקות `lipskey_brand_screen.dart:350`)

## 🟢 לבנות (הנחיל · בלי תלות) — ~85 + i18n
- **הגדרות (39):** 25 שורות "בבנייה" `catalog_settings_screen.dart:287-497` + 14 שדות-מתים `app_settings.dart:52-79` (ה-state כבר קיים — רק לחבר קריאה).
- **התראות (~20):** כל "נשמר אך לא משפיע"/"בבנייה" ב-`notif_settings_screen.dart` — צליל/רטט · פר-תפקיד · סיכומים · שעות-שקט · quick-actions · הצעות-ספקים · חזר-למלאי · תזכורות · עדכוני-פרויקטים.
- **מכשיר (9):** רכיבי image_picker/geolocator/signature_pad/share_plus — `camera_sheet.dart:168,189,199` · `persona_pod_sheet.dart:200,223` · `site_hub_screen.dart:826,1201` · `contractor_tools_sheets.dart:671` · `rewards_hub_screen.dart:338` · `install_studio_screen.dart:2771`.
- **AI (5):** על דאטה אמיתי — `ai_hub_screen.dart:207,245,358,405` (חיזוי-מלאי · התאמה-משולשת · בלאי · analytics).
- **צ׳אט (3):** `chats_screen.dart:1307,1314,1714` (חיפוש-בשיחה · חסימת-איש-קשר · הקלטת-קול).
- **קטלוג/חנות (~9):** הרחבת פילטרים `catalog_screen.dart:1714` · 6 sheets-שירות `store_screen.dart:3233-3281` (השכרה · פיקדונות · החזרות · מכרז-ספקים · גיליונות-בטיחות · השוואת-מחירים) · שיחה(tel:)/מועדים/תזמון `store_screen.dart:922-1040`.
- **i18n — ערבית + אנגלית** (טראק גדול נפרד): מערכת-l10n + תרגום ~כל המחרוזות + בדיקת LTR לאנגלית. `*_settings` language selectors (כרגע `enabled:false`).

## גלים (wave plan)
1. **הסתרה** (5 מחלקות + 2 מקצועות) — ⏳ בתהליך
2. **הגדרות + התראות** (חיבור ~59)
3. **מכשיר** (הוספת רכיבים + לכידה אמיתית)
4. **AI + צ׳אט**
5. **קטלוג/חנות** (sheets + quick-actions)
6. **i18n** (ערבית+אנגלית — גדול)
7. **🔑** — ממתין למפתחות/חשבונות מהבעלים (8 פריטים)

> כל גל: builder → supervisor (analyze 0 · suite · mutation · build) → commit-על-ירוק → push.
