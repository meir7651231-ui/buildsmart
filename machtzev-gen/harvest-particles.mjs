#!/usr/bin/env node
// 🏔️ harvest-particles — יכולת-המחולל: יוצא לבד לכל ריפו · כל ענף · מחלץ כל חלקיק-פעולת-יסוד
//   (פונקציה-מיוצאת עם חתימה = סוקט קלט→פלט), מדדפ חוצה-ענף, ומזרים למחצב (קטלוג-אב).
//   READ-ONLY מוחלט על הריפואים החיים: git ls-tree / git show בלבד — אפס checkout/fetch/merge/כתיבה.
//   פלט: /tmp/quarry-iso/machtzev/generator/master-particles.json + התקדמות חיה. ללא עצירות.
import { execSync } from 'node:child_process';
import fs from 'node:fs'; import crypto from 'node:crypto';
// המחולל מגלה לבד את כל ריפואי-ה-git על הדיסק — אפס רשימה מקובעת (הלקח: לא לקבע היקף).
const REPOS = (() => {
  const found = execSync(`find /home /tmp -maxdepth 4 -name .git -type d 2>/dev/null | sed 's#/.git##'`, { encoding: 'utf8' }).split('\n').filter(Boolean);
  return found.map((r) => [r, r.split('/').pop()]);
})();
const OUT = '/tmp/quarry-iso/machtzev/generator/master-particles.json';
const PROG = '/tmp/harvest.progress';
const sh = (cmd, cwd) => { try { return execSync(cmd, { cwd, encoding: 'utf8', maxBuffer: 1e9, stdio: ['ignore', 'pipe', 'ignore'] }); } catch { return ''; } };
const log = (s) => fs.appendFileSync(PROG, s + '\n');

// חילוץ חלקיקי-יסוד מקובץ-מקור: פונקציה-מיוצאת עם חתימה (קלט→פלט = סוקט). שם+חתימה = זהות-החלקיק.
function particles(src, lang) {
  const out = [];
  if (lang === 'dart') {
    for (const m of src.matchAll(/(?:^|\n)\s*([A-Za-z_][\w<>,?\[\] ]*?)\s+([a-z_]\w*)\s*\(([^)]*)\)\s*(?:async\s*)?\{/g)) {
      const ret = m[1].trim(), name = m[2], params = m[3].trim();
      if (/^(if|for|while|switch|catch|return|else)$/.test(name)) continue;
      out.push({ name, sig: `${params}=>${ret}`, op: opOf(ret, params) });
    }
  } else {
    for (const m of src.matchAll(/export\s+(?:async\s+)?function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)\s*:?\s*([^\{]*)\{|export\s+const\s+([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?\(([^)]*)\)\s*(?::\s*([^=]*))?=>/g)) {
      const name = m[1] || m[4], params = (m[2] || m[5] || '').trim(), ret = (m[3] || m[6] || '').trim();
      out.push({ name, sig: `${params}=>${ret}`, op: opOf(ret, params) });
    }
  }
  return out;
}
const opOf = (ret, params) => {
  const r = (ret || '').toLowerCase();
  if (/\|\s*null|\?\s*$/.test(ret) && /string|int|num/.test(r)) return 'guard';
  if (/\bbool/.test(r)) return 'predicate';
  if (/\[\]|list|array|map|set|iterable/.test(r)) return 'collection';
  if (/\b(int|double|num|number)\b/.test(r)) return 'measure';
  if (/\bstring\b/.test(r)) return 'format';
  if (/void|future<void>|promise<void>/.test(r)) return 'effect';
  return 'transform';
};

fs.writeFileSync(PROG, `🏔️ harvest התחיל · ${new Date().toISOString()}\n`);
const seen = new Set();               // דדופ חוצה-ענף: hash(name+sig)
const seenBlob = new Set();           // דדופ ברמת-קובץ: blob-SHA (תוכן-זהה נקרא פעם-אחת)
const catalog = {};                   // op → [{name,sig,origin}]
let totalFiles = 0, totalParts = 0;

for (const [root, label] of REPOS) {
  if (!fs.existsSync(root + '/.git')) { log(`skip ${label} (לא-git)`); continue; }
  const branches = sh('git branch -a --format="%(refname)"', root).split('\n').map((b) => b.trim()).filter((b) => b && !b.includes('HEAD'));
  log(`\n📦 ${label}: ${branches.length} ענפים`);
  for (const br of branches) {
    // git ls-tree -r מחזיר: <mode> blob <sha> <path> — דדופ לפי blob-SHA: כל תוכן-קובץ ייחודי נקרא פעם-אחת בכל האימפריה
    const rows = sh(`git ls-tree -r ${br}`, root).split('\n').map((l) => l.match(/^\S+ blob (\S+)\t(.+)$/)).filter(Boolean).filter((m) => /\.(ts|tsx|mjs|js|dart)$/.test(m[2]) && !/\.d\.ts$|\.test\.|\.spec\.|node_modules|\.g\.dart$/.test(m[2]));
    let brParts = 0;
    for (const [, blob, f] of rows) {
      if (seenBlob.has(blob)) continue; seenBlob.add(blob);   // תוכן-זהה בענף/ריפו אחר — כבר נסרק
      const src = sh(`git show ${blob}`, root); if (!src) continue;
      totalFiles++;
      const lang = f.endsWith('.dart') ? 'dart' : 'js';
      for (const p of particles(src, lang)) {
        const h = crypto.createHash('md5').update(p.name + '|' + p.sig).digest('hex');
        if (seen.has(h)) continue; seen.add(h);
        (catalog[p.op] ||= []).push({ name: p.name, sig: p.sig.slice(0, 80), origin: `${label}:${f}` });
        totalParts++; brParts++;
      }
    }
    log(`  ${br.replace('refs/','')}: +${brParts} חלקיקים חדשים (מצטבר ${totalParts})`);
  }
}

const summary = Object.fromEntries(Object.entries(catalog).map(([op, arr]) => [op, arr.length]));
fs.writeFileSync(OUT, JSON.stringify({ totalParticles: totalParts, totalFilesScanned: totalFiles, byOp: summary, catalog }, null, 0));
log(`\n✅ סיום: ${totalParts} חלקיקי-יסוד ייחודיים מ-${totalFiles} קבצים · לפי-op: ${JSON.stringify(summary)}`);
log(`📥 הוזרם למחצב: ${OUT}`);
