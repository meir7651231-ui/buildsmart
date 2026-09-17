# שכבת-הגרעין מהסכמה (core-from-shape · G6a)

49 ישויות · יחסים 32/33 פתורים · workflows 8 (2 עם אטום-מעבר · 6 סדר-הצהרה) · אירועים 35 · חוקים 383 · ערוצים 14

| ישות | מונח | שדות | יחסים | workflow | אירועים | חוקים | ערוצים |
|---|---|---|---|---|---|---|---|
| Member | בן/בת משפחה | 17 | — | — | — | 17 | phone phone2 |
| CredLogEntry | — | 3 | — | — | recorded | 3 | — |
| FamilyCred | — | 2 | — | — | — | 1 | — |
| FamilyDoc | — | 3 | — | — | added | 3 | — |
| Family | משפחה | 25 | — | status:active→pending→inactive | created | 22 | phone phone2 email |
| CourseSession | — | 3 | — | — | — | 3 | — |
| CourseFile | — | 6 | — | — | — | 5 | — |
| Course | חוג | 39 | teacherId⇒Teacher roomId⇒Room prevYearId⇒Course | — | start end | 28 | — |
| Absence | — | 6 | — | — | recorded makeup | 2 | — |
| Payment | — | 4 | — | — | recorded | 4 | — |
| Enrollment | שיבוץ | 26 | memberId⇒Member courseId⇒Course dueEventId⇒OrgEvent renewedToId⇒Enrollment | status:active→paused→ended→wait | due enrolled ended | 22 | — |
| Teacher | מורה | 19 | — | — | start | 12 | phone phone2 email payeePhone |
| Room | חדר | 12 | — | — | — | 12 | — |
| OrgEvent | — | 13 | roomId⇒Room famId⇒Family spId⇒∅(reserved) | — | recorded | 16 | — |
| Donation | תרומה | 7 | — | — | recorded | 6 | — |
| AyinName | — | 8 | — | — | — | 4 | — |
| KitItem | — | 2 | — | — | — | 2 | — |
| WarehouseItem | — | 5 | — | — | — | 5 | — |
| AyinAnswer | — | 2 | — | — | recorded | 2 | — |
| TimeEntry | — | 4 | — | — | recorded | 3 | — |
| MatEntry | — | 3 | — | — | — | 3 | — |
| AyinLog | — | 3 | — | — | recorded | 2 | — |
| AyinCase | תיק | 15 | — | stage:new→lead→eyes→answer→done [next-stage] | — | 8 | — |
| Hok | — | 8 | — | — | started | 8 | — |
| Supporter | תורם | 24 | nextEventId⇒OrgEvent | — | next | 16 | phone email |
| QuoteTemplate | — | 3 | — | — | — | 3 | — |
| DialLogEntry | חיוג | 4 | — | outcome:donated→noanswer→refused→callback→done→skip | — | 4 | — |
| CallEntry | שיחה | 2 | — | outcome:donated→noanswer→refused→callback→done→skip | at | 3 | — |
| DialerCampaign | — | 5 | — | — | — | 3 | — |
| TzScoreEntry | — | 3 | — | — | recorded | 3 | — |
| TzCoordinator | רכז | 10 | famId⇒Family memberId⇒Member | — | start | 11 | phone |
| TzCollection | — | 5 | campaignId⇒TzCampaign | — | recorded | 6 | — |
| TzBox | קופה | 9 | coordinatorId⇒TzCoordinator famId⇒Family | status:home→office→lost→retired | — | 12 | — |
| TzCampaign | מבצע | 7 | — | — | start end | 7 | — |
| TzEvent | — | 9 | coordinatorId⇒TzCoordinator boxId⇒TzBox | — | recorded | 12 | — |
| ShopItem | פריט | 13 | storeId⇒ShopStore | — | — | 10 | — |
| ShopComponent | — | 10 | itemId⇒ShopItem storeId⇒ShopStore | — | — | 9 | — |
| ShopIntake | — | 9 | itemId⇒ShopItem | — | recorded expiry | 10 | — |
| ShopProduct | מוצר | 7 | — | — | — | 5 | — |
| ShopStore | חנות | 6 | — | — | — | 6 | phone |
| ShopCriterion | קריטריון | 4 | — | — | — | 4 | — |
| ShopRedemption | — | 10 | componentId⇒ShopComponent | — | voided recorded | 8 | — |
| ShopAssignment | שיוך | 9 | productId⇒ShopProduct famId⇒Family memberId⇒Member | status:active→done→stopped | — | 11 | — |
| ShopEvent | — | 10 | assignmentId⇒ShopAssignment roomId⇒Room mainEventId⇒OrgEvent | — | recorded | 12 | — |
| Volunteer | מתנדב | 8 | — | — | created | 6 | phone |
| WorkTask | — | 10 | — | — | — | 7 | — |
| Delivery | מסירה | 9 | dayId⇒DistributionDay assignmentId⇒ShopAssignment volunteerId⇒Volunteer familyId⇒Family | status:pickup→enroute→delivered [advance-status] | delivered | 12 | — |
| DistributionDay | — | 6 | — | — | recorded created | 6 | — |
| AuditEntry | — | 4 | — | — | — | 4 | — |
