# מפת-חיווט — מה מוביל לאן

## זרימת-פתיחה (נשלח v5.92 · `0df54f8`)
`main` → `OnboardingGate` (gated by `welcomeSeenProvider`, seeded ב-`main()` מ-prefs):
- **חדש:** Welcome(רישום) → Profession → 3 שקופיות → בית.
- **כניסה-קיימת / דמו** → בית ישירות (דילוג על מקצוע).
- **logo "BuildSmart"** → בורר "מי אתה?" (`showRolePicker`, `role_picker_sheet.dart`); תפקיד שאינו קבלן → סעיפי חיוג-BS שלו (`activePersonaProvider` + `bs_dial_widget`); קבלן → נשאר באפליקציה הראשית.
- **💡 (קצה שמאלי בכותרת)** → סיור-חוזר (`showIntroTour` → השקופיות).
- **צ'יפ-שם ליד הלוגו** = שם פרטי של משתמש רשום (`userProfileProvider`); אורח/דמו → אין צ'יפ.

קבצים: `welcome_screen` · `profession_screen` · `onboarding_screen` · `role_picker_sheet` · `state/onboarding_gate` · `state/user_profile`. Guarded by `onboarding_test` (7).

## תובנות-אודיט (2026-06-03)
- **`userProfileProvider`** (name/contact/profession) היה **write-only** — נאסף ולא נצרך. עכשיו מוזן ל**ברכת-הבית** (הצ'יפ). 
- **הפער הבא (טרם נבנה):** אזור **"👤 חשבון" בהגדרות** — שם/טלפון/סוג-עוסק/**תחום-מקצועי**, תצוגה **ועריכה**, שקורא+כותב `userProfileProvider`. מקור-אמת: האב-טיפוס `index.html` @6817-6822 (`setGroup('👤 חשבון', ...)`).
- ⚠️ **אל תבלבל שני "מקצוע":**
  - `userProfile.profession` = אינסטלטור/חשמלאי/קבלן-שיפוצים — נתון-**תצוגה/חשבון** (כמו האב-טיפוס).
  - `professionModeProvider` (`profession_mode.dart`) = diy/contractor/pro — ה-state ה**חי** שקובע רמת-פירוט-קטלוג, עם צ'יפ-מחזורי משלו ב-`catalog_screen` (~שורה 4853). **נפרד לגמרי.**
- **"תוכל לשנות מההגדרות"** (תחתית מסך-מקצוע) — הבטחה שתתממש רק כשייבנה אזור-החשבון.

## מקור-אמת לחיווט
האב-טיפוס `index.html` (זרימת-הפתיחה @4029-4238; `showScreen`/`finishRegistration`@18345/`enterApp`@11756/`enterRole`@11806; `homeGreet`@4428) + ה-state והמסכים הקיימים. **R8: אין נתונים — אין המצאה.**
