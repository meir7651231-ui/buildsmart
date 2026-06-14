# LAUNCH-TASKS-MICRO — מפת השקה מלאה (App Store + Google Play)

> רשימת‑המשימות **המלאה** מ"דמו עובד + ליבת‑שרת מוכחת" עד **השקה בשתי החנויות, בלי placeholders, בלי פספוס מילימטר**.
> מבוסס על האודיט המלא (יוני 2026): server + online‑services + device + placeholders. **גרסה 2 — הורחבה לכיסוי מלא** (אינדקסים, אבטחה, QA, משפטי, חנויות, דומיינים).
> מקרא: **[agent]**=קוד · **[אתה]**=console/עסקי/החלטה · **[חיצוני]**=זמן‑קיר שאי‑אפשר לדחוס.

## מצב נוכחי (אומת)
- ✅ שרת מחובר ומוכח: התחברות(אימייל) · הזמנות · סנכרון — אבל **רק ל‑admin**.
- 🔴 צ׳אט שבור גם ל‑admin (uid). 🧩 רוב ה"חכמה"/חומרה = placeholders (לא קשור לשרת).
- **שורש:** הקליינט כותב שם/תפקיד במקום `auth.uid`, ומאזין לכל אוסף בלי `where`. תיקון ה‑uid פותח את הרוב.

---

## Phase A — ליבת‑uid (חוסם השקה) · ~1–2 שבועות
| ID | משימה | מי |
|---|---|---|
| A1 | `FirestoreCollectionSource`: scoped‑query אופציונלי (ברירת‑מחדל=קיים, אפס רגרסיה) | agent |
| A2 | להזרים `auth.uid` ל‑repos (orders/chat/customers) | agent |
| A3 | orders: `contractorId=uid`; `storeId/courierId=uid` בשיוך; שם‑תצוגה בשדה נפרד | agent |
| A4 | orders: listener ממוקד (`contractorId|storeId|courierId==uid`; manager=full) | agent |
| A5 | chat: `participants=[uid]` + `fromUid` + queries ממוקדים | agent |
| A6 | customers: `ownerId=uid` | agent |
| A7 | מסך הקצאת‑תפקידים (manager→`setRole`) + חיבור `assignRole` ל‑UI | agent |
| A8 | חיבור callables: `advanceOrderStage` · `computeCredit` | agent |
| A9 | seed ראשוני מחשבון admin/dev בלבד | אתה+agent |

## Phase B — ניקוי placeholders (חובה לאפל!) · ~2–4 שבועות
*אפל דוחה אפליקציות עם כפתורים שלא עובדים / "בקרוב".*
| ID | משימה | מי |
|---|---|---|
| B1 | החלטה לכל ~35 "בקרוב" + ~60 הגדרות: לסיים או להסתיר | אתה+agent |
| B2 | פילטרים/מיון · פרסונת קבלן · קטגוריות/מחלקות/מותגים ריקים — להשלים/להסתיר | agent |
| B3 | הגדרות מתות ("נשמר אך לא משפיע") → להסתיר עד מימוש | agent |
| B4 | מקצועות: לבנות חשמלאי/שיפוצים או להסתיר (כרגע רק אינסטלטור) | אתה+agent |
| B5 | להסיר את תג‑הבדיקה (BackendDebugBadge) | agent |
| B6 | onboarding/הרשמה אמיתית למשתמש חדש (לא דמו) | agent |

## Phase C — חומרה (תמונות/שיתוף) · ~שבוע
| C1 | `image_picker`/`camera` + צילום אמיתי (לפני‑אחרי, POD, משימה) | agent |
| C2 | העלאת תמונות ל‑R2 דרך `getUploadUrl` (presigned) | agent |
| C3 | להפעיל `share_plus` (שיתוף אמיתי במקום toast) | agent |

## Phase D — תשלום · ~1–2 שבועות + חיצוני
| D1 | בחירת ספק סליקה ישראלי (Tranzila/Cardcom/Meshulam/Grow) | אתה |
| D2 | פתיחת חשבון‑סוחר (תהליך מול חברת אשראי) | אתה+חיצוני |
| D3 | אינטגרציית סליקה ב‑checkout + מסך תשלום | agent |
| D4 | קבלות/חשבונית‑מס אוטומטית | אתה+agent |

## Phase E — שירותים חיצוניים (אופציונלי ל‑v1) · ~1–2 שבועות
| E1 | מזג‑אוויר: API (OpenWeather/IMS) + חיבור | אתה(מפתח)+agent |
| E2 | שערי מטבע: API + המרה בכל המחירים (הבורר קיים) | agent |
| E3 | AI אמיתי: חיבור LLM ל‑AI hub + צ׳אט (במקום canned) | אתה(מפתח)+agent |

## Phase F — הקמת נייטיב (iOS + Android) · ~שבוע
| F1 | רישום iOS+Android ב‑Firebase + `google-services.json`/`GoogleService-Info.plist` | אתה+agent |
| F2 | App Check נייטיב (Play Integrity / DeviceCheck) | agent |
| F3 | **מחיקת‑חשבון מלאה** (users/{uid}+data) — דרישת אפל | agent |
| F4 | push iOS: העלאת **APNS auth key** ל‑Firebase + Push capability/entitlement (Xcode) | אתה+agent |
| F5 | ערוצי‑התראות (Android channels) + אייקון התראה | agent |
| F6 | אייקונים · splash · גרסה/build‑number · build‑modes | agent |
| F7 | bundle id / package name סופי + שם‑אפליקציה זמין בשתי החנויות | אתה |

## Phase G — הקשחת שרת לפרודקשן · ~1 שבוע
| G1 | **אינדקסים מורכבים ב‑Firestore** (נדרשים ל‑A4/A5 — `where`+`orderBy`) | agent |
| G2 | הקשחת Security Rules: מ‑admin‑override ל‑ownership‑אמיתי לכל אוסף | agent |
| G3 | בדיקות‑rules (emulator) — חנות לא‑קוראת‑של‑אחר · chat מבודד · credit חסום | agent |
| G4 | אכיפת **App Check** על Firestore + callables (S5.7) | אתה+agent |
| G5 | **Crashlytics** (ניטור קריסות) + Analytics אמיתי (כרגע מקומי בלבד) | agent |
| G6 | התראות‑תקציב/עלות (Blaze) + מכסות SMS | אתה |
| G7 | גיבוי/ייצוא Firestore + מדיניות שמירה | אתה+agent |

## Phase H — QA ובדיקות · ~1 שבוע (במקביל)
| H1 | עדכון ~1,953 הבדיקות אחרי שינוי ה‑uid (כולל badge/golden) | agent |
| H2 | מטריצת בדיקות מכשיר אמיתי (iOS + Android, גרסאות שונות) | אתה+agent |
| H3 | beta: TestFlight (אפל) + internal/closed (גוגל) | אתה+agent |
| H4 | **חשבון‑דמו עובד לבודקי אפל** + App Review notes | אתה+agent |

## Phase I — משפטי ותאימות (חוק ישראלי + חנויות)
| I1 | תקנון + מדיניות פרטיות אמיתיים (חוק הגנת‑הפרטיות / GDPR) | אתה(עו"ד)+agent |
| I2 | מילוי פרטי‑חברה (`[שם החברה]` → אמיתי) בכל המסמכים | אתה |
| I3 | **נגישות** (תקנות נגישות — חובה בישראל) | אתה+agent |
| I4 | רישום עוסק/חברה + חשבוניות‑מס (תנאי לתשלום) | אתה+חיצוני |
| I5 | דירוג‑גיל/content‑rating + הצהרת‑הצפנה (export compliance) | אתה |
| I6 | כתובת‑תמיכה + מדיניות מחיקת‑נתונים פומבית | אתה |

## Phase J — נכסי‑חנות + הגשה · ~ימים + ביקורת
| J1 | Apple: App Store Connect, certificates/provisioning, App Privacy labels | אתה+agent |
| J2 | Google: Play Console, **Play App Signing key**, Data Safety, target audience | אתה+agent |
| J3 | צילומי‑מסך לכל גודל מסך · feature graphic (גוגל) · אייקון‑חנות | אתה+agent |
| J4 | תיאורים · מילות‑מפתח · "מה חדש" | אתה+agent |
| J5 | חשבונות מפתח: Apple $99/שנה · Google $25 | אתה |
| J6 | 🔴 Google: **14 יום** closed‑test (12 טסטרים) — לא ניתן לדחוס | אתה+חיצוני |
| J7 | הגשה + ביקורת (אפל 1–7 ימים, אולי דחיות→תיקון→הגשה‑חוזרת) | חיצוני |

## Domains — 2 הדומיינים
| DM1 | `buildsmart-il.com` — חי ✅ (כרגע דמו) | — |
| DM2 | חיבור `בניהחכמה.ישראל` ל‑Firebase Hosting + SSL | אתה+agent |
| DM3 | החלטת redirect (עברי → ראשי) + הפעלת השרת האמיתי על הדומיין כשמוכן | אתה+agent |

---

## אומדן
- **MVP נקי** (A+B+F+G+H+I+J, בלי C/D/E): **~6–8 שבועות**.
- **הכל אמיתי בלי פשרות** (כולל תשלום + חומרה + שירותים חיצוניים): **~2–3 חודשים**.
- **זמן‑קיר חיצוני** (14‑יום גוגל · ביקורת אפל · חשבון‑סוחר · עו"ד): לא ניתן לדחיסה — להתחיל מוקדם במקביל.

## תלויות
```
A (uid) ─→ G (indexes+rules+AppCheck) ─→ H (QA) ─→ J (submit)
A ─→ B (cleanup) ───────────────────────────────→ J
F (native) ─────────────────────────────────────→ J
I (legal) ──────────────────────────────────────→ J   (מתחיל מיד, מקביל)
D (payments) → חיצוני מתחיל מיד ; C/E אופציונלי לעדכונים
J6 (Google 14-day) מתחיל מוקדם ככל האפשר
```

## הערות (מלכודות שלא לפספס)
- **G1 אינדקסים** — בלעדיהם השאילתות הממוקדות (A4/A5) **ייכשלו ב‑runtime**. חובה.
- **B חובה לאפל** — כל "בקרוב" גלוי = דחייה ודאית.
- **H4 חשבון‑דמו** — אפל לא תאשר בלי התחברות עובדת לבודק.
- **I3 נגישות** — חובה חוקית בישראל, לא רק חנות.
- מסמך זה הוא **חי** — כל פריט שמתגלה תוך כדי נרשם כאן. זה ה‑SSOT היחיד להשקה.

---

## 🔬 זוטות שמפילות השקה ברגע האחרון (granular — לא לפספס)
*הדברים הקטנים שלא מופיעים בתוכנית‑על אבל עוצרים הגשה / שוברים בפרודקשן. ⏰ = מלכודת‑זמן. כל פריט עם ⚠️ = לאמת את הדרישה העדכנית (משתנה לאורך זמן).*

### 🔥 Firebase / שרת
- ⏰ **אינדקסים מורכבים** (`firestore.indexes.json`) — שאילתה עם `where`+`orderBy` נכשלת בפעם הראשונה בפרודקשן. ליצור מראש ולפרוס, לא לחכות לשגיאה.
- לוודא ש‑**Rules + Indexes נפרסו ל‑prod** (לא רק emulator/דפדפן).
- **`firebase_options.dart` רק ל‑web כרגע** — נייטיב זורק שגיאה ש‑`main.dart` תופס (try/catch) → **לא קריסה, אבל הטלפון נופל לדמו ולא מתחבר לשרת**. חובה להוסיף iOS/Android כדי שגרסת‑הטלפון תדבר עם השרת הקיים.
- להגביל את ה‑**API key** ב‑GCP (apps/domains) — מפתח פתוח ניתן לניצול/עלויות.
- **forgot‑password** לאימייל חייב לעבוד · אימות‑אימייל אם נדרש.
- מכסות/עלות SMS (phone‑auth) + reCAPTCHA מוגדר לדומיין הנכון.
- `_diag`/בדיקות — לוודא שאין collection בדיקה פתוח ב‑rules.

### 🍎 Apple — זוטות
- **App Privacy labels** חייבים להתאים **בדיוק** לנתונים שנאספים — אי‑התאמה = דחייה.
- ⏰ **חשבון‑דמו עובד** ב‑App Review Notes (לא פג‑תוקף, עם נתונים) — בלעדיו לא יוכלו לבדוק = דחייה.
- **Sign in with Apple** חובה אם יש התחברות חברתית (גוגל/פייסבוק). (רק אימייל/טלפון → פטור.)
- **מחיקת‑חשבון בתוך‑האפליקציה**, נגישה (Guideline 5.1.1) — לא רק "פנה לתמיכה".
- **מחרוזות‑הרשאה** (Info.plist) ספציפיות ובעברית ("המצלמה משמשת לסריקת ברקוד") — גנרי = דחייה.
- **export compliance**: להוסיף `ITSAppUsesNonExemptEncryption=false` ל‑Info.plist (HTTPS פטור) — אחרת שאלה בכל build.
- **אייקון** 1024×1024, בלי שקיפות/alpha, בלי פינות מעוגלות ידניות.
- ⏰ **צילומי‑מסך בגדלים מדויקים** (6.7"/6.5" iPhone; 12.9" iPad אם תומך iPad) — גודל לא‑נכון חוסם הגשה.
- **iPad**: אם לא מסומן "iPhone only" — חייב לעבוד על iPad בלי קריסה.
- **תיאור/metadata** בלי אזכור "אנדרואיד / גם ב‑Google Play" = דחייה.
- **privacy policy URL + support URL** חיים ונגישים בזמן ההגשה.
- ⏰ עיבוד build אחרי העלאה (~שעה) · TestFlight external review (~1–2 ימים).
- bundle id ננעל לתמיד אחרי יצירה · aps‑environment (dev/prod) תואם ל‑push.

### 🤖 Google — זוטות
- ⏰⚠️ **Target API level** עדכני (גוגל דורש API חדש יחסית) — אחרת חסום להעלאה.
- **Play App Signing** — לשמור היטב את upload key; איבוד = נעילה מהאפליקציה.
- **Data Safety form** תואם למדיניות‑הפרטיות — אי‑התאמה = דחייה.
- **Android 13+ `POST_NOTIFICATIONS`** — הרשאת‑ריצה! בלי בקשה מפורשת — התראות **לא מופיעות בשקט**.
- **אייקון התראה** (silhouette לבן + שקיפות) — אחרת ריבוע/עיגול לבן.
- **content rating** (שאלון IARC) · target audience (אם מתחת 13 → דרישות נוספות).
- ⏰⚠️ closed‑test לחשבון אישי חדש (~12+ טסטרים / 14 יום — **לאמת המספר הנוכחי**).
- פורמט **.aab** (לא APK) · 64‑bit · feature graphic 1024×500 · אייקון 512×512 (PNG 32‑bit).
- pre‑launch report (גוגל מריצה על מכשירים אמיתיים — קריסות יצוצו שם).

### 🔧 טכני / Flutter
- **להסיר את תג‑הבדיקה (BackendDebugBadge)** + כל קוד debug/test לפני prod.
- **version code/name** לעלות בכל העלאה — אי‑אפשר להעלות אותו מספר פעמיים.
- splash/launch screen (iOS `LaunchScreen`) · אייקונים בכל הצפיפויות.
- **release build** (לא debug): לוודא ש‑R8/minification לא שובר Firebase/reflection.
- מצבי‑שגיאה ללא‑רשת / token‑פג → לא מסך לבן.
- RTL: לבדוק שאין שבירת layout (במיוחד מסכים/דיאלוגים חדשים).
- תאריכים/מספרים ב‑he‑IL (intl) · גופן Heebo נטען בכל המסכים.
- אם מוסיפים גלריה: `NSPhotoLibraryUsageDescription` (iOS).

### ⚖️ משפטי / עסקי (ישראל)
- תקנון + מדיניות‑פרטיות **חיים באתר** בזמן ההגשה (URL עובד).
- **הצהרת נגישות** באתר (דרישת חוק).
- פרטי‑חברה אמיתיים בכל המסמכים (לא `[שם החברה]`).
- מדיניות‑החזרים (לתשלום) + חשבונית‑מס אוטומטית.
- ⏰ הנפקת **SSL** לשני הדומיינים — שעות עד 48ש' (זמן‑קיר).

---

## 📋 מצאי מסכים מלא (ענף whats-happening · HEAD e3e6e94 · 50 קבצים)
> מעבר ממצה אחד‑לאחד על האפליקציה **האמיתית** (לא הסנאפשוט הישן של ענף‑הידע).
> **ספירה: ✅ 29 גמורים · 🟡 14 חלקיים · 🔴 6 לא‑עובדים** (מתוך 49 מסכים פעילים; +1 helper).

**✅ גמורים (29):** install_studio · lipskey_product_sheet · lipskey_products · notifications · home_shell · rewards_hub · persona_picking · finder · tasks · budget · projects · profile · worker_app · smart_project · audit · regression_panel · onboarding · stock · home_content_reorder · role_picker · coming_soon(host) · suppliers · lens_selector · updates · barcode_scanner · smart_home(ליבה) · dial/menu system.

**🟡 חלקיים (14):**
| מסך | מה חסר | סיבה |
|---|---|---|
| catalog | קטגוריות ריקות → "בקרוב" | placeholder |
| store/checkout | רושם אמצעי‑תשלום, **לא גובה** · OCR ת"מ "בקרוב" | external |
| manager_dashboard | כתיבות admin‑only | uid |
| store_dashboard · courier_dashboard | ✅ A4‑A6 (208f3a9): בריכה ∪ שלי לפי `storeUid/courierUid` — אך מגודר בדגל (דורמנטי בברירת‑מחדל) | uid |
| login_sheet | אמיתי, אך gated מאחורי הדגל | uid |
| finance_hub | FX מ‑kFxRates קבוע · PDF מדומה | external |
| notif_settings | email/SMS/WhatsApp כבויים | external |
| site_hub | ✅ (e1dea1c): GPS נייטיב אמיתי (geolocator) + צילום (C2); הרשאה‑דחויה→null כן | device |
| contractor_tools | סריקת‑תוכנית מדומה | device |
| catalog/chat/store_settings | שורות "נשמר אך לא משפיע" | placeholder |
| departments | 4/9 מחלקות "בקרוב" | placeholder |
| lipskey_brand · smart_home | תג "בקרוב" קל | placeholder |

**🔴 לא‑עובדים (6):**
| מסך | מה חסר | סיבה |
|---|---|---|
| chats | ✅ נסגר (ff9d69d, מגודר): fromUid + participantUids מאוכלס (A7 role-union) → מסתנכרן/מבודד; דורמנטי עד דגל/F1 → 🟡 | uid |
| ai_hub | 7/9 כלים = נתונים קבועים | external |
| camera_sheet | רק ברקוד+פלאש; צילום/גלריה מדומים | device |
| persona_pod | ✅ (d1b0fea+C2): חתימה אמיתית (signature_pad) + צילום אמיתי; עולה R2 (gated) | device |
| profession | רק אינסטלטור; חשמלאי/שיפוצים → "בקרוב" | placeholder |
| notif channels | email/SMS/WhatsApp כבויים | external |

**פילוח 20 הלא‑גמורים (חלק נופלים ביותר מאחת):** uid×5 · external×5 · device×5 · placeholder×6 · legal×1
→ ממופה לשלבים: **uid→A · placeholder→B · device→C · תשלום/external→D/E · legal→I**.

**2 enablers כבר בנויים, רק כבויים מאחורי הדגל:** S1 auth (`auth_state`/`login_sheet`) + S6 push (`push_state`). השלמת זהות‑ה‑uid (Phase A) + הדלקת הדגל = פותחים אותם יחד.

**5 החוסמים הגדולים:** (1) זהות‑uid בהזמנות+צ׳אט · (2) תשלום אמיתי (לא גובה היום) · (3) AI hub (7/9 מדומה) · (4) מצלמה/POD (צילום מדומה) · (5) מקצוע אחד + חצי מחלקות.
