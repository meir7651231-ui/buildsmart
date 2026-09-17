# סכמה ⇒ פעולות-יסוד (shape-ops · G2)

**54** ישויות · **492** שדות ⇒ ops נגזרים מצורת-הטיפוס בלבד.

## כיסוי רתמת-הזהב (חלקיקי compose-engine שנגזרים מהצורה)
| מודול | ישויות | חלקיקים | נגזרים | חסרים |
|---|---|---|---|---|
| inv | WarehouseItem, ShopItem, ShopIntake, MatEntry | 25 | 24 | movements:log |
| stu | Member, Family, Enrollment | 6 | 6 | — |
| par | Family, Member | 4 | 3 | par.details:details |
| att | Absence, Enrollment, CourseSession, Course | 5 | 5 | — |
| crs | Course, Enrollment, Room, CourseSession, CourseFile | 4 | 4 | — |
| tch | Teacher, Course, CourseSession | 4 | 4 | — |
| rm | Room, OrgEvent, Course, CourseSession | 4 | 4 | — |
| fee | Payment, Hok, Enrollment, Supporter, Donation | 4 | 4 | — |
| dash | WorkTask, AuditEntry, Enrollment, Payment, Absence | 4 | 4 | — |

**סה"כ 58/60 (97%)**

## ops פר-ישות
| ישות | שדות | ops |
|---|---|---|
| Member | 17 | broadcast · calendar · certs · channel · contact · expiry · export · filter · flag · form · holidayGuard · identity · kpi · lifecycle · panel · partition · perm · pipeline · search · states · table · temporal · text · triage · workflow |
| CredLogEntry | 3 | aggregate · balance · calendar · expiry · export · filter · form · holidayGuard · kpi · measure · panel · perm · search · stat · states · table · temporal · text · trend |
| FamilyCred | 2 | aggregate · attendance · collection · export · filter · form · import · kpi · log · makeups · measure · panel · perm · roster · search · stat · states · table |
| FamilyDoc | 3 | calendar · expiry · export · filter · form · holidayGuard · identity · kpi · panel · perm · search · states · table · temporal · text |
| Family | 25 | aggregate · attendance · balance · broadcast · calendar · certs · channel · collection · contact · enrollment · expiry · export · filter · flag · form · holidayGuard · identity · import · kpi · lifecycle · list · makeups · measure · panel · partition · perm · pipeline · risk · roster · search · stat · states · table · temporal · text · trend · triage · workflow |
| CourseSession | 3 | export · filter · form · kpi · panel · perm · search · slot · states · table · text · weekly |
| CourseFile | 6 | aggregate · enrollment · export · filter · form · identity · kpi · lifecycle · measure · panel · partition · perm · pipeline · risk · search · stat · states · table · text · triage · workflow |
| Course | 39 | aggregate · attendance · balance · calendar · certs · clash · collection · details · enrollment · expiry · export · filter · flag · form · hok · holidayGuard · identity · import · kpi · lifecycle · list · load · log · makeups · measure · panel · partition · perm · pipeline · range · relation · risk · roster · search · slot · stat · states · table · temporal · text · trend · triage · weekly · workflow |
| Absence | 6 | calendar · certs · clash · expiry · export · filter · flag · form · holidayGuard · kpi · panel · partition · perm · range · search · states · table · temporal · text |
| Payment | 4 | aggregate · balance · calendar · expiry · export · filter · form · hok · holidayGuard · kpi · measure · panel · perm · search · stat · states · table · temporal · text · trend |
| Enrollment | 26 | aggregate · attendance · balance · calendar · certs · clash · collection · details · enrollment · expiry · export · filter · flag · form · hok · holidayGuard · identity · import · kpi · lifecycle · list · load · log · makeups · measure · panel · partition · perm · pipeline · range · relation · risk · roster · search · stat · states · table · temporal · text · trend · triage · workflow |
| Teacher | 19 | aggregate · balance · broadcast · calendar · certs · channel · contact · enrollment · expiry · export · filter · flag · form · holidayGuard · identity · kpi · lifecycle · measure · panel · partition · perm · pipeline · risk · search · stat · states · table · temporal · text · trend · triage · workflow |
| Room | 12 | aggregate · enrollment · export · filter · flag · flags · form · identity · kpi · measure · panel · partition · perm · risk · search · slot · stat · states · table · text · weekly |
| OrgEvent | 13 | aggregate · balance · calendar · certs · clash · details · enrollment · expiry · export · filter · flag · form · hok · holidayGuard · identity · kpi · lifecycle · load · measure · panel · partition · perm · pipeline · range · relation · risk · search · slot · stat · states · table · temporal · text · trend · triage · weekly · workflow |
| Donation | 7 | aggregate · balance · calendar · enrollment · expiry · export · filter · form · hok · holidayGuard · kpi · lifecycle · measure · panel · partition · perm · pipeline · risk · search · stat · states · table · temporal · text · trend · triage · workflow |
| AyinName | 8 | aggregate · enrollment · export · filter · flag · form · identity · kpi · measure · panel · partition · perm · relation-many · risk · search · stat · states · table · text |
| KitItem | 2 | export · filter · flag · form · kpi · panel · partition · perm · search · states · table · text |
| WarehouseItem | 5 | aggregate · export · filter · form · hok · identity · kpi · measure · panel · perm · search · stat · states · table · text |
| AyinAnswer | 2 | calendar · expiry · export · filter · form · holidayGuard · kpi · panel · perm · search · states · table · temporal · text |
| TimeEntry | 4 | aggregate · balance · calendar · expiry · export · filter · form · holidayGuard · kpi · measure · panel · perm · search · stat · states · table · temporal · text · trend |
| MatEntry | 3 | aggregate · export · filter · form · hok · kpi · measure · panel · perm · search · stat · states · table · text |
| AyinLog | 3 | aggregate · balance · calendar · expiry · export · filter · form · holidayGuard · kpi · measure · panel · perm · search · stat · states · table · temporal · text · trend |
| AyinCase | 15 | attendance · calendar · certs · clash · collection · expiry · export · filter · flag · form · holidayGuard · import · kpi · lifecycle · list · log · makeups · panel · partition · perm · pipeline · range · roster · search · slot · states · table · temporal · text · triage · weekly · workflow |
| Hok | 8 | aggregate · balance · calendar · certs · enrollment · expiry · export · filter · flag · form · hok · holidayGuard · kpi · lifecycle · measure · panel · partition · perm · pipeline · risk · search · stat · states · table · temporal · text · trend · triage · workflow |
| Supporter | 24 | aggregate · attendance · balance · broadcast · calendar · channel · clash · collection · contact · details · expiry · export · filter · form · holidayGuard · identity · import · kpi · list · load · log · makeups · measure · panel · perm · range · relation · roster · search · stat · states · table · temporal · text · trend |
| NotifPrefs | 4 | export · filter · flag · form · kpi · panel · partition · perm · search · states · table |
| ReportPrefs | 4 | export · filter · flag · form · kpi · panel · partition · perm · search · states · table |
| QuoteTemplate | 3 | export · filter · form · identity · kpi · panel · perm · search · states · table · text |
| DialLogEntry | 4 | export · filter · form · identity · kpi · lifecycle · panel · partition · perm · pipeline · search · states · table · text · triage · workflow |
| CallEntry | 2 | calendar · expiry · export · filter · form · holidayGuard · kpi · lifecycle · panel · partition · perm · pipeline · search · states · table · temporal · triage · workflow |
| DialerCampaign | 5 | aggregate · attendance · collection · export · filter · form · hok · import · kpi · log · makeups · measure · panel · perm · relation-many · roster · search · stat · states · table · text |
| UiPrefs | 9 | attendance · collection · export · filter · form · import · kpi · lifecycle · list · makeups · panel · partition · perm · pipeline · roster · search · states · table · text · triage · workflow |
| TzScoreEntry | 3 | aggregate · balance · calendar · expiry · export · filter · form · holidayGuard · kpi · measure · panel · perm · search · stat · states · table · temporal · text · trend |
| TzCoordinator | 10 | aggregate · attendance · balance · broadcast · calendar · certs · channel · collection · contact · details · enrollment · expiry · export · filter · flag · form · holidayGuard · identity · import · kpi · load · log · makeups · measure · panel · partition · perm · relation · risk · roster · search · stat · states · table · temporal · text · trend |
| TzCollection | 5 | aggregate · balance · calendar · details · expiry · export · filter · form · hok · holidayGuard · identity · kpi · load · measure · panel · perm · relation · search · stat · states · table · temporal · text · trend |
| TzBox | 9 | attendance · calendar · collection · details · expiry · export · filter · form · holidayGuard · identity · import · kpi · lifecycle · list · load · makeups · panel · partition · perm · pipeline · relation · roster · search · states · table · temporal · text · triage · workflow |
| TzCampaign | 7 | aggregate · balance · calendar · certs · clash · enrollment · expiry · export · filter · flag · form · holidayGuard · identity · kpi · measure · panel · partition · perm · range · risk · search · stat · states · table · temporal · text · trend |
| TzEvent | 9 | calendar · certs · clash · details · expiry · export · filter · flag · form · holidayGuard · identity · kpi · lifecycle · load · panel · partition · perm · pipeline · range · relation · search · slot · states · table · temporal · text · triage · weekly · workflow |
| ShopItem | 13 | aggregate · details · enrollment · export · filter · flag · form · identity · kpi · lifecycle · list · load · measure · panel · partition · perm · pipeline · relation · risk · search · stat · states · table · text · triage · workflow |
| ShopComponent | 10 | aggregate · details · enrollment · export · filter · form · identity · kpi · lifecycle · load · measure · panel · partition · perm · pipeline · relation · risk · search · stat · states · table · text · triage · workflow |
| ShopIntake | 9 | aggregate · balance · calendar · clash · details · enrollment · expiry · export · filter · form · hok · holidayGuard · identity · kpi · lifecycle · load · measure · panel · partition · perm · pipeline · range · relation · risk · search · stat · states · table · temporal · text · trend · triage · workflow |
| ShopProduct | 7 | attendance · collection · export · filter · flag · form · identity · import · kpi · list · makeups · panel · partition · perm · roster · search · states · table · text |
| ShopStore | 6 | broadcast · channel · contact · export · filter · flag · form · identity · kpi · panel · partition · perm · search · states · table · text |
| ShopCriterion | 4 | aggregate · export · filter · form · identity · kpi · measure · panel · perm · search · stat · states · table · text |
| ShopRedemption | 10 | aggregate · balance · calendar · clash · details · expiry · export · filter · form · hok · holidayGuard · identity · kpi · load · measure · panel · perm · range · relation · search · stat · states · table · temporal · text · trend |
| ShopAssignment | 9 | attendance · calendar · collection · details · expiry · export · filter · form · holidayGuard · identity · import · kpi · lifecycle · list · load · makeups · panel · partition · perm · pipeline · relation · relation-many · roster · search · states · table · temporal · text · triage · workflow |
| ShopEvent | 10 | calendar · certs · clash · details · expiry · export · filter · flag · form · holidayGuard · identity · kpi · lifecycle · load · panel · partition · perm · pipeline · range · relation · search · slot · states · table · temporal · text · triage · weekly · workflow |
| Volunteer | 8 | aggregate · balance · broadcast · calendar · certs · channel · contact · enrollment · expiry · export · filter · flag · form · holidayGuard · identity · kpi · measure · panel · partition · perm · risk · search · stat · states · table · temporal · text · trend |
| WorkTask | 10 | export · filter · form · kpi · lifecycle · panel · partition · perm · pipeline · search · states · table · text · triage · workflow |
| Delivery | 9 | calendar · details · expiry · export · filter · form · holidayGuard · identity · kpi · lifecycle · load · panel · partition · perm · pipeline · relation · search · states · table · temporal · text · triage · workflow |
| DistributionDay | 6 | calendar · certs · clash · expiry · export · filter · flag · form · holidayGuard · identity · kpi · panel · partition · perm · range · search · states · table · temporal · text |
| Db | 41 | aggregate · attendance · collection · export · filter · flags · form · import · kpi · list · log · makeups · measure · panel · perm · roster · search · stat · states · table · text |
| AuditEntry | 4 | export · filter · form · kpi · panel · perm · search · states · table · text |
| SecurityCfg | 3 | export · filter · form · kpi · list · panel · perm · search · states · table · text |
