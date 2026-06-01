# SEND_TO_GOOGLE — runbook הגשה ל-Google Play (BuildSmart)

> **המטרה הסופית:** להעלות את `app-release.aab` + הליסטינג ל-Google Play Console — וזהו.
> מקרא: ✅ מוכן (בנצי הכין) · 🔧 פעולה-טכנית (בנצי, כשיהיו תנאים) · ⬜ **דרוש ממך** (אי-אפשר להמציא).

---

## 0. תנאים מוקדמים (⬜ דרוש ממך — צעד 96 בפרוטוקול)
1. ⬜ **חשבון Google Play Developer** — הרשמה חד-פעמית ($25) ב-play.google.com/console.
2. ⬜ **release keystore + סיסמאות** — מפתח-החתימה. (בנצי יכול לייצר אותו ב-keytool כשתאשר; אתה שומר את הסיסמאות — בלעדיהן אי-אפשר לעדכן את האפליקציה לעולם.)
3. ⬜ **applicationId סופי** — כיום `com.buildsmart.buildsmart`. לא ניתן לשינוי אחרי הפרסום הראשון.
4. ⬜ **privacy-policy URL חי** — דף-אינטרנט ציבורי. בנצי מכין טיוטת-תוכן (`privacy-policy.md`); אתה מארח אותו (GitHub Pages / אתר) ונותן קישור.

---

## 1. בניית ה-AAB החתום (🔧 בנצי, כשיש keystore + Android SDK/CI)
```bash
# 1. הגדרת חתימה — android/key.properties (לא נכנס ל-git):
#    storeFile=<path>\upload-keystore.jks
#    storePassword=***  keyPassword=***  keyAlias=upload
# 2. build.gradle.kts כבר יקרא מ-key.properties (בנצי יכין את ה-signingConfig).
# 3. הבנייה:
flutter build appbundle --release
# פלט: build/app/outputs/bundle/release/app-release.aab
```
**אימות לפני העלאה:** האם ה-AAB חתום ב-release-key (לא debug)? `applicationId` נכון? `versionCode`/`versionName` תואמים ל-`pubspec` (כיום 1.4.1+6)?

---

## 2. יצירת האפליקציה ב-Play Console (⬜ אתה, פעם אחת)
1. Play Console → **Create app** → שם: **BuildSmart** · שפת-ברירת-מחדל: עברית · App/Game: App · Free.
2. אשר את ההצהרות (Developer Program Policies, US export laws).

## 3. מילוי הליסטינג — Store listing (✅ מ-`store-listing/`)
- כותרת + תיאור-קצר + תיאור-מלא (he, ובהמשך en) — מ-`store-listing/` *(קופי-שיווק מעבר לעובדות = ⬜ אישורך, R6/R8)*.
- **App icon 512×512** · **Feature graphic 1024×500** · **Screenshots** (≥2, פר גודל-מכשיר) — מ-`store-listing/` (חלקם ⬜).

## 4. Data safety (✅ מ-`data-safety.md`)
- App content → **Data safety** → העתק את התשובות מ-`data-safety.md`: **No data collected / No data shared**, הרשאות מצלמה/מיקרופון on-device. (וודא את הערת-המיקרופון לגבי שירות-הקול של המערכת.)

## 5. הצהרות נוספות (⬜ אתה, מודרך)
- **Content rating** — מילוי שאלון (אפליקציית-מסחר/פרודוקטיביות → דירוג נמוך).
- **Target audience** — לא-לילדים.
- **Privacy policy** — הדבק את ה-URL (סעיף 0.4).
- **Ads** — אין פרסומות (אומת: 0 SDK פרסום).
- **App access** — כל-התוכן-נגיש (אין login).

## 6. שחרור (Release)
1. **Internal testing** תחילה (מהיר, ללא ביקורת מלאה) → העלה `app-release.aab` → הוסף את עצמך כ-tester → התקן ובדוק על טלפון אמיתי.
2. כשתקין → **Production** → צור Release → העלה AAB → `release-notes` (מ-`release-notes-he.txt`) → **Review & rollout**.
3. ביקורת-גוגל: כמה שעות עד ימים. אחרי אישור — האפליקציה חיה ב-Play.

---

## 7. טבלת go/no-go סופית (חייב P0=0 כדי להעלות)
| חוסם | מצב |
|---|---|
| `app-release.aab` חתום | ⬜ דורש keystore + build (סעיף 1) |
| applicationId סופי | ⬜ אישורך |
| חשבון Play | ⬜ שלך |
| privacy-policy URL | ⬜ שלך (טיוטה ✅) |
| data-safety | ✅ מוכן |
| הרשאות מוצדקות (camera/mic) | ✅ (פאזה H) |
| 0 secrets / offline | ✅ (פאזה H) |
| analyze 0-errors · tests ירוקים | ✅ |
| icon 512 / screenshots / feature-graphic | 🔧 חלקי — ראה `store-listing/` |

**ברגע שכל ה-⬜ נסגרו → העלה `app-release.aab` + הליסטינג ל-Play Console → הסיפור נגמר.**

*(נכתב ע״י בנצי/משיק — פאזה I, צעד 100. מתעדכן ככל שפריטי-⬜ נסגרים.)*
