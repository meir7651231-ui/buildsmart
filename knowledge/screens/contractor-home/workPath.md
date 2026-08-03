# atom · workPath · מסלול עבודה חכם   [🔵 צריך-ניתוק קל]
**class:** `_WorkPath` (:471) · `ConsumerWidget` · **kind:** section (hero)

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| מסלול עבודה חכם (:483) | — לא רשום (plain title) | text | static |
| 🛁 חדש — מאפס עד גמר (:502) | `smart_home_screen.workpath_badge` ✓ | text | static |
| גמר אמבטיה — מלווה אותך שלב-שלב (:509) | `smart_home_screen.workpath_title` ✓ | text | static |
| 4 שלבים בסדר הנכון… (:516) | `smart_home_screen.workpath_sub` ✓ | text | static |

→ **registry: 3 · mapped: 3/3 ✓ · לא-רשום: 1** (הכותרת הראשית)

- **state:** Stateless
- **reads:** אין (ref לא בשימוש לדאטה)
- **cross-effects:** אין · **actions:** אין
- **gate:** `kProfileRawShell` → shrink (:478)
- **layout:** `_Pad→Column[ _SectionTitle('מסלול עבודה חכם'), Container(gradient #1F6F6B→#155350)→Column[ pill→CfgText badge, CfgText title, CfgText sub ] ]`. *(פס-התקדמות 38% הישן הוסר — לא היה מקור אמיתי, :520.)*
- **primitives:** _Pad · _SectionTitle
- **חוזה-רכיב:** props:`[paths:list, onOpen:cb]` (כשיהיה מקור-מסלולים) · **untangle:** מינימלי — כרגע תוכן-סטטי, אין provider לנתק
- **gaps:** רק הכותרת הראשית לא-רשומה (3 הילדים רשומים) — **האטום הכי שלם**
