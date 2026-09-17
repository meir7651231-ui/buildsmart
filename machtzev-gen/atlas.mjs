#!/usr/bin/env node
/** 🗺️ מחצב · אטלס-המדף המלא (atlas) — מנגנון-סריקה טהור, אפס-דאטה (חוק-1).
 *  מחבר את *כל* האטומים לרשות-המחולל (הכרעת-בעלים 29.8 "הוא יכול להשתמש בהכל"):
 *    widgets   — לבנים-ויזואליות (new/dart-ui-bs): מחלקה, props, בנאי
 *    functions — אטומי-לוגיקה (new/dart-maor · new/dart): שם, חתימה, קובץ
 *    data      — אטומי-דאטה (new/dart-data-bs · new/dart-data-maor): קבועים, קובץ
 *  תוצר: machtzev/generator/atlas.json + API בזיכרון (buildAtlas).
 */
import fs from 'node:fs';
import path from 'node:path';
import { classBody, stripComments } from '../assemble/lift-lib.mjs';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const WIDGET_SHELVES = ['new/dart-ui-bs'];
const LOGIC_SHELVES = ['new/dart-maor', 'new/dart'];
const DATA_SHELVES = ['new/dart-data-bs', 'new/dart-data-maor'];

const dartFiles = (dir) => {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) return [];
  return fs.readdirSync(abs, { recursive: true }).map(String)
    .filter(f => f.endsWith('.dart') && !f.endsWith('_test.dart') && !f.includes('QUARANTINE'))
    .filter(f => fs.statSync(path.join(abs, f)).isFile())
    .map(f => ({ shelf: dir, rel: f, abs: path.join(abs, f) }));
};

export function buildAtlas() {
  // תיאור-עצמי בעברית מכותרת-האטום (אותו עיקרון כמו ב-functions): המחולל לומד מהאטום מה הוא.
  const WSCAFFOLD = new Set(['חוט', 'תצוגה', 'אטום', 'חוק', 'מנוע', 'טהור', 'עם', 'של', 'ללא']);
  const heHead = (raw) => {
    const head = raw.split('\n').slice(0, 6).filter(l => /^\s*\/\//.test(l)).join(' ');
    const desc = (head.split('—')[1] || head).replace(/\(חוק[^)]*\)/g, '');
    return [...desc.matchAll(/[֐-׿]{2,}/g)].map(m => m[0]).filter(w => !WSCAFFOLD.has(w)).slice(0, 12);
  };

  const widgets = [];
  for (const f of WIDGET_SHELVES.flatMap(dartFiles)) {
    const raw = fs.readFileSync(f.abs, 'utf8');
    const he = heHead(raw);
    const src = stripComments(raw);
    for (const cm of src.matchAll(/class\s+([A-Z][A-Za-z0-9]*)\s+extends\s+(?:StatelessWidget|StatefulWidget)\b/g)) {
      const cls = cm[1];
      const body = classBody(src, cm.index) || '';
      const types = new Map();
      for (const fm of body.matchAll(/final\s+([^;=]+?)\s+([a-zA-Z_]\w*(?:\s*,\s*[a-zA-Z_]\w*)*)\s*;/g))
        for (const nm of fm[2].split(',')) types.set(nm.trim(), fm[1].trim());
      const ctm = body.match(new RegExp('(?:const\\s+)?' + cls + '\\s*\\(([\\s\\S]*?)\\)\\s*[;:{]'));
      if (!ctm) continue;
      const sig = ctm[1];
      const positional = [];
      const namedPart = sig.includes('{') ? sig.slice(sig.indexOf('{')) : '';
      for (const pp of (sig.includes('{') ? sig.slice(0, sig.indexOf('{')) : sig).split(',')) {
        const mm = pp.match(/this\.(\w+)/); if (mm) positional.push(mm[1]);
      }
      widgets.push({
        cls, file: f.rel, shelf: f.shelf, types, positional, he,
        required: new Set([...namedPart.matchAll(/required\s+this\.(\w+)/g)].map(x => x[1])),
        named: new Set([...namedPart.matchAll(/this\.(\w+)/g)].map(x => x[1])),
        flexRoot: /return\s+(?:Expanded|Flexible)\s*\(/.test(body),   // בנוי-ל-Row: חייב הורה-flex
        dirty: /['"][^'"\n]*[֐-׿]/.test(body),                        // חוב-טוהר: דאטה-עברי קשיח בגוף (הכרעה 16)
      });
    }
  }

  const functions = [];
  for (const f of LOGIC_SHELVES.flatMap(dartFiles)) {
    const raw = fs.readFileSync(f.abs, 'utf8');
    const src = stripComments(raw);
    // תיאור-עצמי בעברית: המילים-העבריות משורת-הכותרת של האטום (מנורמלות: בלי ה"א-הידיעה/פיסוק)
    // מילות-פיגום של כותרות-האטומים (חוט/אטום/חוזה/דרגת...) אינן תיאור — מסוננות
    const SCAFFOLD = new Set(['חוט', 'אטום', 'חוזה', 'דרגת', 'קבוע', 'מוצא', 'קודם', 'אוטומטית']);
    const heOf = (line) => [...(line || '').matchAll(/[֐-׿][֐-׿]*/g)].map(m => m[0].replace(/^ה(?=..)/, '')).filter(w => w.length > 1 && !SCAFFOLD.has(w));
    // שורה-1 טכנית ("אטום-Dart · fnName") ⇒ יורדים בכותרת עד שורת-תיאור עם ≥2 מילים-עבריות.
    // שורות-פיגום (מוצא/טוהר/המרה/חוק/תיקוני-פורט) מדולגות — התיאור האמיתי בדרך-כלל ב"תפקיד:".
    const headLines = raw.split('\n').slice(0, 14).filter(l => /^\s*\/\//.test(l));
    let he = heOf(headLines[0]);
    if (he.length < 2) {
      for (const hl of headLines.slice(1)) {
        if (/מוצא:|טוהר:|חוק-|המרה|תורגם|תיקוני|import |אזהר|צילום|קלט:|פלט:/.test(hl)) continue;
        const w = heOf(hl.replace(/^\s*\/\/+\s*/, '').replace(/^תפקיד:\s*/, ''));
        if (w.length >= 2) { he = w.slice(0, 10); break; }
      }
    }
    for (const fm of src.matchAll(/(?:^|\n)((?:Future<[^>\n]+>|Iterable<[^>\n]+>|List<[^>\n]+>|Map<[^>\n]+>|Set<[^>\n]+>|[A-Z]\w*(?:<[^>\n]+>)?\??|void|bool|int|double|num|String\??|dynamic)\s+([a-z]\w*)\s*\(((?:[^()]|\([^()]*\))*)\))\s*(?:=>|\{|async)/g)) {
      const ret = fm[1].split(/\s+/)[0];
      // פיצול-פרמטרים מודע-עומק: Map<String, X> הוא פרמטר-אחד (הפסיק הפנימי אינו מפריד).
      const splitTop = (s) => { const out = []; let d = 0, cur = ''; for (const ch of s.replace(/[\[\]]/g, ' ')) { if ('<('.includes(ch)) d++; else if ('>)'.includes(ch)) d--; if (ch === ',' && d === 0) { out.push(cur); cur = ''; } else cur += ch; } if (cur.trim()) out.push(cur); return out; };
      const params = splitTop(fm[3]).map(p => p.trim()).filter(Boolean).map(p => {
        const mm = p.match(/^([\w<>,?() ]+?)\s+(\w+)$/);
        return mm ? { type: mm[1].trim(), name: mm[2] } : { type: p, name: '' };
      });
      functions.push({ name: fm[2], sig: fm[1].replace(/\s+/g, ' ').trim(), ret, params, he, file: f.rel, shelf: f.shelf });
    }
  }

  const data = [];
  for (const f of DATA_SHELVES.flatMap(dartFiles)) {
    const src = stripComments(fs.readFileSync(f.abs, 'utf8'));
    const rawD = fs.readFileSync(f.abs, 'utf8');
    const heD = [...(rawD.split('\n')[0] || '').matchAll(/[֐-׿][֐-׿]*/g)].map(m => m[0].replace(/^ה(?=..)/, '')).filter(w => w.length > 1);
    for (const dm of src.matchAll(/(?:^|\n)const\s+(?:(\w[\w<>, ]*?)\s+)?([a-zA-Z_]\w*)\s*=/g)) {
      const entry = { name: dm[2], type: dm[1] || '', he: heD, file: f.rel, shelf: f.shelf };
      // דגימת-תוכן ל-List<String>: הפריטים עצמם (חומר-בנייה חי למחולל)
      if (entry.type === 'List<String>') {
        const at = dm.index + dm[0].length;
        const seg = src.slice(at, src.indexOf(';', at));
        entry.items = [...seg.matchAll(/'((?:\\.|[^'\\])*)'/g)].map(x => x[1].replace(/\\'/g, "'")).slice(0, 12);
      }
      data.push(entry);
    }
  }

  return { widgets, functions, data };
}

export function writeAtlas(atlas) {
  fs.writeFileSync(path.join(ROOT, 'machtzev/generator/atlas.json'), JSON.stringify({
    counts: { widgets: atlas.widgets.length, functions: atlas.functions.length, data: atlas.data.length },
    widgets: atlas.widgets.map(a => ({ cls: a.cls, file: a.file, props: [...a.types.keys()], required: [...a.required], positional: a.positional, he: a.he })),
    functions: atlas.functions,
    data: atlas.data,
  }, null, 1));
}

if (import.meta.url === 'file://' + process.argv[1]) {
  const a = buildAtlas();
  writeAtlas(a);
  console.log(`🗺️ אטלס-מלא · widgets: ${a.widgets.length} · functions: ${a.functions.length} · data: ${a.data.length}`);
}
