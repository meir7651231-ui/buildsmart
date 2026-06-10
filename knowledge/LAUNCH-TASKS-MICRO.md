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
