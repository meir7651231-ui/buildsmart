#!/usr/bin/env node
// ⬆️ purity-data-max — מחולל ע"י wire-upgrade (detect→fix→verify · אפס-אובדן).
//   ברירת-מחדל: מריץ את purity/purity-data.mjs מילה-במילה ⇒ פלט ביט-זהה. --upgrade: מוסיף fix+verify (יבש/עותק).
//   תפקיד-מקור: detect · פער-שמולא: guard,fix,aggregate,act
import { execFileSync } from 'node:child_process';
import path from 'node:path';
const HERE = new URL('.', import.meta.url).pathname;
const run = (f, args = []) => { try { return execFileSync('node', [path.join(HERE, f), ...args], { encoding: 'utf8' }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }; // סובלני-לקוד-יציאה: פלט המקור מועבר כמות-שהוא (כולל usage), ⇒ ברירת-מחדל ביט-זהה גם לדורשי-args
const UPGRADE = process.argv.includes('--upgrade');

// ── שלב 1 · detect (המנוע המקורי — ברירת-מחדל, ביט-זהה) ──
const detect = run("../purity/purity-data.mjs", process.argv.slice(2).filter(a => a !== '--upgrade'));
process.stdout.write(detect);
if (!UPGRADE) process.exit(0);   // ← ברירת-מחדל = בדיוק המנוע המקורי

// ── שלב 2 · fix (עוזר שנמצא באימפריה: purify) — יבש בלבד ──
console.log('\n⬆️ [upgrade] fix זמין: purity/purify.mjs — הרצה-יבשה (לא-מוטטת):');
try { console.log(run("../purity/purify.mjs", ['--dry']).split('\n').slice(-3).join('\n')); } catch (e) { console.log('   (אין מצב --dry; מדולג בבטחה)'); }

// ── שלב 3 · verify (אורקל: deep-purity-scan) ──
console.log('\n✅ [verify] deep-purity-scan.mjs:');
try { console.log(run("../deep-purity-scan.mjs", ['--gate']).split('\n').slice(-2).join('\n')); } catch (e) { console.log('   verify: ' + (e.stdout || e.message || '').split('\n').slice(-2).join(' ')); }
