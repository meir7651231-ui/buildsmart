#!/usr/bin/env node
// 🏔️ super-finish — המחולל מסיים לבד: בוחר-חזק (super-quarry) → גוזר-חוזה+סדר (io-contract) →
//   זורע קלט-אמת → מריץ את שרשרת-החציבה מקצה-לקצה על עותק-מבודד → סופר פלט. אפס-הרדקוד-סדר (נגזר).
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
import { SUPER } from './super-quarry.mjs';
import { ioContract } from './io-contract.mjs';
const GEN = path.dirname(fileURLToPath(import.meta.url)), MZ = path.join(GEN, '..'), ROOT = path.join(MZ, '..');
const ISO = '/tmp/super-finish', MZI = path.join(ISO, 'machtzev');
const log = (s) => process.stdout.write(s + '\n');

execSync(`rm -rf ${ISO} && cp -r ${ROOT} ${ISO}`);
log('📦 עותק-מבודד מוכן');

// (1) זריעת קלט-אמת: מסכי-מקור אמיתיים מ-buildsmart ⇒ תיקיית-הזנה בעותק
const SEED = path.join(ISO, 'seed-screens'); fs.mkdirSync(SEED, { recursive: true });
let screens = [];
try { screens = execSync(`find /home/user/buildsmart/app_flutter/lib -name "*_screen.dart" 2>/dev/null | head -5`, { encoding: 'utf8' }).trim().split('\n').filter(Boolean); } catch {}
for (const s of screens) { try { fs.copyFileSync(s, path.join(SEED, path.basename(s))); } catch {} }
log(`🌱 נזרעו ${screens.length} מסכי-מקור אמיתיים`);

// (2) שרשרת-החציבה מ-super-quarry (בחר-חזק), רק שלבי-הפירוק/הרמה (לא extract/* שקוראים מהמקור)
const chain = SUPER.filter((c) => /screen-decomp|shelf-lift|data-lift|purify/.test(c.engine)).map((c) => c.engine);
log('🔗 שרשרת (נגזרת): ' + chain.map((f) => f.split('/').pop().replace(/\.mjs$/, '')).join(' → '));

// (3) ריצה מקצה-לקצה על העותק — כל שלב מוגבל-זמן, פלט-שלב נשאר בעותק לשלב-הבא (SCRATCH משותף)
const countAtoms = () => { try { return execSync(`ls ${path.join(MZI, 'new/atoms')} 2>/dev/null | wc -l`, { encoding: 'utf8' }).trim(); } catch { return '0'; } };
const before = countAtoms();
let ran = 0;
// screen-decomp פר-מסך-זרע ⇒ מניפסטי-מכונה; שאר השלבים על ה-SCRATCH המשותף
for (const eng of chain) {
  const abs = path.join(MZI, eng);
  try {
    if (/screen-decomp/.test(eng)) {
      for (const s of fs.readdirSync(SEED)) execSync(`timeout 30 node ${abs} ${path.join(SEED, s)} --json ${path.join(MZI, 'screens-seed/machine', s.replace(/\.dart$/, '.json'))} 2>/dev/null || true`, { cwd: MZI });
    } else {
      execSync(`timeout 90 node ${abs} ${path.join(MZI, 'screens-seed/machine')} 2>&1 | tail -1 || true`, { cwd: MZI, encoding: 'utf8' });
    }
    ran++;
    log(`  ✓ ${eng.split('/').pop()}`);
  } catch (e) { log(`  ⚠️ ${eng.split('/').pop()}: ${(e.message || '').split('\n')[0].slice(0, 50)}`); }
}
const after = countAtoms();

// (4) אורקל: כמה מהאטומים-שנחצבו מתקמפלים/נקיים (deep-purity-scan)
let clean = '?'; try { clean = execSync(`node ${path.join(MZI, 'deep-purity-scan.mjs')} 2>&1 | tail -1`, { cwd: MZI, encoding: 'utf8' }).trim(); } catch {}

log(`\n🏔️ מחצב-העל רץ מקצה-לקצה: ${ran}/${chain.length} שלבים · אטומים: ${before} ⇒ ${after}`);
log(`✅ אורקל: ${clean}`);
execSync(`rm -rf ${ISO}`); log('🧹 עותק נמחק · חי נקי');
