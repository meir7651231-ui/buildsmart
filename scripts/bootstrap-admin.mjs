// One-time bootstrap: grant the OWNER (manager) custom claims to the Google
// account so the server (firestore.rules) treats them as the god-role AND the
// client board gate opens the manager dashboard on the Firebase-Auth path.
//
// WHY THIS EXISTS: roles live as Firebase Auth CUSTOM CLAIMS, never as a
// client-writable field (functions/src/index.ts, firestore.rules S5). There is
// no Firebase console UI for custom claims — the FIRST admin must be set with
// the Admin SDK (the chicken-and-egg the setRole callable documents). After the
// owner has the claim, they can assign every other role in-app via setRole, and
// THIS script + its workflow should be DELETED (it must not linger as a way to
// mint admins).
//
// THE CLAIM (both, on purpose):
//   • admin: true     — the firestore.rules `isAdmin()` superset (cross-user
//                       reads for the assign-sheet, setRole's caller check,
//                       review of ANY role request).
//   • role: 'manager' — a persona-id role the CLIENT reads: rolesFromClaims →
//                       boardSessionFromAuthSnapshot opens the manager board on
//                       the Firebase path (kUidScopedQueries ON). isManager()
//                       also passes from this alone.
//
// SECURITY: the owner signs in with GOOGLE — this script does NOT set a
// password (an email+password would be a backdoor into the admin account).
//
// Runs in CI with GOOGLE_APPLICATION_CREDENTIALS pointing at the deploy service
// account JSON (Application Default Credentials).
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

const email = (process.env.BS_EMAIL || 'meir7651231@gmail.com').trim();

initializeApp({ credential: applicationDefault() });
const auth = getAuth();

let user;
try {
  user = await auth.getUserByEmail(email);
  // Just ensure the account is enabled + verified — do NOT set a password
  // (the owner authenticates with Google; a known password would be a backdoor).
  await auth.updateUser(user.uid, { emailVerified: true, disabled: false });
  console.log(`Found existing user: uid=${user.uid}`);
} catch (e) {
  if (e && e.code === 'auth/user-not-found') {
    // Should not happen for the owner (they have signed in with Google, so the
    // account exists). Create a bare passwordless account if truly missing.
    user = await auth.createUser({ email, emailVerified: true });
    console.log(`Created user: uid=${user.uid}`);
  } else {
    throw e;
  }
}

// Merge over existing claims and add admin:true + role:'manager' (see header).
const claims = { ...(user.customClaims || {}), admin: true, role: 'manager' };
await auth.setCustomUserClaims(user.uid, claims);

console.log('======================================================');
console.log(`✅ admin:true + role:'manager' set for ${email}`);
console.log(`   uid = ${user.uid}`);
console.log("   -> sign OUT and back IN (Google) on the app to refresh the");
console.log('      token; the manager board then opens server-verified.');
console.log('======================================================');
