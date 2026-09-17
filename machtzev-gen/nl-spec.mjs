#!/usr/bin/env node
// ══════════════════════════════════════════════════════════════════════════
//  nl-spec.mjs — צפן §22: משפט-בעברית-חופשית ⇒ אפיון-מובנה (ישות … עם …).
//  ⚙️ מנגנון-עיוור (חוק-הטוהר · §19): אפס מילה-עברית בקוד. כל ידע-השפה מוזרק
//  מאטום-הדאטה 'nl-lang.data.json' (מילות-פיגום · מפרידי-שדות · חיבור-רשימה).
//  המנוע רק: מפצל-לפי-מבנה (מפריד/פסיק/חיבור מהדאטה) → מסיר-פיגום → נושאים=ישויות ·
//  אחרי-מפריד=שדות. ⇒ app-ds.buildApp ⇒ אפליקציה עובדת (רצפת-§22). זיהוי-חלקי ⇒ פשוט יותר.
// ══════════════════════════════════════════════════════════════════════════
import fs from 'node:fs';
import { stem } from './match.mjs';
import * as R from '../root.mjs';
const LANG = JSON.parse(fs.readFileSync((R.GEN_DIR + 'nl-lang.data.json'), 'utf8'));
const LEAD = new Set(LANG.leadins || []);
const MARK = LANG.fieldMarks || [];
const CONJ = LANG.listConj || [];
const DEF_FIELDS = LANG.defaultFields || [];
const FALLBACK = LANG.fallbackName || '';
const TPL_ENT = LANG.tplEntity || '';
const TPL_WITH = LANG.tplWith || '';
const INTRO = LANG.introMarks || [];
const EACH = LANG.eachWords || [];
const IMPLIED = LANG.impliedMark || '';
// 'לכל X שדה, שדה' — מרקר-שדות **מובלע** (בעברית 'יש' משתמע). ⇒ מזריק את המרקר: X מקבל
// את הרשימה כשדות (במקום שהשדות יהפכו לישויות). מבני · מהדאטה (eachWords/impliedMark).
const EACH_RE = (EACH.length && IMPLIED) ? new RegExp(`(?:^|[,،]\\s*)(?:${EACH.join('|')})\\s+([֐-׿]{2,})\\s+(?=[֐-׿])`) : null;
const PLURAL_RE = new RegExp('(' + (LANG.pluralSuffixes || []).join('|') + ')$');   // אות-ריבוי מהדאטה (עיוור)
const heWords = (s) => [...(s || '').matchAll(/[֐-׿][֐-׿'"׳״]*/g)].map((m) => m[0]);
const content = (ws) => ws.filter((w) => w.length > 1 && !LEAD.has(w) && !MARK.includes(w) && !CONJ.includes(w));
const pluralW = (w) => PLURAL_RE.test(w || '');   // מילה-בודדת ברבים?
// deprefix-ל (מבני · כמו stemmer): קידומת 'ל' (אל/עבור) על שם-**תחום** ⇒ מוסרת (למכון⇒מכון · לרכב⇒רכב).
// רק 'ל', רק אורך≥4, ומוחל אך-ורק על שם-הראש — פריטי-רשימה בזנב ('לקוחות') לא נוגעים.
const deL = (w) => (w.length >= 4 && w[0] === 'ל' && !PLURAL_RE.test(w)) ? w.slice(1) : w;
const nameOf = (s) => content(heWords(s)).slice(0, 2).join(' ') || null;
const headName = (s) => { const c = content(heWords(s)); return c.length ? [deL(c[0]), ...c.slice(1, 2)].join(' ') : null; };
// דפוסים-מבניים נבנים מהדאטה המוזרקת (המנוע עיוור לתוכן):
const MARK_RE = MARK.length ? new RegExp(`\\s+(?:${MARK.join('|')})\\s+`) : null;
const INTRO_RE = INTRO.length ? new RegExp(`\\s*[${INTRO.join('')}]\\s*`) : null;
const ITEM_RE = new RegExp(`\\s*[,،]\\s*${CONJ.length ? `|\\s+(?:${CONJ.join('|')})(?=[֐-׿])` : ''}`);
const splitItems = (s) => s.split(ITEM_RE).map((x) => x.trim()).filter(Boolean);

export function nlToSpec(text) {
  const t = String(text || '').replace(/[•]/g, ' ');
  const clauses = t.split(/[.;\n]+/).map((c) => c.trim()).filter((c) => heWords(c).length);
  const ents = []; const seen = new Set();
  const push = (name, fieldStrs) => {
    if (!name || name.length < 2 || seen.has(name)) return; seen.add(name);
    const fs = [...new Set(fieldStrs.map((g) => content(heWords(g)).join(' ')).filter((f) => f.length > 1))];
    ents.push({ name, fields: fs.length ? fs : DEF_FIELDS });
  };
  for (const rawClause of clauses) {
    // (0) 'לכל X …' ⇒ מזריק מרקר-שדות מובלע (X יש …) כדי שהרשימה תהיה שדות, לא ישויות.
    const clause = EACH_RE ? rawClause.replace(EACH_RE, (m, w) => ` , ${w} ${IMPLIED} `) : rawClause;
    // (1) intro-mark (':') — הראש שלפניו = תחום/מערכת. ראש-לפני-אינטרו ברבים (ישות אמיתית,
    //     'ניהול רכבים:') נשמר; ראש-תחום ביחיד ('ניהול מלון:') נשמט. הזנב שאחרי = הפריטים.
    const iParts = INTRO_RE ? clause.split(INTRO_RE) : [clause];
    const work = iParts.length > 1 ? iParts.slice(1).join(' ') : clause;
    if (iParts.length > 1) { const pc = content(heWords(iParts[0])); if (pc.length && pluralW(pc[0])) push(deL(pc[0]), []); }
    // (2) field-mark (עם/יש/כולל) — ראש=ישות · זנב=פריטים
    const seg = MARK_RE ? work.split(MARK_RE) : [work];
    const headStr = seg[0];
    const tailStr = seg.slice(1).join(' ');
    const headC = content(heWords(headStr));
    const headItems = splitItems(headStr).map(nameOf).filter(Boolean);
    const tailItems = tailStr ? splitItems(tailStr).filter((x) => content(heWords(x)).length) : [];
    // אות-ריבוי מורפולוגי (מבני, לא מילון): מילה ברבים (ים/ות) = ישות · ביחיד = שדה.
    const firstW = (s) => content(heWords(s))[0] || '';
    const tailPlural = tailItems.filter((x) => pluralW(firstW(x)));
    const tailSingular = tailItems.filter((x) => !pluralW(firstW(x)));
    const headIsEnt = headC.length > 0 && pluralW(headC[0]);   // ראש-רבים = ישות אמיתית ('פרויקטים')
    if (!tailItems.length) {
      // אין זנב ⇒ הראש = הישות(יות). רשימה בראש ⇒ כל הפריטים; אחרת ישות-יחידה.
      if (headItems.length > 1) headItems.forEach((h) => push(h, []));
      else push(headName(headStr) || headItems[0], []);
    } else if (tailPlural.length) {
      // זנב-רבים = ישויות. ראש-רבים = ישות-נוספת (מקבל שדות-יחיד); ראש-תחום = נשמט.
      if (headIsEnt) push(headName(headStr), tailSingular);
      tailItems.forEach((tt) => push(nameOf(tt), []));
    } else if (headItems.length > 1) {
      // רשימת-ראש + זנב-שדות ('משימות, משימה יש …') ⇒ קודמים=ישויות · אחרון מקבל את השדות.
      headItems.slice(0, -1).forEach((h) => push(h, []));
      push(headItems[headItems.length - 1], tailSingular);
    } else {
      // זנב כולו יחיד = שדות ⇒ הראש = הישות (שם-מנוקה-קידומת).
      push(headName(headStr) || headItems[0], tailSingular);
    }
  }
  if (!ents.length) push(nameOf(t) || FALLBACK, []);
  // דדופ לפי-גזע: 'רכבים'/'רכב' · 'משימות'/'משימה' = מושג-אחד ⇒ מיזוג. שומר את בעל-שדות-האמת.
  const isReal = (e) => e.fields !== DEF_FIELDS;
  const byStem = new Map();
  for (const e of ents) {
    const key = stem(content(heWords(e.name))[0] || e.name);
    const prev = byStem.get(key);
    if (!prev || (isReal(e) && !isReal(prev))) byStem.set(key, e);
  }
  return [...byStem.values()].map((e) => `${TPL_ENT} ${e.name} ${TPL_WITH} ${e.fields.join(', ')}`).join('\n');
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const text = process.argv.slice(2).join(' ');
  if (!text) { console.log('usage: node nl-spec.mjs "<free hebrew sentence>"'); process.exit(0); }
  console.log('IN:  ' + text + '\nSPEC:\n' + nlToSpec(text).split('\n').map((l) => '  ' + l).join('\n'));
}
