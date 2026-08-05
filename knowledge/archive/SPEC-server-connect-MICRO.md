# SPEC-server-connect — פירוק-מיקרו מלא (Firebase + R2)

> פירוק שדה-אחר-שדה של `SPEC-server-connect.md` (S0–S9) למשימות-מיקרו. כל שורה = unit-אחד · DoD-בודד · [agent]/[אתה=console]. ביצוע `claude/whats-happening-LyY9G` · push רק על "תדחוף".
> **עיקרון:** drop-in (`_local`→`_firebase`) דרך **cache-pattern** (sync-reads מ-cache · listeners מ-Firestore · optimistic-writes) → UI ללא-שינוי.

---

## ✅ FOUNDATION READY (06-09) — console הוקם, הצי יכול להתחיל קוד
- **Firebase project:** `buildsmart-b0b78` (Spark plan).
- **S0.1 ✅** — project קיים · web app רשום · Hosting חי (`buildsmart-b0b78.web.app`).
- **Auth ✅ (console)** — מופעל: **Phone** + **Email/Password** (מכסת SMS חינם 10/יום → Blaze לפני launch).
- **Firestore ✅ (console)** — **Standard** · region **`me-west1` (Tel Aviv)** · **Production mode** (deny-by-default → דורש Rules S5).
- **CI hosting ✅** — `firebase-hosting.yml` + `firebase.json` (commit `db920f2`, ענף whats-happening · secret `FIREBASE_SERVICE_ACCOUNT`).
- **➡️ הצי מתחיל מ:** S0.2 (`flutterfire configure`) → S0.3 (deps) → S0.4 (init `main.dart`) → S0.5 (App Check) → S1 (auth) → S2/S3 (repos `_firebase`).
- ⚠️ `flutterfire configure` דורש **Firebase CLI + גישת-פרויקט** (הצי/מפתח — לא ה-console-user הלא-טכני).

## S0 · הקמת-Firebase (חוסם-הכל)
| ID | משימה | מי | DoD |
|---|---|---|---|
| S0.1 | צור פרויקט Firebase (console) + הוסף iOS/Android/Web apps | אתה | פרויקט קיים · google-services.json/plist |
| S0.2 | `flutterfire configure` → `firebase_options.dart` | agent | קובץ נוצר · `analyze` 0 |
| S0.3 | deps: `firebase_core`·`firebase_auth`·`cloud_firestore`·`firebase_messaging`·`cloud_functions`·`firebase_app_check` | agent | pub get ירוק |
| S0.4 | `main.dart`: `Firebase.initializeApp` + `FirebaseFirestore.settings(persistenceEnabled:true)` | agent | האפליקציה עולה |
| S0.5 | App Check (debug-provider dev · Play-Integrity/DeviceCheck prod) | agent | App Check פעיל |

## S1 · Authentication (חוסם S5)
| ID | משימה | מי | DoD |
|---|---|---|---|
| S1.1 | מסך/sheet login — שדה-טלפון + שליחת-OTP (`verifyPhoneNumber`) | agent | SMS נשלח |
| S1.2 | אימות-קוד (`signInWithCredential`) | agent | התחברות מצליחה |
| S1.3 | מייל-fallback (`signInWithEmailAndPassword`) | agent | התחברות-מייל |
| S1.4 | `authStateProvider` (Riverpod) — user נוכחי + `_loaded`-guard | agent | provider משקף-מצב |
| S1.5 | קריאת-תפקיד מ-custom-claims (`getIdTokenResult`) → `roleProvider` | agent | role מהשרת |
| S1.6 | `role_picker`: רק למשתמש רב-תפקיד; אחרת role-מ-claims (לא בורר) | agent | פרסונה=זהות |
| S1.7 | logout + ניקוי-cache | agent | יציאה נקייה |
| S1.8 | **מחיקת-חשבון בתוך-האפליקציה** (Apple דורש) — `user.delete()` + מחיקת-data | agent | חשבון נמחק |
| S1.9 | set-role function (admin מקצה תפקיד למשתמש) | agent | claim נכתב |

## S2 · סכמה + cache-pattern (חוסם S3/S4)
| ID | משימה | מי | DoD |
|---|---|---|---|
| S2.1 | מסמך-סכמה: collections + שדות (ר' §סכמה למטה) | agent | schema.md |
| S2.2 | base `FirestoreCachedRepo<T>`: `snapshots()`→cache(Riverpod) · sync `all()` מ-cache · `write`→Firestore+optimistic | agent | base-class + test |
| S2.3 | pilot: `orders` דרך base — מוכיח את הדפוס | agent | orders חי דרך-cache · UI ללא-שינוי |

## S3 · Repository `_firebase` ×6 (מקבילי · drop-in)
*כל repo: ממש את ה-interface הקיים מול Firestore (דרך base S2.2), שמור `_local` כ-fallback.*
| ID | repo | שדות-Firestore | interface (קיים) | DoD |
|---|---|---|---|---|
| S3.O | `orders_firebase` | `Order{orderId,projectId,lines[OrderLineItem{sku,nameHe,brand,qty,unitPrice,lineTotal,size?,note?}],sum,stage,siteAddress,contractorId,storeId,courierId,ts}` | all/open/place/advance/setStage/resetToSeed | provider מ-Firestore · UI זהה · test |
| S3.C | `customers_firebase` | `Customer{id,name,phone,creditLimit,used,balance,ownerId}` | + credit | אשראי נטען · test |
| S3.K | `catalog_firebase` | **סטטי — לא Firestore!** 1,877 מוצרים נשארים bundled/R2-CDN (JSON); repo קורא משם | read | קטלוג מ-bundle/CDN · 0 עלות-DB |
| S3.S | `site_firebase` | `SiteNode{projectId,floor,apt,room}`·gantt·snags·attendance·inspections | — | אתר מ-Firestore |
| S3.T | `stock_firebase` | `StockItem{sku,name,qty,location,projectId}` | move | מלאי+move · test |
| S3.F | `finance_firebase` | `approvalQueue{id,item,status,by}`·`penaltyLedger`·payment-terms (השאר=נגזר client) | — | אישורים/קנסות persist |

## S4 · Real-time (אחרי S3)
| ID | משימה | קובץ | DoD |
|---|---|---|---|
| S4.1 | `chatThreads.where(participants array-contains uid).snapshots()` → רשימת-שיחות חיה | `sys_chat`+repo | רשימה מתעדכנת חי |
| S4.2 | `chatMessages.where(threadId).orderBy(ts).snapshots()` → הודעות-חיות | `sys_chat` | הודעה חדשה מופיעה |
| S4.3 | `send()` → כתיבת-message + עדכון-thread (lastMsg/ts) | `sys_chat` | נשלח+נראה |
| S4.4 | `orders.snapshots()` → cache → `sysOrdersProvider` (סטטוס חי) | `sys_orders`+repo | קידום-חנות נראה אצל-שליח/קבלן |
| S4.5 | **בדיקה דו-מכשירית** chat+orders (A→B תוך-שניות) | — | ✅ cross-device |

## S5 · 🔒 Security Rules — RBAC צד-שרת (קריטי · לפני-השקה)
*כל collection — חוק read/write עם `auth.uid` + role-claim + ownership.*
| ID | collection | חוק |
|---|---|---|
| S5.1 | `users` | read: self/admin · write role: **admin בלבד** |
| S5.2 | `chatThreads` | read/write: `uid in resource.data.participants` |
| S5.3 | `chatMessages` | read: uid∈thread.participants · create: `fromUid==uid` |
| S5.4 | `customers` | read credit: `role==manager \|\| ownerId==uid` · write: manager |
| S5.5 | `orders` | create: contractor · update-stage: store(new→ready) / courier(pickup→delivered) — **transition-מותר-לתפקיד** · read: משתתף |
| S5.6 | `stock`/`site`/`projects`/`tasks` | read/write לפי project-ownership + role |
| S5.7 | App Check enforcement על כל-ה-collections | חסום לקוחות-לא-אפליקציה |
| S5.8 | **emulator-tests** — חנות לא-קוראת-של-אחר · chat-מבודד · credit-חסום | ✅ rules_test ירוק |

## S6 · FCM push
| ID | משימה | DoD |
|---|---|---|
| S6.1 | רישום-token + שמירה ל-`users/{uid}.fcmToken` | token נשמר |
| S6.2 | handlers (foreground/background/tap) | התראה מטופלת |
| S6.3 | trigger: push בשינוי-stage-הזמנה + הודעת-צ׳אט (דרך Function S8) | push מגיע |

## S7 · R2 תמונות (app-side)
| ID | משימה | DoD |
|---|---|---|
| S7.1 | קריאת תמונות-מוצר מ-R2 (URL/CDN) | תמונות נטענות |
| S7.2 | העלאה (POD/before-after) → R2 (presigned, creds בשרת) | העלאה עובדת |

## S8 · Cloud Functions (לוגיקה-רגישה)
| ID | משימה | DoD |
|---|---|---|
| S8.1 | `validateStageTransition` (לא-סומך-client) | מעבר-לא-חוקי נחסם |
| S8.2 | `computeCredit` (אשראי-קבלן בשרת) | credit מחושב-שרת |
| S8.3 | `onStageChange`/`onNewMessage` → FCM trigger | push נשלח |
| S8.4 | `auditLog` (אישורי-רכש/פעולות-רגישות) | log נכתב |

## S9 · Offline/sync
| ID | משימה | DoD |
|---|---|---|
| S9.1 | אמת Firestore offline-persistence (read/write אופליין) | עובד-אופליין |
| S9.2 | offline-queue ל-batch-order (נשלח בחזרת-רשת) | תור-נשלח |
| S9.3 | conflict-resolution (last-write-wins / merge) | אין-אובדן |

---

## סכמת-Firestore (collections)
```
users/{uid}        {phone, role, fcmToken, displayName}
orders/{id}        {projectId, lines[], sum, stage, siteAddress, contractorId, storeId, courierId, ts}
customers/{id}     {name, phone, creditLimit, used, balance, ownerId}
projects/{id}      {name, address, status, contractorId, members[]}
tasks/{id}         {projectId, title, status, assigneeUid, log[]}
stock/{id}         {sku, name, qty, location, projectId}
siteNodes/{id}     {projectId, floor, apt, room, ...}
chatThreads/{id}   {participants:[uid], names, lastMsg, ts}
chatMessages/{id}  {threadId, fromUid, fromRole, text, ts}
─ קטלוג (1,877): NOT Firestore — bundled/R2-CDN JSON (סטטי, אפס עלות-DB)
```

## תלויות
```
S0 → S1 ┐
     → S2 ┤→ S3(×6 מקבילי) → S4(real-time)
S1+S2 ──┴→ S5(Rules — לפני-השקה!)
מקבילי-אחרי-S0: S6 · S7 · S9   ·   S8 לפי-צורך
```

## אומדן-מיקרו
S0 ~5 micro · S1 ~9 · S2 ~3 · S3 ~6 (×repo) · S4 ~5 · S5 ~8 · S6 ~3 · S7 ~2 · S8 ~4 · S9 ~3 = **~48 משימות-מיקרו** · ~2–3 שבועות.

## אזהרות
- **קטלוג לא ב-Firestore** (1,877 סטטי → bundle/R2; אחרת עלות-reads מיותרת).
- **S5 לפני כל deploy-פומבי** — DB-פתוח = דליפת-credit/chat.
- **creds (R2/admin) בשרת/Functions בלבד** — לעולם לא client.
- **drop-in:** אל תהפוך interface ל-async — cache-pattern (S2.2) שומר sync.
