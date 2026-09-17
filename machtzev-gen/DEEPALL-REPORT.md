# דוח-סיכונים deepall · 54 מנועים עם סיכון (3 🔴 קריטי) · נסרקו 867
# הצורה מזוהה; ההכרעה תחומית לבן-אדם. גבול: סיכונים סמנטיים לא-נתפסים.

🔴 mergeSupporterInto  (src/lib/dedup.ts)
   🟡 בליעה-שקטה: 'nextNote' מאוחד keep.nextNote || drop.nextNote — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'phone' מאוחד keep.phone || drop.phone — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'email' מאוחד keep.email || drop.email — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'address' מאוחד keep.address || drop.address — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'city' מאוחד keep.city || drop.city — אם שונים, אחד אובד בשקט
   🔴 בליעה-שקטה: 'idNum' מאוחד keep.idNum || drop.idNum — אם שונים, אחד אובד בשקט (קריטי — זהות/כסף!)
   🟡 בליעה-שקטה: 'cat' מאוחד keep.cat || drop.cat — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'forWho' מאוחד keep.forWho || drop.forWho — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'nextDate' מאוחד keep.nextDate || drop.nextDate — אם שונים, אחד אובד בשקט
   🔴 בליעה-שקטה: 'extId' מאוחד keep.extId || drop.extId — אם שונים, אחד אובד בשקט (קריטי — זהות/כסף!)
   🔴 בליעה-שקטה: 'hok' מאוחד keep.hok || drop.hok — אם שונים, אחד אובד בשקט (קריטי — זהות/כסף!)
   🟡 בליעה-שקטה: 'ayin' מאוחד keep.ayin || drop.ayin — אם שונים, אחד אובד בשקט
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🔴 migrate  (src/store/persist.ts)
   🟡 בליעה-שקטה: 'security' מאוחד db.security ?? base.security — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'first' מאוחד agg.first || s.first — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'last' מאוחד agg.last || s.last — אם שונים, אחד אובד בשקט
   🔴 רצף-מונה: מונה (seq++) בונה מזהה — ודא אי-חורים/אי-כפל (רציפות קבלות-מס); אין הוכחת-רצף בגוף
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🔴 planRidRenumber  (src/store/persist.ts)
   🔴 רצף-מונה: מונה (seq++) בונה מזהה — ודא אי-חורים/אי-כפל (רציפות קבלות-מס); אין הוכחת-רצף בגוף
🟡 blockReason  (src/components/calendar/calLib.ts)
   🟡 קבוע-קסם: '16' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '21' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '20' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 buildCustomExport  (src/lib/customExport.ts)
   🟡 בליעה-שקטה: 'phone' מאוחד m.phone || fam.phone — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'length' מאוחד dons.length || answers.length — אם שונים, אחד אובד בשקט
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 buildSlots  (src/components/diary/lib.ts)
   🟡 קבוע-קסם: '96' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '900' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '960' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 orbitTheme  (src/lib/orbitTheme.ts)
   🟡 קבוע-קסם: '15' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '70' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '265' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 paretoReport  (src/components/supporters/pareto.ts)
   🟡 קבוע-קסם: '20' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '50' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '80' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 supScore  (src/components/supporters/lib.ts)
   🟡 קבוע-קסם: '5000' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '2000' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '500' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 supTier  (src/components/supporters/lib.ts)
   🟡 קבוע-קסם: '800' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '600' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '400' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 askClaude  (src/lib/ai.ts)
   🟡 קבוע-קסם: '401' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '429' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 buildWallData  (src/components/wall/wallData.ts)
   🟡 קבוע-קסם: '700' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 gem  (src/lib/hebrew.ts)
   🟡 קבוע-קסם: '15' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '16' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 holidayOf  (src/lib/hebrew.ts)
   🟡 קבוע-קסם: '18' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '11' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 itemOf  (src/components/shop/lib.ts)
   🟡 בליעה-שקטה: 'value' מאוחד comp.value ?? item.value — אם שונים, אחד אובד בשקט
   🟡 בליעה-שקטה: 'basePrice' מאוחד comp.basePrice ?? item.basePrice — אם שונים, אחד אובד בשקט
🟡 normalizeTelephony  (src/lib/config.ts)
   🟡 קבוע-קסם: '164' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '20' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 runAudit  (src/lib/audit.ts)
   🟡 קבוע-קסם: '25' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 tierOf  (src/components/families/lib.ts)
   🟡 קבוע-קסם: '950' מקובע בהשוואה — מועמד למדיניות/הגדרה
   🟡 קבוע-קסם: '800' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 annualReportLines  (src/lib/annualReport.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 askMaor  (src/components/supporters/askMaor.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 attentionItems  (src/components/home/homeData.ts)
   🟡 קבוע-קסם: '500' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 boxTotal  (src/components/tzedaka/lib.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 buildHandoffHtml  (src/components/builder/handoff.ts)
   🟡 בליעה-שקטה: 'length' מאוחד liveSold.length || roadSold.length — אם שונים, אחד אובד בשקט
🟡 buildPodium  (src/components/wall/wallData.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 carouselItems  (src/components/home/homeData.ts)
   🟡 קבוע-קסם: '14' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 classContacts  (src/components/courses/broadcast.ts)
   🟡 בליעה-שקטה: 'phone' מאוחד f.phone || m.phone — אם שונים, אחד אובד בשקט
🟡 cockpitCollectedThisMonth  (src/components/supporters/cockpit.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 collectionList  (src/components/courses/collection.ts)
   🟡 בליעה-שקטה: 'phone' מאוחד f.phone || m.phone — אם שונים, אחד אובד בשקט
🟡 computeQuote  (src/lib/pricing.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 decryptDoc  (src/lib/cloudCrypto.ts)
   🟡 JSON.parse-לא-מוגן: JSON.parse בלי try/catch — נתון-פגום מפיל את הפונקציה (עטוף ב-try או ולידציה)
🟡 donorSignals  (src/components/supporters/signals.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 famHistoryOf  (src/components/families/lib.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 fmtDateTime  (src/components/settings/helpers.ts)
   🟡 קבוע-קסם: '15' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 hokMonthlyTotal  (src/components/supporters/lib.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 holidayNames  (src/components/shop/lib.ts)
   🟡 קבוע-קסם: '400' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 integerInWords  (src/lib/hebrewNumber.ts)
   🟡 קבוע-קסם: '999' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 makeupEligibility  (src/components/diary/lib.ts)
   🟡 קבוע-קסם: '48' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 managementMetrics  (src/components/reports/management.tsx)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 matchIncomingToPlanned  (src/lib/plannedMatch.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 nextOccurIso  (src/components/calendar/calLib.ts)
   🟡 קבוע-קסם: '400' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 paidInRange  (src/components/reports/lib.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 paidOf  (src/components/courses/lib.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 pendingIls  (src/components/supporters/planned.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 pendingUsd  (src/components/supporters/planned.ts)
   🟡 חשבון-כסף-בצפים: סכימת סכומים ב-+/* על float — סיכון-עיגול מצטבר (עדיף אגורות)
🟡 planNedarimSync  (src/lib/nedarimSync.ts)
   🟡 קבוע-קסם: '40' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 teamCsvRows  (src/components/platform/teamIntel.ts)
   🟡 קבוע-קסם: '99' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 validateHebMonthNames  (src/lib/hebdate.ts)
   🟡 קבוע-קסם: '440' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 waDigits  (src/lib/wa.ts)
   🟡 קבוע-קסם: '15' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 workerIntel  (src/components/platform/teamIntel.ts)
   🟡 קבוע-קסם: '14' מקובע בהשוואה — מועמד למדיניות/הגדרה
🟡 writeOrgCloudConfig  (src/lib/cloudConfig.ts)
   🟡 JSON.parse-לא-מוגן: JSON.parse בלי try/catch — נתון-פגום מפיל את הפונקציה (עטוף ב-try או ולידציה)
🟡 writeOrgCloudDoc  (src/lib/cloudConfig.ts)
   🟡 JSON.parse-לא-מוגן: JSON.parse בלי try/catch — נתון-פגום מפיל את הפונקציה (עטוף ב-try או ולידציה)
🟡 writeOrgJoinRequest  (src/lib/cloudConfig.ts)
   🟡 JSON.parse-לא-מוגן: JSON.parse בלי try/catch — נתון-פגום מפיל את הפונקציה (עטוף ב-try או ולידציה)
🟡 writeOrgLead  (src/lib/cloudConfig.ts)
   🟡 JSON.parse-לא-מוגן: JSON.parse בלי try/catch — נתון-פגום מפיל את הפונקציה (עטוף ב-try או ולידציה)
🟡 writeOrgRequest  (src/lib/cloudConfig.ts)
   🟡 JSON.parse-לא-מוגן: JSON.parse בלי try/catch — נתון-פגום מפיל את הפונקציה (עטוף ב-try או ולידציה)