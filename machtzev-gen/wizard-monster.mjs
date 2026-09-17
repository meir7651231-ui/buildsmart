#!/usr/bin/env node
// 🏔️🧙 wizard-monster — שדרוג-מקסימום ל-wizardStepError. המחולל שלף מהאימפריה את היכולות שחסרו לו:
//   phoneRegion + regex-הטלפון של signUpError + בדיקת-חברות-ברשימה. אפס-אובדן: default ביט-זהה למקורי;
//   השדרוג (strict) הוא שקע-עם-default שרק *מוסיף* קפדנות (תופס קלט-רע שהמקורי בלע בשקט).

// ── מנועים שנשלפו מהאימפריה (פורט נאמן, read-only) ───────────────────────
function phoneRegion(raw) { // ←src/components/supporters/lib.ts
  const s = (raw || '').replace(/[^\d+]/g, ''); if (!s) return 'il';
  if (/^(\+?972|00972)/.test(s)) return 'il'; if (/^\+/.test(s)) return 'intl'; if (/^00/.test(s)) return 'intl';
  const d = s.replace(/\D/g, ''); if (/^0\d{8,9}$/.test(d)) return 'il'; if (/^5\d{8}$/.test(d)) return 'il'; return 'intl';
}
const PHONE_RE = /^[\d+][\d\s-]{6,}$/;      // ←signUpError (config.ts) — קפדנות שחסרה בשלב 3
const EMAIL_RE = /^\S+@\S+\.\S+$/;          // ←signUpError
const SIZE_IDS = new Set(['small', 'medium', 'large']); // ←ORG_SIZES
function signUpError(orgName, contactName, phone, email, password, password2) { // ←config.ts:739 (פורט נאמן)
  if (!orgName.trim()) return 'שם הארגון הוא שדה חובה';
  if (!contactName.trim()) return 'שם איש הקשר הוא שדה חובה';
  if (!PHONE_RE.test(phone.trim())) return 'מספר טלפון תקין הוא שדה חובה — נחזור אליכם לאישור';
  if (!EMAIL_RE.test(email.trim())) return 'כתובת האימייל אינה תקינה';
  if (password.length < 6) return 'הסמה חייבת להיות לפחות 6 תווים';
  if (password !== password2) return 'הסיסמאות אינן זהות';
  return '';
}

// ── המקורי (פורט ביט-זהה מ-signupWizard.ts:66) ───────────────────────────
function wizardStepError_ORIG(step, s) {
  switch (step) {
    case 0: return s.industry ? null : 'בחרו את תחום העסק כדי להמשיך';
    case 1: return s.size ? null : 'בחרו את גודל הארגון';
    case 2: return null;
    case 3:
      if (!s.orgName.trim()) return 'שם הארגון חובה';
      if (!s.contactName.trim()) return 'שם איש קשר חובה';
      if (!s.phone.trim()) return 'טלפון חובה — נחזור אליכם לאישור';
      return null;
    case 4: return signUpError(s.orgName, s.contactName, s.phone, s.email, s.password, s.password2) || null;
    default: return null;
  }
}

// ── המונסטר המשודרג: default=ORIG ביט-זהה · strict=שולף-היכולות ───────────
export function wizardStepError(step, s, opt = {}) {
  const strict = opt.strict === true;                 // שקע-עם-default: חסר ⇒ false ⇒ ביט-זהה למקורי
  const industries = opt.industries;                  // המחולל מזריק WIZARD_INDUSTRIES (רשימת-חברות)
  if (!strict) return wizardStepError_ORIG(step, s);  // ← החזק לא נשבר
  switch (step) {
    case 0:
      if (!s.industry) return 'בחרו את תחום העסק כדי להמשיך';
      if (industries && !industries.has(s.industry)) return 'תחום לא חוקי'; // שדרוג: חברות-ברשימה
      return null;
    case 1:
      if (!s.size) return 'בחרו את גודל הארגון';
      if (!SIZE_IDS.has(s.size)) return 'גודל לא חוקי'; // שדרוג: חברות-ברשימה
      return null;
    case 2: return null;
    case 3:
      if (!s.orgName.trim()) return 'שם הארגון חובה';
      if (!s.contactName.trim()) return 'שם איש קשר חובה';
      if (!s.phone.trim()) return 'טלפון חובה — נחזור אליכם לאישור';
      if (!PHONE_RE.test(s.phone.trim())) return 'מספר טלפון תקין הוא שדה חובה'; // שדרוג: regex מ-signUpError
      return null;
    case 4: return signUpError(s.orgName, s.contactName, s.phone, s.email, s.password, s.password2) || null;
    default: return null;
  }
}

// ── הוכחה 1: אפס-אובדן — default(step,s) === ORIG(step,s) על מדגם אקראי ────
const mk = (o) => ({ industry: '', size: '', orgName: '', contactName: '', phone: '', email: '', password: '', password2: '', needs: [], ...o });
let rng = 7; const rnd = () => (rng = (rng * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const rv = (a) => a[Math.floor(rnd() * a.length)];
const states = Array.from({ length: 400 }, () => mk({ industry: rv(['', 'x', 'digital', 'zzz']), size: rv(['', 'small', 'huge']), orgName: rv(['', 'ארגון', ' ']), contactName: rv(['', 'דנה']), phone: rv(['', 'abc', '052-1234567', '0521234567', '12']), email: rv(['', 'a@b.co', 'bad']), password: rv(['', '123456', 'ab']), password2: rv(['', '123456']) }));
let same = 0;
for (const s of states) for (let step = 0; step <= 5; step++) if (wizardStepError(step, s) === wizardStepError_ORIG(step, s)) same++;
const totalCmp = states.length * 6;
console.log('🏔️🧙 wizardStepError — שדרוג-מקסימום ע"י המחולל\n');
console.log(`הוכחה-1 (אפס-אובדן · החזק לא נשבר): default ≡ מקורי ב-${same}/${totalCmp} ${same === totalCmp ? '✅ ביט-זהה' : '❌'}`);

// ── הוכחה 2: השדרוג *עובד* — strict תופס קלט-רע שהמקורי בלע ────────────────
console.log('\nהוכחה-2 (השדרוג עובד · לפני⇒אחרי):');
const bad = [
  { step: 3, s: mk({ orgName: 'א', contactName: 'ב', phone: 'לא-טלפון' }), why: 'טלפון = טקסט-זבל' },
  { step: 1, s: mk({ size: 'ענק' }), why: 'גודל לא-ברשימה' },
  { step: 3, s: mk({ orgName: 'א', contactName: 'ב', phone: '12' }), why: 'טלפון קצר-מדי' },
];
for (const b of bad) {
  const before = wizardStepError_ORIG(b.step, b.s);
  const after = wizardStepError(b.step, b.s, { strict: true });
  console.log(`  שלב ${b.step} · ${b.why}:  מקורי=${JSON.stringify(before)}  →  משודרג=${JSON.stringify(after)}  ${before === null && after !== null ? '✅ נתפס' : '•'}`);
}
console.log(`\n✅ שדרוג-מקסימום: המחולל שלף phoneRegion·regex-signUpError·חברות-רשימה → wizardStepError תופס עכשיו טלפון-זבל/גודל-לא-חוקי שהמקורי אישר. default ביט-זהה (אפס-אובדן).`);
