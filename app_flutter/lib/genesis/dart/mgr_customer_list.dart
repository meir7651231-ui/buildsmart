// ⚛️ אטום-Dart (דרגת-חוזה) · mgrCustomerList
// תפקיד: אגרגציית-קונים — קיפול הזמנות לרשומות-לקוח (מונה+מחזור), ממוינות יורד לפי מחזור.
// מוצא: buildsmart/app_flutter/lib/logic/manager_dashboard.dart:279-302
//        (‏mgrCustomerList; חוק-4 — התנהגות זהה).
// אחים-שסוקטו/הוטבעו:
//   • `ManagerCustomer` (data-class-אח) ⇒ **הוטבע verbatim** מגוף-הטיוטה (שדות,
//     בנאי, copyWith — קוד זהה; פרוזת-התיעוד הותמצתה בלבד, לא הקוד).
//   • `ManagerOrder` (טיפוס-שכן) — המקור manager_dashboard.dart אינו בריפו
//     (grep ⇒ ריק). האטום קורא רק `.who` (String) ו-`.sum` (int) ⇒ **הוטבע
//     data-class מינימלי מוסק** מגוף-הטיוטה (חוק-8/דיבר 11, מתועד). דגל-סיכון:
//     אם למקור שדות נוספים — האגרגציה כאן עדיין ביט-זהה (קוראת רק who/sum).
//   • `kManagerOrderSeed` (const-זרע, ברירת-המחדל האופציונלית) ⇒ **הושמט**:
//     const-קטלוג לא-נגיש; הפרמטר `orders` הופך ל-**חובה** (חוק-3). האגרגציה
//     עצמה ‏(279-302) ביט-זהה — רק ברירת-המחדל נשמטה.
// טוהר: אפס import (dart:core בלבד).
//
// קלט:  orders — הזמנות (List<ManagerOrder>; במקור אופציונלי עם זרע).
// פלט:  List<ManagerCustomer> — רשומה פר-קונה (לפי `who`), ממוינת יורד לפי totalSpend.

// הוטבע מוסק (טיפוס-שכן): המקור קורא רק who+sum.
class ManagerOrder {
  const ManagerOrder({required this.who, required this.sum});
  final String who; // שם-הקונה (מפתח-האגרגציה).
  final int sum; // סכום-ההזמנה.
}

/// Buyer aggregate: one [ManagerCustomer] per distinct `who`, sorted by spend
/// descending. Verbatim behaviour of manager_dashboard.dart:279-302 (the const
/// seed default dropped; `orders` is required).
List<ManagerCustomer> mgrCustomerList(List<ManagerOrder> orders) {
  final src = orders;
  final byBuyer = <String, ManagerCustomer>{};
  for (final o in src) {
    final cur = byBuyer[o.who];
    if (cur == null) {
      byBuyer[o.who] = ManagerCustomer(
        name: o.who,
        orderCount: 1,
        totalSpend: o.sum,
        // fake-data-sweep 1א: real credit comes from computeCredit; the sync seed is 0.
        creditLimit: 0,
      );
    } else {
      byBuyer[o.who] = ManagerCustomer(
        name: cur.name,
        orderCount: cur.orderCount + 1,
        totalSpend: cur.totalSpend + o.sum,
        creditLimit: cur.creditLimit,
      );
    }
  }
  final out = byBuyer.values.toList()
    ..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
  return out;
}

/// A buyer aggregate — M3 foundation (see [mgrCustomerList]).
/// הוטבע verbatim (data-class-אח).
class ManagerCustomer {
  const ManagerCustomer({
    required this.name,
    required this.orderCount,
    required this.totalSpend,
    required this.creditLimit,
    this.ownerId = '',
    this.phone = '',
  });

  final String name;
  final int orderCount;
  final int totalSpend;
  final int creditLimit;

  /// A11 — the owning manager's `auth.uid`, forward-ready. '' on this derived path.
  final String ownerId;

  /// #8/3c — the customer's free-text phone (derived, '' when unknown).
  final String phone;

  ManagerCustomer copyWith({
    String? name,
    int? orderCount,
    int? totalSpend,
    int? creditLimit,
    String? ownerId,
    String? phone,
  }) =>
      ManagerCustomer(
        name: name ?? this.name,
        orderCount: orderCount ?? this.orderCount,
        totalSpend: totalSpend ?? this.totalSpend,
        creditLimit: creditLimit ?? this.creditLimit,
        ownerId: ownerId ?? this.ownerId,
        phone: phone ?? this.phone,
      );
}
