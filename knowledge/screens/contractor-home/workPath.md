# atom · workPath · מסלול עבודה חכם   [🔵 צריך-ניתוק קל]
`_WorkPath` (:471) · ConsumerWidget · section (hero)

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| מסלול עבודה חכם (:483) | — לא רשום | text | static |
| 🛁 חדש — מאפס עד גמר (:502) | `smart_home_screen.workpath_badge` ✓ | text | static |
| גמר אמבטיה — מלווה אותך שלב-שלב (:509) | `smart_home_screen.workpath_title` ✓ | text | static |
| 4 שלבים בסדר הנכון… (:515) | `smart_home_screen.workpath_sub` ✓ | text | static |

→ **registry 3 · mapped 3/3 ✓ · לא-רשום 1** (הכותרת) · **state:** Stateless

## 2 · חיבורים (edges)
```
workPath —קרא→   — (אין provider)
workPath —כתוב→  —
workPath —משתמש→ _Pad · _SectionTitle · cfgRadius · CfgText
workPath —מגודר→ kProfileRawShell
```

## 3 · התנהגות (flows)
**WP-1 · build (שער בלבד):**
`rule` `if kProfileRawShell → shrink` → אחרת **רנדר-סטטי טהור** (כרטיס-gradient · badge/title/sub כ-CfgText). **אין reads · אין onTap · אין InkWell.**
*(הערה: פס-התקדמות 38% הישן הוסר — לא היה מקור אמיתי, :520.)*

→ **effect:** תצוגה-סטטית או כלום. **האטום היחיד ללא התנהגות-אינטראקטיבית (מלבד שער).**

## חוזה-רכיב + gaps
`extractable: needs-untangle קל` · props:`[paths, onOpen]` (כשיהיה מקור-מסלולים) · **untangle:** מינימלי — כרגע תוכן-סטטי
**gaps:** רק הכותרת הראשית לא-רשומה (3 הילדים רשומים) — **הכי שלם מבחינת registry**
