#!/usr/bin/env node
// 🔬 maor-opindex — אינדקס-op של מנועי-maor (קריאה-בלבד), בפורמט ש-cover צורך: {id, file, op, sockets(טיפוסי-קלט), ret}.
//   מפרק כל פונקציה מיוצאת לחלקיק-op לפי חתימתה (לא לפי שם — שם אינו ראיה). מבודד: קורא /home/user/maor-system, כותב ל-/tmp בלבד.
import fs from 'node:fs'; import path from 'node:path';
const MAOR = '/home/user/maor-system'; const ROOTS = ['src/lib', 'telephony', 'src/components/supporters'];
function walk(d, a=[]){ if(!fs.existsSync(d))return a; for(const e of fs.readdirSync(d,{withFileTypes:true})){ if(e.name==='node_modules'||e.name.startsWith('.'))continue; const p=path.join(d,e.name); if(e.isDirectory())walk(p,a); else if(/\.(ts|mjs)$/.test(e.name)&&!/\.d\.ts$|\.test\./.test(e.name))a.push(p);} return a; }
const files = ROOTS.flatMap(r=>walk(path.join(MAOR,r)));
// op לפי טיפוס-הפלט (אותה מוסכמה כמו op-census של המחולל): bool⇒predicate · string⇒format · number⇒measure · array⇒collection · null-union⇒guard
const opOfRet = (ret) => { const r=(ret||'').trim();
  if(/\|\s*null|\|\s*undefined/.test(r) && /string|number/i.test(r)) return 'guard';   // T|null = שער (העלה של tel!)
  if(/\bboolean\b/.test(r)) return 'predicate';
  if(/\[\]|Array|Map|Set|Record/.test(r)) return 'collection';
  if(/\bnumber\b/.test(r)) return 'measure';
  if(/\bstring\b/.test(r)) return 'format';
  return 'transform'; };
const idx=[];
for(const f of files){ const src=fs.readFileSync(f,'utf8'); const rel=path.relative(MAOR,f);
  // export function name(params): ret  ·  export const name = (params): ret =>
  const re=/export\s+(?:async\s+)?function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)\s*:\s*([^\{]+)\{|export\s+const\s+([A-Za-z0-9_]+)\s*=\s*\(([^)]*)\)\s*:\s*([^=]+)=>/g;
  let m; while((m=re.exec(src))){ const name=m[1]||m[4]; const params=(m[2]||m[5]||'').trim(); const ret=(m[3]||m[6]||'').trim();
    const sockets=params?params.split(',').map(s=>s.split(':').slice(1).join(':').trim()||s.trim()).filter(Boolean):[];
    idx.push({id:name, file:rel, op:opOfRet(ret), sockets, ret}); } }
fs.writeFileSync('/tmp/quarry-iso/machtzev/generator/maor-opindex.json', JSON.stringify(idx,null,1));
// דוח: החלקיקים סביב tel — normalize/guard/format של טלפון
const phone = idx.filter(a=>/phone|tel|dial|e164|msisdn|digits|wa|caller/i.test(a.id+a.ret+a.sockets.join()));
console.log(`סרקתי ${files.length} קבצים · ${idx.length} חלקיקי-op · מתוכם ${phone.length} קשורי-טלפון`);
console.log('\nחלקיקי-tel לפי op:');
for(const op of ['guard','format','predicate','measure','collection','transform']){ const g=phone.filter(a=>a.op===op); if(g.length) console.log(` ${op}: ${g.map(a=>a.id).slice(0,12).join(' · ')}`); }
