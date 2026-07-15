# הנחיית U3 — בעלות-חנות (Store ↔ Owner) ⭐ חוסם-השקה

> **SSOT:** `knowledge/SPEC-user-system-MICRO.md` §U3 · **ביצוע:** `claude/whats-happening-LyY9G` · **דחיפה: רק על "תדחוף".**
> **בסיס:** U1 חי-רדום (`b8fecd93` · CI 8/8 ירוק כולל protocol-enforce). U3 **משלים את שכבת-החנויות** שכבר עלתה לאוויר (catalog→server) — זה חוסם-ההשקה במסלול-המהיר U0→U1→U3.
> **החלטה-נעולה #3:** בעל-יחיד לכל חנות (`storeId` אחד). בלי מודל-צוות.

---

## 1 · 🎯 הגילוי הגדול — חצי מ-U3 כבר בנוי (מאומת ב-`b8fecd93`)
C5.3 כבר הטמיע את **חוק-האבטחה של המלאי owner-gated** ופרס אותו חי (`firestore.rules:783`), במצב forward-ready:
```
match /inventory/{invId} {
  allow read:  if isSignedIn();
  allow write: if isManager() || isOwnerEmail()
      || (hasRole('store')
          && request.auth.token.get('storeId','') != ''
          && request.resource.data.get('storeId','') == request.auth.token.get('storeId',''));
}
```
כלומר: חנות יכולה לכתוב מלאי **רק של עצמה** — הכלל כבר **חי ופרוס**. מה שחסר הוא **טביעת ה-claim `storeId`** (setRole לא כותב אותו עדיין). ברגע ש-setRole יטביע `storeId` — ענף-הבעלים מתעורר לבד. **זו אבן-הראשה של U3 — והיא קטנה.**

## 2 · מוקשים מאומתים (חובה לפני נגיעה)
1. ⚠️ **שם ה-claim = `storeId`** — לא `storeUid`! חייב להיות שווה ל-`id` של החנות ול-`storeId` של שורת-המלאי (doc-id = `{storeId}_{sku}`). הכלל הקיים בודק בדיוק את זה — אל תמציא שם חדש.
2. **מודל `Store` חסר `ownerUid`** — היום id/name/area/logo/contact בלבד (`store_inventory.dart:32`). להוסיף (הקישור ההפוך חנות→בעלים).
3. **`setRole`**: `VALID_ROLES` כבר כולל `'store'` (`functions/src/index.ts:33`), אבל **לא מטביע `storeId`** — זו התוספת היחידה בשרת.
4. **בטיחות-פריסה:** אף משתמש היום אין לו claim `storeId` → ענף-הבעלים **רדום** → **אפס-שינוי-למשתמש-קיים**. הופך פעיל רק כשאדמין ממנה בעל-חנות.

## 3 · המשימות — unit יחיד · DoD · [agent]

### U3.1 · מנגנון-הבעלות
| ID | משימה | DoD |
|---|---|---|
| **U3.1.1 ⭐** | `setRole` מקבל `storeId` אופציונלי (admin-only כמו היום) ומטביע claim `storeId` לצד `role='store'`; ולידציה: storeId לא-ריק + החנות קיימת + audit | claim `storeId` חי |
| U3.1.2 | להוסיף `ownerUid` למודל `Store` + `toDoc`/`fromDoc` + write | חנות↔בעלים |
| U3.1.3 | `myStoreProvider` — החנות של המשתמש המחובר (claim `storeId` → `stores/{id}`) | provider |

### U3.2 · אכיפת-כתיבה (Security Rules)
| ID | משימה | DoD |
|---|---|---|
| U3.2.1 | ✅ **כבר קיים** (`firestore.rules:783`) — רק **לאמת** שהענף מתעורר עם ה-claim | rule (verify) |
| U3.2.2 | להדק `/stores/{storeId}` update → `ownerUid == uid` \|\| admin (היום manager\|\|owner) | rule |
| **U3.2.3 ⭐** | **טסט קריטי:** חנות-א' לא כותבת מלאי של חנות-ב' → **403** (rules-test באמולטור) | PASS |

### U3.3 · חיווט-UI (השלמת השכבה-המסחרית)
| ID | משימה | DoD |
|---|---|---|
| U3.3.1 | טופס-הספק (`supplier_onboarding.dart`) כותב תחת ה-`storeId` של המשתמש | מוצר→חנות-נכונה |
| U3.3.2 | מסך-מלאי-חנות: בעל-חנות עורך מחיר/מלאי של **החנות שלו בלבד** | self-manage |
| U3.3.3 | isolation — חנות רואה/עורכת רק את הנתונים שלה | isolation |
| U3.3.4 | test מלא (3 זרימות) | PASS |

---

## 4 · גידור + בטיחות
- שינויי-U3 (setRole claim + stores rule) **אדיטיביים-ובטוחים**: אף claim `storeId` לא קיים היום → אפס-שינוי-למשתמש-קיים. **לא** flag-gated (זה שרת+rules), אבל "יכולת-מוכנה-לא-בשימוש" — בדיוק כמו ה-rules של U0.
- **המנועים off-limits** (dive/compat/search/studio) — לא נגעים.
- **rules deploy = חי מיידית** (לא מאחורי דגל) → **חובה rules-test ירוק לפני push**, ואימות שהענף-החדש רק מהדק (לא משחרר קיים).

## 5 · הרצת-הנחיל + שער
`/swarm knowledge/SPEC-user-system-MICRO.md` (מיקוד U3).
- **עדשות:** cross-role · state-leakage · **money-numeric** (מחיר/מלאי — קריטי!) · data-seed · async-race.
- **שער:** `flutter analyze` 0 · סוויטה מלאה + **rules-test** (store-A≠store-B → 403) · **mutation-verify** על טסט-הבידוד (הזרק: הסר את בדיקת ה-storeId → הטסט חייב RED) · protocol-enforce ירוק · **rules deploy ירוק**.
- **דחיפה: רק על "תדחוף".**

## 6 · DoD-השקה (זה חוסם-ההשקה)
"בוצע" = **בעל-חנות מנהל את המלאי שלו לבד, ואינו יכול לגעת בשל אחר** (מוכח 403 בטסט + mutation-verify), הכל ירוק. זה משלים את מה ששיגרנו: הקטלוג→שרת נותן **קריאה**; U3 נותן לחנות **כתיבה בטוחה** של המלאי שלה.

## 7 · אחרי U3
U3 סוגר את חוסם-ההשקה המרכזי. נשאר: **U5.2** (חיווט-UI למחיקת-חשבון — חוסם-iOS של Apple) + U2 (הרשמה, שמפעילה את onboarding-החנות שמזין את U3).
