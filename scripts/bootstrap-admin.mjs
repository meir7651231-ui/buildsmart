// One-time bootstrap: grant the `admin: true` custom claim to the test account
// so a real (rules-enforced) Firestore write can be verified end to end.
//
// WHY THIS EXISTS: roles live as Firebase Auth CUSTOM CLAIMS, never as a
// client-writable field (functions/src/index.ts, firestore.rules S5). There is
// no Firebase console UI for custom claims — the FIRST admin must be set with
// the Admin SDK (the chicken-and-egg the setRole callable documents). After
// this account works, the admin can assign every other role in-app via setRole,
// and THIS script + its workflow should be deleted.
//
// Runs in CI with GOOGLE_APPLICATION_CREDENTIALS pointing at the deploy service
// account JSON (Application Default Credentials).
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

const email = (process.env.BS_EMAIL || 'test@buildsmart.co.il').trim();
const password = (process.env.BS_PASSWORD || 'Test123456').trim();

initializeApp({ credential: applicationDefault() });
const auth = getAuth();

let user;
try {
  user = await auth.getUserByEmail(email);
  // Reset the password to the known value so the documented test creds always
  // work, and make sure the account is enabled + email-verified.
  await auth.updateUser(user.uid, { password, emailVerified: true, disabled: false });
  console.log(`Found existing user, reset creds: uid=${user.uid}`);
} catch (e) {
  if (e && e.code === 'auth/user-not-found') {
    user = await auth.createUser({ email, password, emailVerified: true });
    console.log(`Created user: uid=${user.uid}`);
  } else {
    throw e;
  }
}

// Merge over existing claims (keep any role/roles already there) and add admin.
const claims = { ...(user.customClaims || {}), admin: true };
await auth.setCustomUserClaims(user.uid, claims);

console.log('======================================================');
console.log(`✅ admin claim set for ${email}`);
console.log(`   uid   = ${user.uid}`);
console.log(`   login = ${email} / ${password}`);
console.log('   -> log OUT and back IN on the app to refresh the token,');
console.log('      then create an order: it will now persist.');
console.log('======================================================');
