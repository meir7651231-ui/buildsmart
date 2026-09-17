#!/usr/bin/env node
// ══════════════════════════════════════════════════════════════════════════
//  app-ds.mjs — הדלת-האחת על מערכת-העיצוב: אפיון ⇒ אפליקציה שלמה מעוצבת-פרימיום.
//  ישויות ⇒ טופס-DS (טיפוס נאחז מהאטומים) · דשבורדים ⇒ רשת-KPI מנתוני-הישויות ·
//  לוח-ניווט · מסכי-מערכת. הכל דרך render-ds (טהור). שימוש: node app-ds.mjs -f spec.txt
// ══════════════════════════════════════════════════════════════════════════
import fs from 'node:fs';
import path from 'node:path';
import { interpret as entInterpret } from './entity.mjs';
import { renderEntity, renderDashboard, renderHub, renderSystem, renderMain, renderScreenBind, renderCompose, renderRecordDetail, SCREEN_REGISTRY } from './render-ds.mjs';
import { nlToSpec } from './nl-spec.mjs';
import { L, T } from './chrome.mjs';
import * as R from '../root.mjs';

const ROOT = R.ROOT;
const OUT = R.outDir();
const DATA = R.dataOutDir();
const ENTITY_RE = /^\s*(צור\s+)?(ישות|טופס|טבלת)(\s|$)/;
const ROLE_RE = /^\s*(תפקיד|הרשאת)\s+/;
const clean = (s) => [...String(s || '').matchAll(/[֐-׿][֐-׿״׳]*/g)].map((m) => m[0]).join(' ').slice(0, 40);

// אשף-תפקיד: 'תפקיד NAME: א, ב, ג' ⇒ {name, all, ents}. 'הכל' ⇒ גישה-מלאה.
function parseRole(line) {
  const body = line.replace(ROLE_RE, '');
  const ci = body.indexOf(':');
  const name = (ci >= 0 ? body.slice(0, ci) : body).trim();
  const afterName = ci >= 0 ? body.slice(ci + 1) : '';
  // סעיפי-'|' (RLS · read-side): '... | היקף: תלמיד.מורה | שדות: תלמיד.ציון=הסתר'.
  const segs = afterName.split('|');
  const entPart = segs[0];
  const all = entPart.includes('הכל');   // ‏\b הוא ASCII בלבד — לא נדלק על עברית
  const ents = all ? [] : entPart.split(/[,،]/).map((s) => s.trim()).filter(Boolean);
  const scope = [], hide = [], ro = [];
  for (let i = 1; i < segs.length; i++) {
    const hm = segs[i].match(/^\s*(היקף|שדות)\s*:(.*)$/);
    if (!hm) continue;
    const items = hm[2].split(/[,،]/).map((x) => x.trim()).filter(Boolean);
    if (hm[1] === 'היקף') {
      for (const it of items) { const d = it.match(/^(.+?)\.(.+)$/); if (d) scope.push({ ent: clean(d[1]), field: clean(d[2]) }); }
    } else {
      // שדות: X.Y=הסתר (הסתרה מלאה כרטיס+טופס) · X.Y=נעל/קריאה (נעילת-קלט בטופס בלבד)
      for (const it of items) { const d = it.match(/^(.+?)\.(.+?)\s*=\s*(.+)$/); if (!d) continue; const e = { ent: clean(d[1]), field: clean(d[2]) }; if (/הסתר/.test(d[3])) hide.push(e); else if (/נעל|קריאה/.test(d[3])) ro.push(e); }
    }
  }
  return { name, all, ents, scope, hide, ro };
}

export function buildApp(specText) {
  // 🗣️ צפן §22: קלט חסר-מבנה לגמרי (אף ישות/דשבורד/תפקיד) ⇒ עברית-חופשית ⇒ nlToSpec.
  // מבנה קיים ⇒ ביט-זהה (לא נוגעים). כך אותה דלת מקבלת גם משפט-חופשי וגם אפיון-מדויק.
  const raw = specText.split(/\n+/).map((l) => l.trim()).filter((l) => l.length > 2);
  // חסר ישות-מפורשת ⇒ עברית-חופשית לשורות-שאינן-תפקיד (שורות-תפקיד נשמרות כמות-שהן ומצורפות
  // בחזרה). באג-שנתפס: קלט מעורב (משפט-ישויות-חופשי + 'תפקיד ...') דילג על nlToSpec כי שורת-
  // תפקיד קיימת ⇒ 0 ישויות, אפליקציה מנוונת. עכשיו רק ישות-מפורשת ⇒ ביט-זהה; אחרת החופשי מתפרש.
  if (raw.length && !raw.some((l) => ENTITY_RE.test(l))) {
    const roleLines = raw.filter((l) => ROLE_RE.test(l));
    const freeLines = raw.filter((l) => !ROLE_RE.test(l));
    const nl = nlToSpec(freeLines.join('\n'));
    if (nl.trim()) specText = [nl, ...roleLines].join('\n');   // חסר-מבנה ⇒ עברית-חופשית + תפקידים
  }
  const all = specText.split(/\n+/).map((l) => l.trim()).filter((l) => l.length > 2);
  const roles = all.filter((l) => ROLE_RE.test(l)).map(parseRole);
  const lines = all.filter((l) => !ROLE_RE.test(l));
  const info = lines.map((line, idx) => ({ line, i: idx + 1, isEnt: ENTITY_RE.test(line) }));

  // מקדימים: כל הישויות (לתוכן-הדשבורדים ולזיהוי-קשרים בין-ישויות) + מפת שם→slug יציב
  const entRes = {};
  for (const li of info) if (li.isEnt) entRes[li.i] = entInterpret(li.line);
  const entMeta = [];
  const nameToSlug = {};
  for (const li of info) if (li.isEnt) {
    const r = entRes[li.i];
    const eslug = `app_ent${li.i}`;
    entMeta.push({ name: r.entity, slug: eslug, fields: r.schema.length, stages: (r.stages || []).length, stageLabels: r.stages || [], icon: '🗂️', numFields: r.schema.filter((s) => s.type === 'num').map((s) => s.label), labels: r.schema.map((s) => s.label) });
    if (!(r.entity in nameToSlug)) nameToSlug[r.entity] = eslug;   // שם ⇒ slug-היעד לקשרים
  }
  const entityNames = entMeta.map((e) => e.name);
  // 🔁 קשר-הפוך: לכל ישות-יעד — מי מצביע עליה (ישות F · שדה · יחיד/רבים). משקף את
  // סדר-הקדימות של render-ds: קשר-יחיד (pickRelation, תת-קבוצת-מילים) קודם, ואם אין —
  // קשר-רבים (pickMultiRelation, צורת-רבים של ישות חד-מילית). כך גרף-הקשרים שלם ל-M2M.
  const hw = (s) => [...String(s || '').matchAll(/[֐-׿][֐-׿״׳]*/g)].map((m) => m[0]);
  const definal = (w) => w.replace(/ך$/, 'כ').replace(/ם$/, 'מ').replace(/ן$/, 'נ').replace(/ף$/, 'פ').replace(/ץ$/, 'צ');
  const pluralForms = (en) => { const b = definal(en.replace(/ה$/, '')); const b2 = definal(en); return new Set([`${b}ים`, `${b}ות`, `${b2}ים`, `${b2}ות`]); };
  const relOf = (label, self) => {
    const fw = new Set(hw(label));
    for (const en of entityNames) {                                   // (א) קשר-יחיד — כמו pickRelation
      if (en === self) continue;
      const ew = hw(en);
      if (ew.length && ew.every((w) => fw.has(w))) return { en, multi: false };
    }
    for (const en of entityNames) {                                   // (ב) קשר-רבים — כמו pickMultiRelation
      if (en === self || hw(en).length !== 1) continue;
      const forms = pluralForms(en);
      for (const w of fw) if (forms.has(w)) return { en, multi: true };
    }
    return null;
  };
  const backRefs = {};
  // 🗑 קשתות-שלמות (Referential Integrity, opt-in): רק שדות-קשר שהילד הכריז עליהם
  // ב-'| מחיקה:'. בלי-הכרזה ⇒ אין-קשת ⇒ removeById מתנהג כמקודם (ביט-זהה). מדיניות-מחיקה
  // חמורה-ביותר פר-ישות-הורה (חסימה=0 גוברת) ⇒ שער-מחיקה בכרטיס-ההורה.
  const edges = [];
  const delGuardByName = {};
  for (const li of info) if (li.isEnt) {
    const F = entRes[li.i]; const fslug = `app_ent${li.i}`;
    const dp = F.delPolicy || [];
    for (const s of F.schema) {
      // רק שדות שמתרנדרים כקשר: לא נוסחה/צבירה, לא enum, לא מקונן (משקף את קדימות render-ds).
      if (s.formula || (s.enumVals && s.enumVals.length) || (s.members && s.members.length)) continue;
      const hit = relOf(s.label, F.entity);
      if (hit) (backRefs[hit.en] ??= []).push({ fslug, ffield: s.label, fname: F.entity, multi: hit.multi });
      const decl = hit ? dp.find((d) => d.field === s.label) : null;
      if (hit && decl && nameToSlug[hit.en]) {
        edges.push({ childSlug: fslug, field: s.label, parentSlug: nameToSlug[hit.en], parentName: hit.en, policy: decl.policy, multi: hit.multi });
        const cur = delGuardByName[hit.en];
        delGuardByName[hit.en] = cur === undefined ? decl.policy : (cur === 0 || decl.policy === 0 ? 0 : decl.policy);
      }
    }
  }

  // ניקוי פלט-app קודם
  for (const f of fs.readdirSync(OUT)) if (/^gen_app_.*\.dart$/.test(f)) fs.unlinkSync(path.join(OUT, f));
  for (const f of fs.readdirSync(DATA)) if (/^gen_app_.*_content\.dart$/.test(f)) fs.unlinkSync(path.join(DATA, f));

  const screens = [];
  for (const li of info) {
    if (li.isEnt) {
      const r = entRes[li.i];
      const slug = `app_ent${li.i}`;
      const authz = roles.length ? {
        scope: roles.map((role) => { const sc = (role.scope || []).find((x) => x.ent === r.entity); return sc ? sc.field : ''; }),
        hidden: roles.map((role) => r.schema.map((s, i) => (role.hide || []).some((h) => h.ent === r.entity && h.field === s.label) ? i : -1).filter((i) => i >= 0)),
        readonly: roles.map((role) => r.schema.map((s, i) => (role.ro || []).some((h) => h.ent === r.entity && h.field === s.label) ? i : -1).filter((i) => i >= 0)),
      } : null;
      const { cls } = renderEntity(slug, { name: r.entity, icon: '🗂️', schema: r.schema, stages: r.stages || [], entityNames, nameToSlug, backRefs: backRefs[r.entity] || [], vrules: r.vrules || [], delGuard: delGuardByName[r.entity], guards: r.guards || [], authz });
      screens.push({ slug, cls, kind: 'entity', name: r.entity, icon: '🗂️', sub: `${r.schema.length} ${L.fieldsWord}${(r.stages || []).length ? ` · ${r.stages.length} ${L.stagesWord}` : ''}` });
    } else {
      const slug = `app_scr${li.i}`;
      const title = (li.line.split(/\s+עם\s+/)[0] || li.line).trim();     // כותרת = לפני 'עם'
      // פיצול-מדדים מודע-עומק: רווח/פסיק מפרידים רק ברמה-0 — רווח בתוך '(...)' (מונה-מסונן
      // 'מונה(מערכת: סטטוס=קריטי)') אינו מפריד. באג-קודם: split גלובלי שבר אגרגט-עם-רווח.
      const splitMetrics = (str) => { const out = []; let d = 0, cur = ''; for (const ch of str) { if (ch === '(') d++; else if (ch === ')') d = Math.max(0, d - 1); if ((ch === ' ' || ch === ',' || ch === '\t') && d === 0) { if (cur.trim()) out.push(cur.trim()); cur = ''; } else cur += ch; } if (cur.trim()) out.push(cur.trim()); return out; };
      const rawMetrics = splitMetrics(li.line.split(/\s+עם\s+/)[1] || '');   // מדדים = אחרי 'עם'
      // אגרגט מהאפיון: סכום(ישות.שדה) · ממוצע(ישות.שדה) · מונה(ישות). בלי-סוגריים ⇒ מונה-לפי-שם.
      const aggs = [], countWords = [];
      // מונה-מסונן (KPI 'בסיכון' · דשבורד-מפקד): 'מונה(ישות: שדה=ערך)' ⇒ סופר רשומות במצב.
      const FILT_RE = new RegExp('^' + L.count + '\\(([^:)]+):\\s*([^=)]+)=([^)]+)\\)$');
      for (const t of rawMetrics) {
        const mf = t.match(FILT_RE);
        if (mf) { const en = mf[1].trim(); aggs.push({ kind: L.count, entityName: en, field: mf[2].trim(), value: mf[3].trim(), slug: nameToSlug[en] || '', filtered: true }); continue; }
        const m = t.match(/^(סכום|ממוצע|מונה)\(([^.)]+)(?:\.([^)]+))?\)$/);
        if (m) aggs.push({ kind: m[1], entityName: m[2].trim(), field: (m[3] || '').trim(), slug: nameToSlug[m[2].trim()] || '' });
        else countWords.push(t);
      }
      const { cls } = renderDashboard(slug, { title: clean(title), icon: '📊', entities: entMeta, metrics: countWords, aggs });
      screens.push({ slug, cls, kind: 'dashboard', name: clean(title), icon: '📊', sub: `${(countWords.length + aggs.length) || entMeta.length} ${L.metricsWord}` });
    }
  }

  // 🖥 מחבר-ישות-למסך: הישויות-הראשונות ממלאות מסכי-Composed מפורקים אמיתיים, מחזוריות
  // על רישום-המסכים (כל ישות ⇒ תבנית-מסך אחרת) — הוכחת-הכללה על 3 צורות-שקע גנריות.
  // 🔐 היקף-RLS פר-ישות: שדה-ההיקף שתפקיד מגביל לפיו (role.scope). כל מסכי-החיווט
  // (בינד/הרכבה/כרטיס) מכבדים אותו (scoped) כמו מסך-הישות — אחרת משתמש-מוגבל רואה הכל.
  const scopeByEnt = {};
  for (const role of roles) for (const sc of (role.scope || [])) { const sl = nameToSlug[sc.ent]; if (sl && !scopeByEnt[sl]) scopeByEnt[sl] = sc.field; }

  const bindScreens = [];
  const bindN = Math.min(entMeta.length, SCREEN_REGISTRY.length);
  for (let bi = 0; bi < bindN; bi++) {
    const ent = entMeta[bi];
    const spec = SCREEN_REGISTRY[bi % SCREEN_REGISTRY.length];
    const bslug = `app_bind${bi + 1}`;
    const { cls } = renderScreenBind(bslug, { entitySlug: ent.slug, spec, scopeField: scopeByEnt[ent.slug] || null });
    bindScreens.push({ slug: bslug, cls, kind: 'entity', name: `🖥 ${ent.name} · ${L.screenTag}`, icon: '🖥', sub: T('realScreenSub', { cls: spec.cls.replace('Composed', '') }) });
  }

  // 🔎 מסכי-רשומה-בודדת: בורר-רשומה ⇒ שדות + KPI-יחסים (ילדים שמצביעים על הרשומה).
  // היחסים הם ערך פר-רשומה (countRef) — שייכים למסך-הפרט, לא לסקירה. נבנים ראשונים
  // כדי שמסך-הסקירה יוכל לנווט אליהם (הקלקה על שורה ⇒ הכרטיס של אותה רשומה).
  const detailScreens = [];
  const detailByEnt = {};
  let detN = 0;
  for (const e of entMeta) {
    const rels = (backRefs[e.name] || []).map((b) => ({ childSlug: b.fslug, childField: b.ffield, childName: b.fname }));
    const d = renderRecordDetail(`app_rec${++detN}`, { entitySlug: e.slug, entityName: e.name, fields: e.labels || [], relations: rels, scopeField: scopeByEnt[e.slug] || null });
    if (d) { detailScreens.push({ slug: d.slug, cls: d.cls, kind: 'entity', name: `🔎 ${e.name} · ${L.cardTag}`, icon: '🔎', sub: rels.length ? T('recordRels', { n: rels.length }) : L.singleRecord }); detailByEnt[e.slug] = { cls: d.cls, slug: d.slug }; }
    else detN--;
  }

  // 🧩 מסכי-הרכבה: אטום+אטום ⇒ מסך-סקירה חדש (לא ממחזר מסך-מוכן — מרכיב מלבנים).
  // לכל ישות "עשירה" (שדה-מספרי ו/או שלבים) נבנה מסך-סקירה: KPI + מגמה + התקדמות +
  // מבט-ראשי (לוח / רשימה-לחיצה⇒כרטיס). האטומים נבחרים מהמצע לפי-צורה.
  const composeScreens = [];
  let overN = 0;
  for (const e of entMeta) {
    if (!(e.stageLabels || []).length && !(e.numFields || []).length) continue;   // אין מה להרכיב מעבר ללי מסך-הישות
    const c = renderCompose(`app_over${++overN}`, { entitySlug: e.slug, entityName: e.name, fields: e.labels || [], numFields: e.numFields || [], stages: e.stageLabels || [], detail: detailByEnt[e.slug] || null, scopeField: scopeByEnt[e.slug] || null });
    if (c) composeScreens.push({ slug: c.slug, cls: c.cls, kind: 'entity', name: `🧩 ${e.name} · ${L.overviewTag}`, icon: '🧩', sub: L.composedSub });
    else overN--;
  }

  // מסכי-מערכת (kind='system' — גלויים רק לתפקיד 'הכל')
  const sys = [];
  const a = renderSystem('app_audit', { title: L.auditTitle, icon: '🧾', sectionTitle: L.auditSection, kind: 'empty', items: [L.auditEmpty] });
  sys.push({ ...a, kind: 'system', name: L.auditTitle, icon: '🧾', sub: L.auditSub });
  const fl = renderSystem('app_flags', { title: L.flagsTitle, icon: '🎚️', sectionTitle: L.flagsSection, kind: 'toggles', items: entMeta.slice(0, 12).map((e) => e.name) });
  sys.push({ ...fl, kind: 'system', name: L.flagsTitle, icon: '🎚️', sub: L.flagsSub });
  const st = renderSystem('app_settings', { title: L.settingsTitle, icon: '⚙️', sectionTitle: L.settingsSection, kind: 'toggles', items: [L.settingsItem1, L.settingsItem2, L.settingsItem3] });
  sys.push({ ...st, kind: 'system', name: L.settingsTitle, icon: '⚙️', sub: L.settingsSub });

  // RLS · שדות-היקף ייחודיים (slug+שדה) — למילוי בורר-"מי-אני" בלוח.
  const scopeFields = [];
  for (const role of roles) for (const sc of (role.scope || [])) { const sl = nameToSlug[sc.ent]; if (sl && !scopeFields.some((x) => x.slug === sl && x.field === sc.field)) scopeFields.push({ slug: sl, field: sc.field }); }
  const hub = renderHub('app_hub', { title: L.appTitle, icon: '🏗️', screens: [...screens, ...composeScreens, ...detailScreens, ...bindScreens, ...sys], roles, scopeFields });
  // שורש-האפליקציה: main + MaterialApp ⇒ אפליקציה עצמאית שרצה בלי entry-זמני.
  renderMain('app_main', { title: L.appTitle, hubSlug: 'app_hub', hubCls: hub.cls, edges });

  return { screens, sys, roles };
}

if (import.meta.url === 'file://' + process.argv[1]) {
  let spec;
  if (process.argv[2] === '-f') spec = fs.readFileSync(process.argv[3], 'utf8');
  else spec = process.argv.slice(2).join('\n');
  if (!spec.trim()) { console.error('שימוש: node app-ds.mjs -f spec.txt'); process.exit(1); }
  const { screens, sys } = buildApp(spec);
  const ents = screens.filter((s) => s.icon === '🗂️');
  console.log(`\n✨ אפליקציה (מערכת-עיצוב) חוללה — ${screens.length + sys.length + 1} מסכים`);
  console.log(`   ${ents.length} ישויות · ${screens.length - ents.length} דשבורדים · ${sys.length} מערכת · 1 לוח`);
  console.log('   הכל דרך render-ds הטהור (טיפוס נאחז מהאטומים · אפס regex).');
}
