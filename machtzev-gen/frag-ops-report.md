# ייחוס-ops פר-שבר (frag-ops · G8b)

557 שברים עם מפתחות-דאטה ⇒ G2-ops · הסכמת-מודול על 25 ישויות חזקות: top-1 6 · top-2 8

| מודול | שברים-מיוחסים | G2-ops |
|---|---|---|
| schoolos.dart | 33 | aggregate calendar expiry flag holidayGuard measure partition stat temporal text |
| schoolos_students.dart | 85 | calendar channel expiry flag flags holidayGuard identity list partition relation slot temporal text weekly |
| schoolos_attendance.dart | 34 | aggregate flag identity measure partition relation stat text |
| schoolos_courses.dart | 98 | aggregate calendar channel expiry flag holidayGuard identity list measure partition relation slot stat temporal text weekly |
| schoolos_teachers.dart | 66 | aggregate calendar expiry flags holidayGuard identity list measure relation slot stat temporal text weekly |
| schoolos_rooms.dart | 62 | aggregate calendar expiry flag flags holidayGuard identity measure partition relation slot stat temporal text weekly |
| schoolos_fees.dart | 81 | aggregate calendar channel expiry flag flags holidayGuard identity list measure partition stat temporal text |
| schoolos_parents.dart | 75 | aggregate calendar expiry flag flags holidayGuard identity list measure partition relation slot stat temporal text weekly |
| schoolos_dashboard.dart | 23 | aggregate calendar expiry flags holidayGuard list measure stat temporal text |

## בורר-לפי-שברים מול בורר-לפי-שמות
| ישות | שמות ⇒ | שברים ⇒ (score·n) | הסכמה |
|---|---|---|---|
| Member | students | fees (2.457·73) · dashboard (2.174·18) | ✗ |
| Family | students | fees (3.37·79) · dashboard (3.13·22) | ✗ |
| CourseFile | courses | schoolos (2.455·31) · teachers (1.924·56) | ✗ |
| Course | courses | teachers (3.576·66) · fees (3.247·77) | ✗ |
| Payment | fees | dashboard (3.087·22) · schoolos (2.909·32) | ✗ |
| Enrollment | fees | fees (3.247·77) · teachers (3.152·65) | ✓ |
| Teacher | students | fees (3.198·78) · dashboard (3.087·22) | ✗ |
| Room | rooms | rooms (2.5·62) · schoolos (2.485·31) | ✓ |
| OrgEvent | courses | teachers (3.439·66) · dashboard (3.087·22) | ✗ |
| Donation | fees | dashboard (3.087·22) · schoolos (2.939·32) | ✗ |
| Hok | fees | dashboard (3.087·22) · schoolos (2.97·32) | ✗ |
| Supporter | fees | fees (3.321·79) · teachers (3.152·65) | ✓ |
| DialLogEntry | fees | rooms (1.435·57) · parents (1.307·66) | ✗ |
| TzCoordinator | fees | fees (3.198·78) · dashboard (3.087·22) | ✓ |
| TzCollection | fees | dashboard (3.087·22) · fees (3.025·76) | ~ |
| TzCampaign | courses | dashboard (3.087·22) · fees (3.074·76) | ✗ |
| TzEvent | courses | teachers (2.576·63) · parents (2.52·72) | ✗ |
| ShopItem | courses | schoolos (2.485·31) · teachers (2.242·57) | ✗ |
| ShopComponent | courses | schoolos (2.455·31) · teachers (2.106·56) | ✗ |
| ShopProduct | rooms | rooms (1.581·57) · parents (1.573·66) | ✓ |
| ShopStore | students | rooms (1.581·57) · parents (1.413·66) | ✗ |
| ShopRedemption | fees | dashboard (3.087·22) · fees (3.025·76) | ~ |
| ShopEvent | courses | teachers (2.576·63) · parents (2.52·72) | ✗ |
| Volunteer | fees | fees (3.198·78) · dashboard (3.087·22) | ✓ |
| WorkTask | dashboard | rooms (0.823·45) · schoolos (0.727·23) | ✗ |
