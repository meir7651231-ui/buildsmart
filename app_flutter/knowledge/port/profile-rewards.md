# Port · E — פרופיל / דרגות / מועדון (כרטיס הקבלן)

> ידע מפורט להטמעה. תחום **E** ב-`../PARITY.md`. סטטוס Flutter: ❌ **נעדר לגמרי**.
> מקור התוכן: פרוטוטייפ `/index.html` (verbatim) + מימוש-dial ב-Preact `app/`.
> כלל-על: הכל **dial** (R2), מחרוזות **verbatim** (R6/R8), לוגיקה ב-helpers טהורים.

## למה זה ראשון
נעדר לגמרי ב-Flutter (דף חלק) · Preact כבר תרגם ל-dial (`PROFILE_TREE`) — מבנה מוכן · תוכן עשיר ומוגדר · אין הכרעת-עיצוב. **בונוס:** מילוי זה ממלא גם את persona הקבלן הריק (תחום A).

## מקור (פרוטוטייפ)
- כרטיס: `refreshIdentity()` [L6545] · עריכה `openIdentityEditor` [L6692] · דרגה `openRankDetail` [L6702].
- דרגות: `RANKS` [L6499] · `currentRank/nextRank` [L6526/6531] · התקדמות `%` [L6560].
- הישגים: `identityAchievements(s)` [L6535].
- מועדון: `openRewardsHub()` [L21452] · `buildCoins`/`loginStreak`/`referralCode` [L21409].
- מימוש-dial ב-Preact: `app/src/components/menu/submenu-settings.tsx` `PROFILE_TREE` [L846-896] + `app/src/data/identity.ts`.

## מבנה ה-dial להטמעה (verbatim)
```
👷 כרטיס קבלן                      ← hero: 'BuildSmart · כרטיס קבלן', avatar 👷, 'קבלן רשום'
├── 📊 המספרים שלך                 ← 4 עלי-סטטיסטיקה (חיים מ-identityStats)
│   ├── 📦 הזמנות
│   ├── 🏗️ אתרים פעילים
│   ├── 🌳 עצי מוצרים
│   └── 🧠 אביזרים שהעץ הציל         (+ שורת 'סך הרכש דרך BuildSmart')
├── 🏅 דרגות הקבלן                  ← סולם 4 הדרגות (להלן)
│   └── 🎯 הישגים                   ← 6 badges (להלן)
└── 🎮 מועדון BuildSmart            ← rewards hub (7 אריחים, להלן)
```

### דרגות — `RANKS` (verbatim, סף = מס' הזמנות מצטבר)
| emoji | שם | min | הטבה (verbatim) |
|---|---|---|---|
| 🔰 | קבלן חדש | 0 | גישה מלאה לקטלוג ולעץ המוצרים החכם |
| 🔨 | קבלן קבוע | 3 | 2% הנחה על כל הזמנה · עדיפות בזמני משלוח |
| ⭐ | קבלן מועדף | 8 | 5% הנחה · משלוח אקספרס חינם פעם בשבוע |
| 💎 | קבלן פלטינום | 15 | 8% הנחה · אקספרס חינם תמיד · מנהל לקוח אישי |

לוגיקה (helpers טהורים, mutation-tested): `currentRank(orders)` · `nextRank(orders)` ·
`rankProgress(orders) = (orders − rank.min) / (next.min − rank.min)`.

### הישגים — `identityAchievements` (verbatim, `on` לפי סטטיסטיקה חיה)
| emoji | שם | תנאי |
|---|---|---|
| 🚀 | הזמנה ראשונה | orders ≥ 1 |
| 📦 | 10 הזמנות | orders ≥ 10 |
| 🏗️ | ריבוי אתרים | sites ≥ 3 |
| 🌳 | חובב עץ מוצרים | trees ≥ 5 |
| 🧠 | לא שוכח כלום | autoSaved ≥ 25 |
| 💰 | מחזור ₪10K | spent ≥ 10000 |

### מועדון BuildSmart — `openRewardsHub` (verbatim, 7 אריחים)
באנר: `🪙 {N} BuildCoins` · `🔥 רצף של {N} ימים פעילים`. אריחים:
🎯 אתגרים חודשיים · 🏆 לוח מובילים · 🌿 תגי ירוק · 📍 קופונים לפי מיקום ·
👥 הזמן חבר (+100) · 💎 מועדון VIP (כסף / זהב ≥500 / פלטינה ≥1500) · 🎁 מימוש הטבות.

## נתונים
- `identityStats` = {orders, sites, trees, autoSaved, spent}. אין backend → **ערכי דמו** (כמו Preact: sites=3, השאר 0/דמו). מסומן "מצב הדגמה" ביושר.
- `buildCoins=340`, `loginStreak=4`, `referralCode='BUILD-7K29'` — דמו verbatim.
- ⛔ ערכים אמיתיים (הזמנות/מחזור) — חסומים עד backend; הדרגה/הישגים מחושבים מהדמו.

## שילוב ב-Flutter (מומלץ)
- למלא את persona **👷 קבלן** ב-`bs_dial_widget.dart` בעץ הזה → פותר A+E יחד.
- נתונים: `lib/data/contractor_identity.dart` (RANKS + achievements + stats דמו).
- לוגיקה: helpers טהורים ב-אותו קובץ (`currentRank`/`nextRank`/`rankProgress`) → `WIRING.md` + `gaps_test`.
- העלים נפתחים כ-dial-drill (R4: circle+label); עלי-סטטיסטיקה מציגים ערך, לא toast "בבנייה".

## קריטריוני קבלה
- persona קבלן ב-BS dial אינו ריק → פותח את עץ-הכרטיס.
- `currentRank(0)`=קבלן חדש · `currentRank(3)`=קבלן קבוע · `currentRank(15)`=פלטינום.
- 6 ההישגים נדלקים לפי הסף (helper נבדק עם mutation).
- כל המחרוזות verbatim; אין עלה שמראה "בבנייה" בתוך הכרטיס.
- `flutter analyze` נקי · `flutter test` ירוק · גרסה מוקפצת.

## פתוח
- היכן בדיוק נגיש (persona קבלן ב-BS dial מומלץ; חלופה: כניסת "פרופיל"). תלוי בהכרעת תחום A.
