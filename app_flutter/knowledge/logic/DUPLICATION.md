# דוח כפילויות — שכבת ה-state (מבוסס על הפירוק המלא)

> נגזר אוטומטית מ-1,852 האטומים המפורקים (`knowledge/logic/*`), ע"י השוואת
> **גוף-האלגוריתם** (behaviour IR) בין מודולים — לא רק שמות. קורא-בלבד: הדוח
> **מתעד** את החוב ומציע פתרון; הוא **לא** משנה קוד.

## 1 · תקציר מנהלים

באפליקציה יש **כפילות-קוד מערכתית** בשכבת ה-`state/`: אותה שגרת שמירה/טעינה
ואותה תבנית-notifier הועתקו-הודבקו על פני עשרות מודולים, במקום להיכתב פעם אחת.

| דפוס | # מודולים | מה משוכפל |
|---|---|---|
| **טעינה מ-SharedPreferences** | **27** | `getInstance → getString(_key) → decode` |
| **שמירה ל-SharedPreferences** | **23** | `getInstance → setString(_key, encode)` |
| **סֶטֶר `state=`** (ה-invariant) | **6** | `_loaded=true → super.state=value → _persist()` |
| **`update(f)`** | **5** | `state=f(state) → _persist()` |
| **סנכרון-רימוט** | **4** | `_refreshFromRemote` + bind/dispose |

**~50 העתקות** של שגרת-האחסון לבדה.

## 2 · הממצאים המדויקים

### 2.1 טעינה (27 מודולים)
```
ab_experiments · brand_history · card_acc_state · card_detail_mode ·
card_filter_state · card_projects · card_selection · card_versions ·
comparison_set · draft_quote · feature_flags · hidden_catalog_sections ·
material_requests_engine · offline_cache · onboarding_progress · profession_mode ·
project_mode · recent_searches · required_docs_policy · saved_projects ·
stage_progress · user_profile · vacation_requests · worker_attendance ·
worker_certs · worker_forms · worker_trainings
```
גוף זהה: `prefs = await SharedPreferences.getInstance() · raw = prefs.getString(_key) · if raw != null → decode`.

### 2.2 שמירה (23 מודולים) — **3 ווריאנטים של codec**
- **רשימה** (`setStringList`) — 9 מודולים
- **אובייקט** (`setString + jsonEncode`) — 11 מודולים
- **enum** (`setString(_key, state.name)`) — 3 מודולים

> ⚠️ זו הסיבה ש"פונקציה אחת" נאיבית לא תעבוד — צריך codec מוזרק.

### 2.3 הסֶטֶר `state=` — **הכי מסוכן** (hard-case #6, משוכפל 6 פעמים)
```
orders_engine · persona_fulfillment · projects_engine · smart_cart · sys_chat · tasks_engine
```
גוף זהה: `_loaded = true · super.state = value · _persist()`.
**הכלל הקריטי "שמור-תמיד-אחרי-שינוי" משוכפל 6 פעמים.** אם מתקנים באחד ושוכחים
באחר — נוצר באג "המצב לא נשמר" שקשה לאתר.

### 2.4 `update(f)` — 5 מודולי-הגדרות
```
app_settings · catalog_settings · chat_settings · notif_settings · store_settings
```
גוף זהה: `state = f(state) · unawaited(_persist())`.

### 2.5 סנכרון-רימוט — 4 מנועים
```
material_requests_engine · orders_engine · sys_chat · tasks_engine
```
גוף זהה: `bindRemote` + `_refreshFromRemote` + `dispose(removeListener)`.

---

## 3 · הפתרון — בטוח, לא-שובר-כלום

### 3.1 העיקרון: mixin אחד, opt-in, זהה-התנהגות
במקום 50 העתקות — **mixin אחד** ש-notifier "מצטרף" אליו. ה-codec מוזרק (פותר את
3 הווריאנטים):

```dart
// lib/state/_persisted.dart  (קובץ חדש — לא נוגע באף מודול קיים)
mixin PrefsPersisted<T> on StateNotifier<T> {
  String get storageKey;          // המפתח
  T decode(String raw);           // מחרוזת → מצב
  String encode(T value);         // מצב → מחרוזת
  bool loaded = false;

  Future<void> loadFromPrefs() async {          // זהה בייט-בבייט ל-_load הידני
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) super.state = decode(raw);
    loaded = true;
  }
  Future<void> persistToPrefs() async {         // זהה ל-_persist הידני
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, encode(state));
  }
  @override
  set state(T value) {                          // מרכז את hard-case #6 למקום אחד
    loaded = true;
    super.state = value;
    persistToPrefs();
  }
}
```
לרשימות: `PrefsPersistedList` (עם `setStringList`); ל-settings: בסיס `SettingsNotifier`
עם `update(f)`.

### 3.2 למה זה **לא שובר כלום** — 6 ערובות

1. **תוספתי (Additive).** קובץ חדש. אף מודול קיים לא משתנה עד שהוא *בוחר* להצטרף.
   אין שינוי גורף, אין big-bang.
2. **זהה-התנהגות בייט-בבייט.** גוף ה-mixin עושה בדיוק מה שהקוד המועתק עשה —
   אותו מפתח, אותו `SharedPreferences` API, אותו דגל `loaded`, אותו סדר.
3. **הדרגתי והפיך.** מודול-אחד-בכל-פעם, diff זעיר. כל צעד ניתן-לביטול לבד.
4. **🔑 המפרק הוא ההוכחה.** אחרי מיגרציה של מודול X: מריצים `decompose --logic X`
   ומשווים את ה-behaviour+contract IR מול הגולדן שלפני. **אם ה-IR זהה (אותם צעדים,
   אותם reads/writes, אותה purity) — ההתנהגות נשמרה, מוכח.**
5. **שער-הבדיקות.** סוויטת 793 הבדיקות + golden פר-מודול רצה על כל מיגרציה. ירוק=בטוח.
6. **מוריד סיכון, לא מוסיף.** ה-invariant של #6 עובר מ-6 עותקים ל**מקום אחד** —
   כבר אי-אפשר "לשכוח" אותו באחד ההעתקים.

### 3.3 סדר-מיגרציה (בטוח→עדין)
1. **enum-mode** (`card_detail_mode`·`profession_mode`·`project_mode`) — 3 שורות כ"א, הכי פשוט → מוכיח את התבנית.
2. **settings-5** (`update(f)`) — אחידים לגמרי.
3. **list/json persisted** — לפי codec.
4. **6 המנועים הכבדים** (`state=` invariant) — אחרונים, בזהירות, כי הם היקרים ביותר.

### 3.4 הגדר-כפער, אל-תמציא
מודול עם וריאציה אמיתית (למשל `worker_*` שבודקים `if !mounted`) — **לא נדחף בכוח**
ל-mixin; מתועד כחריג. עדיף 45/50 נקיים + 5 חריגים-מתועדים, מאשר mixin שמסתיר הבדל.

---

## 4 · הכרעת-בעלים

הכפילות עשויה להיות **מכוונת** (עצמאות-מלאה בין מודולים, אפס-תלות במחלקת-בסיס).
הדוח **מתעד** אותה כחוב עם פתרון-מוכן; המעבר לביצוע דורש **אישור מפורש** (כי הוא
נוגע בקוד-אפליקציה — מחוץ למנדט הקורא-בלבד של הפירוק).
