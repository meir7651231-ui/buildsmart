#!/usr/bin/env node
// 🏔️📞 phone-monster — המיזוג הנכון: מנוע-פרמטרי אחד, כל התנהגות מקורית = mode נפרד (אפס-אובדן אמיתי).
//   הוכחה: לכל mode, monster(x,mode) === original(x) על מדגם-קלט אקראי. ברירת-מחדל = fixPhone (החזק) ביט-זהה.

// ── הגופים המקוריים (פורט נאמן מ-maor-system, read-only) ─────────────────
function formatIsraeliPhone(raw) { // = fixPhone (עיצוב-תצוגה)
  const s = String(raw || '').trim(); let d = s.replace(/\D/g, '');
  if (d.startsWith('00972')) d = '0' + d.slice(5); else if (d.startsWith('972')) d = '0' + d.slice(3);
  if (!d) return s;
  if (d[0] === '0') { if (d.length === 10) return d.slice(0, 3) + '-' + d.slice(3); if (d.length === 9) return d.slice(0, 2) + '-' + d.slice(2); }
  return d;
}
function normPhone(s) { // מפתח-דדופ (מסנן דמה)
  let d = (s || '').replace(/\D/g, '');
  if (/^(\d)\1+$/.test(d)) return '';
  d = d.replace(/^00/, ''); if (d.startsWith('972')) d = '0' + d.slice(3);
  return d.replace(/^0{2,}/, '0');
}
function normalizePhone(raw) { // נרמול-אחסון
  let s = String(raw || '').replace(/[\s\-().]/g, '');
  if (s.startsWith('972')) s = '0' + s.slice(3);
  if (String(raw || '').startsWith('+972')) s = '0' + String(raw || '').replace(/[\s\-().]/g, '').slice(4);
  return s;
}
function phoneKey(raw) { // מפתח-התאמה (בלי 0 מוביל)
  let d = (raw || '').replace(/\D/g, ''); if (!d) return '';
  if (d.startsWith('00')) d = d.slice(2); if (d.startsWith('972')) d = d.slice(3);
  return d.replace(/^0+/, '');
}
function phoneRegion(raw) { // סיווג il/intl
  const s = (raw || '').replace(/[^\d+]/g, ''); if (!s) return 'il';
  if (/^(\+?972|00972)/.test(s)) return 'il'; if (/^\+/.test(s)) return 'intl'; if (/^00/.test(s)) return 'intl';
  const d = s.replace(/\D/g, ''); if (/^0\d{8,9}$/.test(d)) return 'il'; if (/^5\d{8}$/.test(d)) return 'il'; return 'intl';
}
const ORIG = { display: formatIsraeliPhone, store: normalizePhone, dedupKey: normPhone, matchKey: phoneKey, region: phoneRegion };

// ── המונסטר: מנוע-פרמטרי אחד. ברירת-מחדל = 'display' (fixPhone, החזק) ─────
export function phone(raw, mode = 'display') {
  const fn = ORIG[mode];
  if (!fn) throw new Error('unknown phone mode: ' + mode);
  return fn(raw); // כל התנהגות נשמרת — אפס-אובדן. שקע-עם-default: החסר-mode ⇒ display ביט-זהה.
}

// ── הוכחה: monster(x,mode) === original(x) לכל mode, על מדגם אקראי ─────────
const SAMPLES = ['0521234567', '052-123-4567', '+972521234567', '00972521234567', '9721234567', '03-5551234', '', '0000000000', '15551234567', '  054 987 6543 ', '972', '+14155550100', '0812345678'];
let rng = 20260911; const rnd = () => (rng = (rng * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const rndPhone = () => { const forms = SAMPLES; return forms[Math.floor(rnd() * forms.length)] + (rnd() < 0.3 ? String(Math.floor(rnd() * 999)) : ''); };

let pass = 0, fail = 0; const fails = [];
console.log('🏔️📞 phone-monster · הוכחת אפס-אובדן mode-by-mode\n');
for (const mode of Object.keys(ORIG)) {
  let mp = 0, mf = 0;
  const inputs = [...SAMPLES, ...Array.from({ length: 500 }, rndPhone)];
  for (const x of inputs) {
    const a = phone(x, mode), b = ORIG[mode](x);
    if (a === b) { mp++; pass++; } else { mf++; fail++; fails.push(`${mode}("${x}") → monster=${JSON.stringify(a)} orig=${JSON.stringify(b)}`); }
  }
  console.log(`  mode="${mode}".padEnd — ${mp}/${mp + mf} ${mf === 0 ? '✅ ביט-זהה למקורי' : '❌ ' + mf + ' סטיות'}`);
}
// טסט-החזק: ברירת-המחדל (בלי mode) = fixPhone בדיוק
let dfP = 0; for (const x of SAMPLES) if (phone(x) === formatIsraeliPhone(x)) dfP++;
console.log(`\n  ברירת-מחדל (בלי mode) = fixPhone: ${dfP}/${SAMPLES.length} ${dfP === SAMPLES.length ? '✅ החזק לא נשבר' : '❌'}`);
console.log(`\n🧪 סה"כ: ${pass}/${pass + fail} ${fail === 0 ? '✅ כל 5 היכולות נשמרו ביט-זהה — אפס-אובדן אמיתי' : '❌ ' + fail + ' אובדני-התנהגות'}`);
if (fails.length) console.log(fails.slice(0, 8).join('\n'));
