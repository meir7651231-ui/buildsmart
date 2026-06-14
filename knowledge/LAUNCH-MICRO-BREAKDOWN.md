# LAUNCH-MICRO-BREAKDOWN — פירוק‑מיקרו מלא לכל המשימות

> פירוק **כל** הדרך להשקה למשימות‑מיקרו בודדות. כל שורה = unit · היכן (קובץ/קונסול) · DoD · מי · מאמץ.
> מי: **[agent]**=קוד · **[את]**=החלטה/קונסול/עסקי · **[חיצוני]**=זמן‑קיר. מאמץ: **S**=שעות · **M**=ימים · **L**=שבוע+.
> נלווה ל‑`LAUNCH-TASKS-MICRO.md` (שלבים + גוטצ'ות + מצאי‑מסכים). מבוסס על מצאי e3e6e94.
>
> 🔴 **תזכורת‑על (אומת 13/6 @208f3a9):** סדרת‑A (כולל A4‑A6 שנדחפו עכשיו) **code‑complete אך דורמנטית בברירת‑מחדל** — `useFirebaseBackend` כבוי (`backend.dart`), ו‑`firebase_options` web‑only. **דיוק חשוב:** על מכשיר נייטיב Firebase **לא עולה — אבל זו לא קריסה.** `main.dart:51‑59` עוטף ב‑try/catch+timeout, ה‑throw נתפס, והאפליקציה **נופלת ל‑repos מקומיים (דמו)**. כלומר הטלפון רץ אך **לא מדבר עם השרת** עד F1. ✅ מוכח רק על **preview‑web עם הדגל** (10/6). הלוחות: דמו (דגל OFF) = `BoardSession`/seed; **דגל ON = `BoardSession` נבנה מ‑Firebase‑uid (A4' 50465b1).**

---

## Phase A — ליבת‑uid (חוסם השקה)
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| A1 | ✅ scoped‑query אופציונלי ב‑source | `firestore_cached_repo.dart` | נדחף (e3e6e94) | agent | — |
| A2 | ✅ בוצע (fleet 5590b38) · `currentUid` מ‑auth + להזריק ל‑providers | `auth_state.dart` → `orders_local`/`chat_repository`/`customers_local` providers | repo רואה uid מחובר | agent | S |
| A3 | ✅ (fleet 24b5bc2) · הזמנה: `contractorId=uid` + שדה‑שם נפרד (להפסיק `who`=שם) | `orders_firebase.toDoc` · `orders_engine.placeOrder` · `store_screen.dart:2816` | doc חדש: `contractorId==auth.uid` | agent | M |
| A4 | ✅ (208f3a9) · claim‑on‑advance: `storeUid/courierUid=uid` בקידום + `orderParticipants` | `orders_engine.dart`·`sys_orders.dart`·`orders_firebase.dart` | order נושא uid של החנות/שליח | agent | M |
| A5 | ✅ (208f3a9) · listener ממוקד + שיתוף‑בריכה + indexes | `orders_local.dart`·`orders_repository.dart` | קבלן רק שלו · pool ל‑new/ready · admin הכול | agent | M |
| A6 | ✅ (208f3a9) · דשבורד חנות/שליח = בריכה ∪ שלי | `store_dashboard_screen.dart`·`courier_dashboard_screen.dart` | חנות רואה את ההזמנות שלה | agent | M |
| A7 | ✅ (5233cf8) · מדריך role→uid (לזהות "מי החנות/שליח") | `users` lookup חדש (by phone/role) | אפשר למפות צד‑נגדי ל‑uid | agent | M |
| A8 | ✅ (c35eefe+ff9d69d): fromUid + **participantUids מאוכלס בשליחה** (union uids לפי A7, `sys_chat.ensureParticipantUids:544`) — מגודר בדגל | `chat_firebase.toDoc` · `sys_chat.send` | thread נושא uids · message fromUid | agent | M |
| A9 | ✅ (fec79e2 seam + ff9d69d אכלוס): `participantUids` מאוכלס (union לפי A7) + scoped read + predicate + rules emulator (283) + 247 בדיקות · **צ׳אט מסתנכרן/מבודד אמיתי** (מגודר; scope=role-union) | `chat_firebase`·`sys_chat`·`chat_repository`·`firestore.rules` | קורא רק threads שלו | agent | M |
| A10 | 🟡 rules + emulator coverage (fec79e2 · 283 בדיקות chat.test.js) forward-ready · נותר: להחליט manager override על צ׳אט | `firestore.rules` chat | rules סופי | את+agent | S |
| A11 | ✅ (c35eefe) · לקוחות: `ownerId=uid` בכתיבה | `customers_firebase.toDoc` | customer doc נושא ownerId | agent | S |
| A12 | ✅ (7344097) · מסך הקצאת‑תפקיד (manager → `setRole`) | `manager_dashboard` ניהול tab → `assignRole` | מנהל נותן תפקיד באפליקציה | agent | M |
| A13 | 🟡 שרת ✅ (advanceOrderStage/computeCredit מיוצאים) · קליינט פתוח (רק setRole נקרא) · לחבר callables: `advanceOrderStage` · `computeCredit` | `sys_orders.advance` · מסך אשראי | קידום/אשראי דרך השרת | agent | M |
| A14 | ⚠️ מספור: הקומיט 'A14' של הצי (ff9d69d) = **אכלוס‑צ׳אט** (A8/A9 ✅), לא seed · seed‑ראשוני זה — ייתכן מיותר (דאטה נוצר בהרשמה/שימוש); פתוח | סקריפט/admin | אוספים מאותחלים | את+agent | S |

> 📋 **סקירת‑לוחות (tip 576036c, 13/6):** 🦺עובד · 🛵שליח · 🏪ספק — **✅ שלושתם גמורים**: מגודרים ("מבחוץ לא רואים כלום"), **מסונכרנים לפי זהות** דרך `BoardSession`/`boardAuthProvider` + 5 חשבונות‑seed (עובד/שליח/חנות/מנהל/דמו), עם מנועים אמיתיים (הזמנות/POD/מלאי/rewards/notifs חיים). **A4‑A6 ממוסגר מחדש:** סינון‑לפי‑זהות בצד‑לקוח **כבר עובד** (לפי `session.username`); **server‑swap ✅ בוצע (208f3a9+50465b1):** seeds→Firebase‑uid (A4') + scoped listener + pool — הכל מגודר בדגל. stubs זעירים שנותרו (3): ביטול‑הזמנה‑כולה (picking:720) · חתימת‑POD "(הדגמה)" (pod:262) · כלי‑סימולציית‑הזמנה (store:453).

## Phase B — ניקוי placeholders (חובה לאפל)
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| B1 | ✅ (5a379a2 · debug-only) · להסיר תג‑בדיקה | `main.dart` + מחיקת `backend_debug_badge.dart` | אין debug ב‑prod | agent | S |
| B2 | ✅ (ebb4efd · הוסתרו) · מקצועות: לבנות חשמלאי+שיפוצים **או** להסתיר | `profession_screen.dart:11` | אין "בקרוב" במקצוע | את+agent | L |
| B3 | ✅ (ebb4efd · הוסתרו) · מחלקות: 4 dormant — לבנות **או** להסתיר | `departments_screen.dart:96` (live:false) | אין מחלקה מתה | את+agent | M |
| B4 | ✅ (5a379a2 · הוסתרו) · קטלוג: קטגוריות ריקות — דאטה **או** להסתיר | `catalog_screen.dart:3041` | אין "בקרוב" בקטלוג | agent | M |
| B5 | 🟡 התקדם (950757d קטלוג חי · 6f9b562+1309a78: 4 הגדרות‑חנות חוּוטו לאמת — shareCartWithTeam/supplierCredit/defaultAddress/purchaseHistory) · **גישה: מלא‑אם‑אפשר, אחרת 'בבנייה' ביושר** · נותרו רבות חסומות‑שרת/דאטה | `*_settings_screen.dart` · WIRING.md | אין "נשמר אך לא משפיע" בר‑חיווט | agent | M |
| B6 | חיפוש: פילטרים/מיון — לממש **או** להסתיר | `catalog_screen.dart:1108` · search dial | פועל או נעלם | agent | M |
| B7 | 🟡 חלקי (00beac4: אריח‑מועדף + "הזמן עכשיו"→סל אמיתי תוקנו) · נותרו עלי‑dial "בבנייה" — להחליט פר‑עלה | `sections.dart`/`menu_trees.dart`/`store_screen.dart` | אין עלה‑מת גלוי | את+agent | L |
| B8 | 🟡 מגודר ב‑useFirebaseBackend (576036c — flag OFF=דמו) · הרשמה אמיתית למשתמש חדש (לא local‑only) | `welcome_screen.dart` | נרשם → חשבון אמיתי | agent | M |

## Phase C — חומרת מכשיר
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| C1 | ✅ (4ddb3b9) · להוסיף `image_picker`+`camera` ל‑pubspec | `pubspec.yaml` | plugins נטענים | agent | S |
| C2 | ✅ (4ddb3b9 · webcam_capture takePicture) · צילום אמיתי (לפני/אחרי, POD, משימה) | `camera_sheet.dart:168` | תמונה נלכדת | agent | M |
| C3 | גלריית מכשיר אמיתית | `camera_sheet.dart:347` | בחירת תמונה אמיתית | agent | S |
| C4 | העלאת תמונה ל‑R2 (presigned) | `getUploadUrl` (קיים) + קליינט | תמונה עולה לענן | agent | M |
| C5 | POD: צילום + חתימה אמיתיים | `persona_pod_sheet.dart:197,220` | מסירה עם הוכחה אמיתית | agent | M |
| C6 | אתר: צילום/GPS אמיתי (+`geolocator`) | `site_hub_screen.dart:826,1175` | מיקום/צילום אמיתי | agent | M |
| C7 | סריקת‑תוכנית: PDF/מצלמה אמיתי **או** להסתיר | `contractor_tools_sheets.dart:517` | פועל או נעלם | את+agent | M |
| C8 | ✅ (00beac4): share_plus מחווט (`state/share_seam.dart`→`Share.share`, שיתוף‑סל) · sheet‑שיתוף OS אמיתי | `state/share_seam.dart` · store/rewards | sheet‑שיתוף OS | agent | S |
| C9 | ביומטרי: `local_auth` + חיווט **או** להסתיר | settings | אימות אמיתי או נעלם | את+agent | M |
| C10 | 🟡 (685299d: iOS `NSPhotoLibraryUsageDescription` נוסף — גלריה בלי crash + תאימות App Store) · נותרו שאר הרשאות פר‑plugin | Android/iOS manifests | אין קריסת‑הרשאה | agent | S |

## Phase D — תשלום
| ID | משימה | מי | מ' |
|---|---|---|---|
| D1 | בחירת ספק סליקה (Tranzila/Cardcom/Meshulam/Grow) | את | S |
| D2 | פתיחת חשבון‑סוחר | את+חיצוני | L |
| D3 | אינטגרציית SDK ב‑checkout | `store_screen.dart:2740` · agent | L |
| D4 | קבלה/חשבונית‑מס אוטומטית | את+agent | M |

## Phase E — שירותים חיצוניים (אופציונלי ל‑v1)
| ID | משימה | היכן | מי | מ' |
|---|---|---|---|---|
| E1 | מזג‑אוויר API | `ai_hub` weather · `site diary` | את+agent | M |
| E2 | שערי‑מטבע API + המרה | `finance_hub kFxRates` · `catalog currency` | agent | M |
| E3 | AI/LLM אמיתי | `ai_hub` 7 כלים · chat bot | את+agent | L |
| E4 | 🟡 (00beac4): `printing` מחווט (`state/pdf_print_seam.dart`→`Printing.layoutPdf`, web+נייטיב) · דאטת‑הדוח עוד עשויה להיות דוגמה | `finance_hub` reports · `state/pdf_print_seam.dart` | agent | M |
| E5 | ספק email/SMS/WhatsApp | `notif channels` | את+agent | M |

## שיחות / וידאו (החלטה 13/6 — מאושר ע"י המשתמש)
> ✅ **V1+V2 בוצעו (8709129+d8cd1fe, אומת בקוד):** כפתורי 📞+💬 חיים · עץ‑ההגדרות המת הוסר · אין וידאו מזויף. וידאו בתוך‑האפליקציה (Agora, V3) = עתידי.
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| V1 | ✅ (8709129+d8cd1fe): 📞 `tel:` + 💬 `wa.me` ב‑`contact_actions` (צ׳אט+פרופיל+כרטיס‑הזמנה; `customerPhone` נחתם בהזמנה) + `url_launcher_seam` נבדק · empty-guard=אפס‑רגרסיה | `widgets/contact_actions.dart` · `url_launcher_seam.dart` | לחיצה → חייגן/וואטסאפ למספר | agent | S |
| V2 | ✅ (8709129): עץ "הגדרות שיחות" המת **הוסר** מהחיפוש (דחיסת‑וידאו/צלצול/read‑receipts/...) עם הערת‑הסבר · מסך‑הצ׳אט נשמר · **אין וידאו מזויף** | `search_index.dart:340,438` | אין הגדרת‑וידאו/שיחה מתה גלויה | agent | S |
| V3 | (עתידי, אחרי launch) וידאו+קול בתוך‑האפליקציה דרך **Agora** SDK | `pubspec` + מסך‑שיחה + Agora‑token function | שיחת‑וידאו בתוך האפליקציה | את+agent | L |

## Phase F — הקמת נייטיב
| ID | משימה | היכן | מי | מ' |
|---|---|---|---|---|
| F1 | רישום iOS+Android ב‑Firebase + native `firebase_options` | console + `firebase_options.dart` | את+agent | M |
| F2 | App Check נייטיב (Play Integrity/DeviceCheck) | agent | M |
| F3 | ✅ (profile→deleteAccount+wipe) · מחיקת‑חשבון מלאה (users/{uid}+data) | `auth_state.deleteAccount` + function | agent | M |
| F4 | APNS key + iOS Push capability | Xcode + Firebase | את+agent | S |
| F5 | Android notif channels + אייקון‑התראה | agent | S |
| F6 | **אייקון‑מותג כתום** (כרגע ברירת‑מחדל כחולה של Flutter!) · favicon/PWA/launcher · splash · version · bundle‑id סופי | agent+את | M |

> ✅ **תוקן (run 27428741969 ✓, 12/6):** היה חוסם — בניית Android (AAB ל‑Play) נכשלת — AGP 8.7.0 ישן מדי; תלויות androidx (core 1.18, activity 1.12) דורשות **8.9.1+**. תיקון: לבמפ AGP→8.9.1 + Gradle תואם ב‑`android/settings.gradle`/wrapper. שייך ל‑Phase F. **S**.

## Phase G — הקשחת שרת
| ID | משימה | היכן | מי | מ' |
|---|---|---|---|---|
| G1 | ✅ (5de11d8) · אינדקסים מורכבים (ל‑A5/A9) | `firestore.indexes.json` | agent | S |
| G2 | ✅ (5de11d8) · הקשחת rules (ownership) + emulator tests | `firestore.rules` + rules_test | agent | M |
| G3 | אכיפת App Check | console + agent | את+agent | S |
| G4 | Crashlytics + Analytics אמיתי | agent | M |
| G5 | התראות‑תקציב Blaze | console | את | S |
| G6 | גיבוי/ייצוא Firestore | console | את+agent | S |

## Phase H — QA
| ID | משימה | מי | מ' |
|---|---|---|---|
| H1 | עדכון ~1,953 בדיקות אחרי uid | agent | M |
| H2 | מטריצת מכשירים אמיתית (iOS/Android) | את+agent | M |
| H3 | beta: TestFlight + Google closed | את+agent | M |
| H4 | חשבון‑דמו לבודק אפל + Review notes | את+agent | S |

## Phase I — משפטי/תאימות
| ID | משימה | מי | מ' |
|---|---|---|---|
| I1 | תקנון + פרטיות אמיתיים | את(עו"ד) | M |
| I2 | מילוי `[שם החברה]` | `legal_texts.dart` · את | S |
| I3 | נגישות (חוק) + a11y באפליקציה | את+agent | M |
| I4 | רישום עוסק/חברה + חשבוניות | את+חיצוני | L |
| I5 | דירוג‑גיל + export compliance | את | S |
| I6 | כתובת‑תמיכה + מדיניות מחיקה פומבית | את+agent | S |

## Phase J — נכסי‑חנות + הגשה
| ID | משימה | מי | מ' |
|---|---|---|---|
| J1 | Apple: ASC, certs, Privacy labels, export | את+agent | M |
| J2 | Google: Console, App Signing, Data Safety, content rating | את+agent | M |
| J3 | צילומי‑מסך לכל גודל + feature graphic + אייקון | את+agent | M |
| J4 | תיאורים + מילות‑מפתח | את+agent | S |
| J5 | חשבונות: Apple $99 · Google $25 | את | S |
| J6 | Google closed‑test 14 יום | את+חיצוני | L |
| J7 | הגשה + ביקורת | חיצוני | L |

## Domains
| ID | משימה | מי | מ' |
|---|---|---|---|
| DM1 | ✅ buildsmart-il.com חי | — | — |
| DM2 | חיבור בניהחכמה.ישראל + SSL | את+agent | S |
| DM3 | redirect + הדלקת השרת האמיתי על הדומיין כשמוכן | את+agent | S |

---

## ספירה
~90 משימות‑מיקרו. **חוסם‑השקה = Phase A (14) + B (8).** השאר מקבילי/בעדכונים.
**סדר מומלץ:** A → G1‑G2 (אינדקסים+rules) → B → H → F → I → J. C/D/E בעדכונים אחרי launch ראשוני.
