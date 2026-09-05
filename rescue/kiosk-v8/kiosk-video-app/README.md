# Kiosk Video — סרטון בלולאה אינסופית על טאבלט סמסונג

אפליקציית קיוסק פשוטה וסגורה שנועדה לקבל טאבלט (SM-X133 / Galaxy Tab A9),
לשים אותו במקום כלשהו, וזהו — הוא ינגן סרטון בלולאה אינסופית כל פעם שיש
אור מספיק בסביבה.

**מאפיינים:**
- 📹 סרטון בלולאה חלקה (Media3 ExoPlayer)
- ☀️ מתחיל אוטומטית כשחיישן האור עובר סף (ברירת מחדל 120 lux)
- 🔒 מצב קיוסק אמיתי — Lock Task + הרשמה כ-HOME → אין דרך לצאת
- 🔌 מסך תמיד דלוק
- 🚀 עולה אוטומטית ב-boot
- 👆 יציאת בעלים מוסתרת: **3 נגיעות בפינה השמאלית-עליונה + PIN**
- ⚙️ מסך הגדרות נסתר: סף אור, PIN, מצב "תמיד דלוק"

---

## הרכבה — צעד אחר צעד

### 1. שים את הסרטון שלך בפרויקט

```
app/src/main/res/raw/video.mp4
```

- שם הקובץ **חייב** להיות `video.mp4` (או שנה את `R.raw.video` ב-`MainActivity`).
- מותר mp4 / m4v / mkv / webm. אין דחיסה נוספת של Gradle (מוגדר ב-build.gradle).
- ~90 MB זה בסדר גמור.

### 2. בנה APK

יש שלוש דרכים.

**דרך א׳ — GitHub Actions (מומלץ — לא צריך מחשב בכלל):**
1. דחוף את הסרטון שלך לענף `claude/hebrew-greeting-qoCnG` (למשל מ-Termux):
   ```bash
   git clone --depth 1 -b claude/hebrew-greeting-qoCnG https://github.com/meir7651231-ui/buildsmart.git
   cd buildsmart
   cp /sdcard/הסרטון-שלך.mp4 kiosk-video-app/app/src/main/res/raw/video.mp4
   git add kiosk-video-app/app/src/main/res/raw/video.mp4
   git commit -m "kiosk: add real video"
   git push
   ```
2. GitHub יבנה את ה-APK אוטומטית (workflow: **Build Kiosk APK**).
3. אחרי ~5 דקות: **Releases** בדף הריפו → הורד את `kiosk-video.apk`.
4. אם עוד לא דחפת סרטון — ה-APK ייבנה עם סרטון בדיקה (test pattern) כדי שתוכל לבדוק את הקיוסק.

**דרך ב׳ — Android Studio:**
1. פתח את התיקייה `kiosk-video-app` ב-Android Studio (Iguana ומעלה).
2. אם יישאל על Gradle wrapper — אשר יצירה (`gradle wrapper --gradle-version 8.5`) או בחר Gradle מקומי 8.5+.
3. חכה ש-Gradle יסתנכרן.
4. `Build → Build Bundle(s) / APK(s) → Build APK(s)`.
5. ה-APK יהיה ב-`app/build/outputs/apk/debug/app-debug.apk`.

**דרך ג׳ — שורת פקודה (דרוש Gradle 8.5+ ו-Android SDK):**
```bash
cd kiosk-video-app
gradle assembleRelease
# → app/build/outputs/apk/release/app-release.apk
```

### 3. התקן על הטאבלט

**דרך USB (הכי פשוט):**
1. הפעל **Developer Options** בטאבלט: `Settings → About tablet → Software information → תלחץ 7 פעמים על Build number`.
2. הפעל **USB Debugging**: `Settings → Developer options → USB debugging`.
3. חבר את הטאבלט למחשב.
4. `adb install app-release.apk`

**דרך העברת קובץ:**
1. העתק את ה-APK ל-`/sdcard/Download/` דרך USB.
2. בטאבלט: File Manager → Downloads → תלחץ על ה-APK → אשר התקנה ממקורות לא ידועים.

---

## הפעלת מצב Kiosk מלא (Device Owner)

כדי שהאפליקציה תעבוד כמצב קיוסק **הרמטי** (המשתמש בכלל לא יכול לצאת) —
חייבים להפוך אותה ל-**Device Owner**. זה מתאפשר **רק על טאבלט שאתו רק
עכשיו איפסת** (factory reset), ואף חשבון גוגל טרם התחבר.

### שלב-שלב:

1. **אפס את הטאבלט לגמרי** (factory reset).
2. עבור בהתקנה הראשונית **בלי להוסיף חשבון גוגל** — דלג על הכל.
3. הפעל Developer Options + USB Debugging כמו למעלה.
4. התקן את ה-APK:
   ```bash
   adb install app-release.apk
   ```
5. הפוך את האפליקציה ל-Device Owner:
   ```bash
   adb shell dpm set-device-owner com.kiosk.video/.KioskDeviceAdminReceiver
   ```
   אם הצליח יופיע: `Success: Device owner set to package ...`.
6. הפעל את האפליקציה (או פשוט הפעל את הטאבלט מחדש).

מעכשיו הטאבלט הוא **קיוסק סגור לחלוטין**: כפתור הבית לא יעבוד, לא ניתן
למשוך את שורת ההתראות, ולא ניתן להתקין / להסיר אפליקציות.

### כדי להסיר את מצב Device Owner

מסך ההגדרות המוסתר → "שחרר Device Owner". אחר כך אפשר להסיר את
האפליקציה רגיל. אין דרך אחרת חוץ מ-factory reset.

---

## אופן שימוש יומי

- **טאבלט במקום חשוך** → הסרטון לא רץ (חוסך סוללה).
- **טאבלט במקום מואר** → הסרטון רץ בלולאה חלקה, לנצח.
- **חיבור לחשמל** → מומלץ להשאיר על מטען. המסך יישאר דלוק.
- **התאמת רגישות** → מסך הגדרות מוסתר.

### גישה למסך ההגדרות (בעלים בלבד)
1. הקש 3 פעמים ברציפות בפינה השמאלית-עליונה של המסך.
2. הכנס PIN (ברירת מחדל: `1234`).
3. שנה מה שצריך → "שמור" → "חזרה לניגון".

**המלץ:** להחליף את ה-PIN מיד בשימוש הראשון.

---

## פתרון בעיות

**הסרטון לא מתחיל גם כשמאיר אור:**
- נכנס להגדרות → הפעל "ניגון קבוע" זמנית כדי לוודא שהסרטון עצמו תקין.
- אם עובד — הסף גבוה מדי. הורד ל-50 lux.

**הסרטון "מגמגם" בין לולאות:**
- זה נדיר עם ExoPlayer + REPEAT_MODE_ALL. אם קורה —
  בדוק שהסרטון מקודד עם keyframes בהתחלה ובסוף (`ffmpeg -force_key_frames "expr:gte(t,n_forced)" ...`).

**האפליקציה נסגרת אחרי כמה שעות:**
- ודא שהטאבלט מחובר למטען. חלק מהיצרנים מכבים אפליקציות ברקע כשהסוללה נמוכה.
- ב-Samsung: `Settings → Device care → Battery → Background usage limits → הוסף את Kiosk Video ל-Never sleeping apps`.

**רוצה להחליף סרטון:**
1. שים את `video.mp4` החדש ב-`app/src/main/res/raw/` ודחוף לענף (ראה "דרך א׳" למעלה) — APK חדש ייבנה אוטומטית.
2. הורד את ה-APK מ-Releases.
3. `adb install -r kiosk-video.apk` (הדגל `-r` = replace, שומר על מצב Device Owner).

---

## מבנה הפרויקט

```
kiosk-video-app/
├── build.gradle.kts               # top-level plugins
├── settings.gradle.kts
├── gradle.properties
├── gradle/wrapper/…
└── app/
    ├── build.gradle.kts           # dependencies (Compose, Media3, DataStore)
    ├── proguard-rules.pro
    └── src/main/
        ├── AndroidManifest.xml
        ├── java/com/kiosk/video/
        │   ├── KioskApp.kt                    # Application class
        │   ├── MainActivity.kt                # Kiosk UI + ExoPlayer + Lock Task
        │   ├── PinDialog.kt                   # PIN prompt Composable
        │   ├── SettingsActivity.kt            # Hidden owner settings
        │   ├── SettingsStore.kt               # DataStore persistence
        │   ├── LightSensorManager.kt          # Ambient light w/ debounce
        │   ├── BootReceiver.kt                # Auto-launch on boot
        │   └── KioskDeviceAdminReceiver.kt    # Device Admin/Owner
        └── res/
            ├── raw/video.mp4                  # ← שם את הסרטון שלך פה
            ├── values/{strings,themes,colors}.xml
            ├── xml/device_admin.xml
            └── …
```

---

## אחריות ובטיחות

- אין באפליקציה כל חיבור לרשת. הכל רץ מקומי.
- לא נאספים נתונים, אין analytics.
- הסרטון מוטמע בתוך ה-APK — אף אחד לא יכול להחליף אותו בלי ה-PIN.

בהצלחה! 🎬
