# דוח כפילויות — שכבת ה-state (מבוסס על הפירוק המלא)

> ## 🟢 סטטוס-ביצוע (opt-in, לא-שובר)
> - **slice 1 — שלישיית ה-enum ✅ בוצע.** `card_detail_mode` + `project_mode`
>   (מלא) + `profession_mode` (חלקי — `_load` המיוחד נשמר verbatim) עברו למיקסין
>   `EnumPrefsPersisted<T>` (`lib/state/prefs_persisted.dart`). ה-`set`/`persist`
>   המשוכפלים ×3 → מקום אחד. 3 בדיקות ייעודיות ירוקות (defaults · שמירה על-פני
>   notifier חדש · no-op אידמפוטנטי). analyze נקי.
> - **slice 2 — 5 מודולי-ההגדרות ⛔ חסום (הכרעת-בעלים).** `app/catalog/chat/notif/
>   store_settings` מוגנים ע"י **Gate 25** בשער-הפרוטוקול (`שער 25: משותף עם
>   Preact — אסור לגעת`). הם חלק מחוזה ה-parity Flutter↔Preact ולא ניתן לפרק אותם
>   באופן חד-צדדי. **דילגתי, כיבדתי את השער** — הדדופ שלהם דורש override מפורש של
>   Gate 25 מהבעלים. (הכפילות מתועדת; הפתרון `JsonPrefsPersisted` מוכן אם/כאשר
>   יאושר.)
> - **slice 3a — 4 מודולי Set-list ✅ בוצע.** `comparison_set` · `stage_progress`
>   · `hidden_catalog_sections` · `onboarding_progress` עברו למיקסין
>   `StringSetPrefsPersisted` (getStringList→toSet / setStringList). **−20 שורות**,
>   ה-import של shared_preferences הוסר לגמרי (דדופ מלא). 37 בדיקות ירוקות.
>   `smart_project_engine` — variant (`_load` שונה) → דולג לפי כלל-הבטיחות.
> - **slice 3b — 4 מודולי Map/List-json ✅ בוצע.** `ab_experiments`+`card_selection`
>   (Map<String,String> → `StringMapPrefsPersisted`) · `card_versions`+`draft_quote`
>   (List → `JsonListPrefsPersisted<E>`). **−47 שורות**. 14 בדיקות ירוקות.
> - **slice 4a — smart_cart (hard-case #6) ✅ בוצע.** ה-`set state` auto-persist +
>   `_loaded` latch → `mixin PersistOnWrite<T>`. `state_loaded_guard_test` נשאר
>   ירוק. 46 בדיקות ירוקות. **5 מנועים נוספים (orders/tasks/projects/sys_chat/
>   persona) — ליבת-הכסף, 2 וריאנטים — ממתינים לצ'קפוינט.**
> - **slice 4b — orders_engine ✅ + projects_engine ✅** (מסלול-הכסף · אותה תבנית
>   `PersistOnWrite<T>` מוכחת · 42 בדיקות + `state_loaded_guard_test` ירוקים).
>   ה-IR מוכיח שמירת-התנהגות: כל mutator עדיין `writes state:state`; תופעת-הלוואי
>   של השמירה עברה מ-inline-לכל-אטום ל-`set state` המשותף במיקסין (בדיוק החתימה
>   הצפויה). נותרו tasks/sys_chat/persona.
> - **3 המנועים הנותרים (`tasks_engine` · `sys_chat` · `persona_fulfillment`) —
>   וריאנטים אמיתיים → נשמרים כפי-שהם (כלל-בטיחות 3.4).** ה-`_load` שלהם קורא את
>   `_loaded` בשומרים-מורכבים או כותב `super.state` מספר פעמים — לא מתאים למיקסין
>   הפשוט; ה-invariant עדיין נאכף ע"י `state_loaded_guard_test`.
> - **slice 5 (HR — `worker_certs/trainings/forms/vacation`) — וריאנטים** (טביעת
>   `_load` שונה, לא בייט-זהה) → מתועדים כחריגים, לא נדחפים בכוח.



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

### 2.3 הסֶטֶר `state=` — **הכי מסוכן** (hard-case #6, היה משוכפל 6 פעמים)
```
✅ smart_cart · ✅ orders_engine · ✅ projects_engine   → PersistOnWrite<T>
⏸️ tasks_engine · sys_chat · persona_fulfillment        → וריאנטים, נשמרים כפי-שהם
```
גוף זהה: `_loaded = true · super.state = value · _persist()`.
**הכלל הקריטי "שמור-תמיד-אחרי-שינוי" רוכז ל`mixin PersistOnWrite<T>` ב-3 המנועים
המתאימים** — כבר אי-אפשר "לשכוח" אותו בהם. 3 הנותרים הם וריאנטים אמיתיים (§3.4)
וה-invariant בהם נאכף ע"י `state_loaded_guard_test`.

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
