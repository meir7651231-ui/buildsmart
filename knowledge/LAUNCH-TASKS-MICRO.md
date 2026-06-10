# LAUNCH-TASKS-MICRO — מפת השקה מלאה (App Store + Google Play)

> פירוק‑מיקרו של הדרך מ**"דמו עובד + ליבת‑שרת מוכחת"** עד **השקה מלאה בשתי החנויות, בלי placeholders**.
> מבוסס על האודיט המלא (יוני 2026): server‑connect + online‑services + device‑capabilities + placeholder‑sweep.
> עיקרון: כל שורה = unit · DoD · **[agent]**=קוד · **[אתה]**=console/עסקי · **[חיצוני]**=זמן‑קיר שאי‑אפשר לדחוס.

## מצב נוכחי (אומת)
- ✅ שרת מחובר ומוכח: התחברות(אימייל) · הזמנות · סנכרון — אבל **רק ל‑admin** (override "רואה הכול").
- 🔴 הצ׳אט שבור גם ל‑admin (uid).
- 🧩 רוב ה"חכמה" (מזג‑אוויר/מטבע/AI) ורוב החומרה (צילום/שיתוף) = placeholders, **לא קשור לשרת**.

## שורש הבעיה
הקליינט כותב **שם/תפקיד** במקום `auth.uid` בשדות בעלות/משתתפים, ומאזין ל**כל אוסף** בלי `where`. לכן הכול עובד ל‑admin ונשבר למשתמש אמיתי. **תיקון ה‑uid הוא המפתח שפותח את הרוב.**

---

## Phase A — ליבת‑uid (חוסם השקה) · ~1–2 שבועות
| ID | משימה | מי | DoD |
|---|---|---|---|
| **A1** | `FirestoreCollectionSource`: param אופציונלי ל‑scoped‑query (ברירת‑מחדל = התנהגות קיימת) | agent | build ירוק · אפס רגרסיה |
| **A2** | להזרים `auth.uid` ל‑repos (orders/chat/customers) דרך ה‑provider | agent | uid זמין בכתיבה/scope |
| **A3** | orders: `contractorId=uid` בכתיבה; `storeId/courierId=uid` בשיוך/קידום; שם‑תצוגה בשדה נפרד | agent | קבלן אמיתי יוצר הזמנה שעוברת את ה‑rules |
| **A4** | orders: listener ממוקד (`contractorId|storeId|courierId == uid`; manager=full) | agent | קבלן רואה רק את שלו · admin הכול |
| **A5** | chat: `participants=[uid]` + `fromUid`; queries ממוקדים (arrayContains/threadId) | agent | הודעה מסתנכרנת בין שני משתמשים אמיתיים |
| **A6** | customers: `ownerId=uid` בכתיבה | agent | קבלן רואה את האשראי שלו |
| **A7** | מסך הקצאת‑תפקידים (manager → `setRole`) + חיבור `assignRole` ל‑UI | agent | מנהל נותן תפקיד מתוך האפליקציה |
| **A8** | לחבר את ה‑callables: `advanceOrderStage` · `computeCredit` | agent | קידום‑שלב/אשראי דרך השרת (לא כתיבה ישירה) |
| **A9** | seed ראשוני מחשבון admin/dev בלבד | אתה+agent | אוספים מאותחלים בשרת |

## Phase B — ניקוי placeholders (חובה לאפל) · ~2–4 שבועות
*אפל דוחה אפליקציות עם כפתורים שלא עובדים / "בקרוב".*
| ID | משימה | מי |
|---|---|---|
| B1 | החלטה לכל ~35 "בקרוב" + ~60 הגדרות: לסיים או להסתיר עד‑אחרי‑השקה | אתה+agent |
| B2 | פילטרים/מיון בחיפוש · פרסונת קבלן · קטגוריות/מחלקות/מותגים ריקים — להשלים או להסתיר | agent |
| B3 | הגדרות מתות ("נשמר אך לא משפיע") → להסתיר עד מימוש | agent |
| B4 | מקצועות: לבנות חשמלאי/שיפוצים או להסתיר (כרגע רק אינסטלטור) | אתה+agent |
| B5 | להסיר את תג‑הבדיקה (BackendDebugBadge) | agent |

## Phase C — חומרה (תמונות/שיתוף) · ~שבוע
| ID | משימה | מי |
|---|---|---|
| C1 | להוסיף `image_picker`/`camera` + צילום אמיתי (לפני‑אחרי, POD, משימה) | agent |
| C2 | העלאת תמונות ל‑R2 דרך `getUploadUrl` (presigned) | agent |
| C3 | להפעיל `share_plus` (שיתוף אמיתי במקום toast) | agent |

## Phase D — תשלום · ~1–2 שבועות + חיצוני
| D1 | בחירת ספק סליקה ישראלי (Tranzila/Cardcom/Meshulam) | אתה |
| D2 | פתיחת חשבון‑סוחר | אתה+חיצוני |
| D3 | אינטגרציית סליקה ב‑checkout | agent |

## Phase E — שירותים חיצוניים (אופציונלי ל‑v1) · ~1–2 שבועות
| E1 | מזג‑אוויר: API (OpenWeather/IMS) + חיבור | אתה(מפתח)+agent |
| E2 | שערי מטבע: API + המרה בכל המחירים (הבורר כבר קיים) | agent |
| E3 | AI אמיתי: חיבור LLM ל‑AI hub + צ׳אט (במקום canned) | אתה(מפתח)+agent |

## Phase F — נייטיב + הכנה לחנויות · ~שבוע
| F1 | רישום iOS+Android ב‑Firebase + `google-services.json`/`GoogleService-Info.plist` | אתה+agent |
| F2 | App Check נייטיב (Play Integrity / DeviceCheck) | agent |
| F3 | **מחיקת‑חשבון מלאה** (users/{uid} + data) — דרישת אפל | agent |
| F4 | push ל‑iOS: APNS entitlement + Push capability (Xcode) | אתה+agent |
| F5 | אייקונים · splash · versioning · build‑modes | agent |

## Phase G — נכסי‑חנות + הגשה · ~ימים + ביקורת
| G1 | מילוי פרטי‑חברה במשפטי (`[שם החברה]` → אמיתי) | אתה |
| G2 | מדיניות פרטיות + Data‑Safety(גוגל) + Privacy‑Labels(אפל) | אתה+agent |
| G3 | צילומי‑מסך · תיאורים · מילות‑מפתח | אתה+agent |
| G4 | חשבונות מפתח: Apple $99/שנה · Google $25 | אתה |
| G5 | 🔴 Google: **14 יום** closed‑test (12 טסטרים) — לא ניתן לדחוס | אתה+חיצוני |
| G6 | הגשה + ביקורת (אפל 1–7 ימים, אולי דחיות) | חיצוני |

---

## אומדן
- **MVP נקי** (ליבה A + ניקוי B, בלי AI/מזג‑אוויר/מטבע אמיתיים): **~4–6 שבועות**.
- **הכל אמיתי, בלי פשרות, שתי חנויות**: **~2–3 חודשים**.
- **זמן‑קיר חיצוני** (14‑יום גוגל · ביקורת אפל · חשבון‑סוחר): לא ניתן לדחיסה — מתחיל במקביל לפיתוח.

## תלויות
```
A (uid core) ─┬─→ B (placeholder cleanup) ─→ G (submit)
              ├─→ C (camera/share) 
              ├─→ D (payments)         ──────→ G
              └─ E (external svcs, optional)
F (native setup) ────────────────────────────→ G
G5 (Google 14-day) starts as early as possible (wall-clock)
```

## הערות
- **A1 קודם** — אבן‑היסוד; כל A3/A4/A5/A6 נשענים עליה.
- **B חובה לאפל** — placeholder גלוי = דחייה ודאית.
- מסלול מומלץ: A → B → F → G (השקה ראשונית נקייה), ואז C/D/E בעדכונים.
