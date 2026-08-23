// ratchet — מצב-מסונן: תפקיד-שרת (claim) ⇒ active, כדי ששער-ההזמנה לא יזרוק
// את הלקוח-המסונן חזרה להרשמה (לולאת חתול-ועכבר · אימות-שטח 12.8).
import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/data/repositories/users_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('withServerRoleApproval', () {
    test('doc חסר + תפקיד-שרת ⇒ משתמש active מסונתז', () {
      final u = withServerRoleApproval(
        null,
        uid: 'U',
        roles: ['contractor'],
        email: 'a@b.com',
      );
      expect(u, isNotNull);
      expect(u!.uid, 'U');
      expect(u.status, UserStatus.active);
      expect(u.role, 'contractor');
    });

    test('doc pending + תפקיד-שרת ⇒ משודרג ל-active', () {
      final pending = const BsUser(uid: 'U', status: UserStatus.pending);
      final u = withServerRoleApproval(pending, uid: 'U', roles: ['worker']);
      expect(u!.status, UserStatus.active);
      expect(u.role, 'worker'); // מולא מה-claim
    });

    test('אין תפקיד-שרת ⇒ ללא-שינוי (זהה-התנהגות)', () {
      expect(withServerRoleApproval(null, uid: 'U', roles: const []), isNull);
      final pending = const BsUser(uid: 'U', status: UserStatus.pending);
      expect(
        withServerRoleApproval(pending, uid: 'U', roles: const []),
        same(pending),
      );
    });

    test('doc active קיים ⇒ לא-נדרס (התפקיד/סטטוס האמיתי גובר)', () {
      final active =
          const BsUser(uid: 'U', role: 'store', status: UserStatus.active);
      final u = withServerRoleApproval(active, uid: 'U', roles: ['contractor']);
      expect(u!.status, UserStatus.active);
      expect(u.role, 'store'); // לא הוחלף
    });

    test('uid ריק ⇒ ללא-שינוי (לא מסנתז זהות ריקה)', () {
      expect(withServerRoleApproval(null, uid: '', roles: ['worker']), isNull);
      expect(withServerRoleApproval(null, uid: null, roles: ['worker']), isNull);
    });
  });
}
