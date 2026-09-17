#!/usr/bin/env node
// 🏔️ super-carver — חולל ע"י super-run: מריץ את החזק בכל op-חציבה בסדר. --exec מפעיל; ברירת-מחדל = תוכנית.
import { execFileSync } from 'node:child_process'; import path from 'node:path';
const HERE = new URL('.', import.meta.url).pathname;
const run = (f, a=[]) => { try { return execFileSync('node',[path.join(HERE,'..',f),...a],{encoding:'utf8'}); } catch(e){ return (e.stdout||'')+(e.stderr||''); } };
const CHAIN = ["carve/screen-decomp.mjs","assemble/shelf-lift.mjs","assemble/data-lift.mjs","purity/purify.mjs","extract/actions.mjs","extract/components.mjs","extract/consts.mjs","extract/engines.mjs","extract/flags.mjs","extract/functions.mjs","extract/icons.mjs","extract/knowledge.mjs","extract/regexes.mjs","extract/schema.mjs","extract/strings.mjs","extract/styles.mjs","extract/terms.mjs","extract/tokens.mjs","extract/verticals.mjs"];
console.log('🏔️ מחצב-העל · שרשרת:', CHAIN.map(f=>f.split('/').pop().replace(/\.mjs$/,'')).join(' → '));
if (!process.argv.includes('--exec')) process.exit(0);
for (const f of CHAIN) { const out = run(f, ['--gate']); console.log('  '+f.split('/').pop().padEnd(20)+' → '+(out.trim().split('\n').pop()||'(רץ)').slice(0,60)); }
