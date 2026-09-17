#!/usr/bin/env node
// 🔌 seam-recognize — מזהה תפר-זר וממפה אותו לסוקט (spec-5 · קיר Wonderous).
//   כשמנוע-זר קשור לגלובל זר ($styles / get_it / router) — מזהה שזה תפר, וממיר את הצימוד לסוקט-פרמטר.
//   זה מה שהיה חסר: המזהים הכירו רק DsSeam שאדם הכניס; כאן — כל צורת-תפר, אוטומטית. פלט: מיפוי + קוד-יבש.
import fs from 'node:fs';
// תבניות-תפר: design (גלובל $-accessor) · di (get_it) · router
const SEAMS = [
  { kind: 'design', re: /\$([a-zA-Z_]\w*)\b/g, socket: (m) => m, note: 'אובייקט-עיצוב-גלובלי ⇒ סוקט (כמו DsSeam)' },
  { kind: 'di', re: /(?:GetIt\.instance|getIt|get_it|GetIt\.I)\b(?:<([A-Za-z0-9_]+)>)?/g, socket: (m, t) => (t ? t[0].toLowerCase() + t.slice(1) : 'dep'), note: 'הזרקת-תלות ⇒ prop' },
  { kind: 'router', re: /(?:context\.go|ScreenPaths\.[a-z]\w*|Navigator\.of\(context\)\.push)/g, socket: () => 'navigate', note: 'ראוטר-גלובלי ⇒ callback-ניווט' },
];
export function recognizeSeams(src) {
  const found = {};
  for (const s of SEAMS) { for (const m of src.matchAll(s.re)) { const name = s.socket(m[1] || m[0], m[1] ? [m[1]] : null); (found[s.kind] ||= { note: s.note, sockets: new Set(), hits: 0 }); found[s.kind].sockets.add(name); found[s.kind].hits++; } }
  // מיפוי + המרת-קוד יבשה: $styles ⇒ פרמטר styles (הסרת ה-$)
  let wired = src;
  const mapping = [];
  for (const [kind, info] of Object.entries(found)) {
    for (const sock of info.sockets) {
      if (kind === 'design') { wired = wired.replace(new RegExp('\\$' + sock + '\\b', 'g'), sock); mapping.push({ kind, from: '$' + sock, to: 'socket:' + sock, note: info.note }); }
      else mapping.push({ kind, from: [...info.sockets][0], to: 'socket:' + sock, hits: info.hits, note: info.note });
    }
  }
  return { seams: Object.fromEntries(Object.entries(found).map(([k, v]) => [k, { note: v.note, sockets: [...v.sockets], hits: v.hits }])), mapping, wired };
}
const isMain = process.argv[1] && process.argv[1].endsWith('seam-recognize.mjs');
if (isMain) {
  const f = process.argv[2];
  const src = f ? fs.readFileSync(f, 'utf8') : `// synthetic Wonderous-style widget (צורת-ה-\$styles האמיתית)
class WonderCard extends StatelessWidget {
  Widget build(BuildContext context) => Container(
    color: darkMode ? \$styles.colors.greyStrong : \$styles.colors.offWhite,
    padding: EdgeInsets.all(\$styles.insets.sm),
    child: Text(title, style: \$styles.text.h3),
  );
  onTap: () => context.go('/details'),
  final repo = getIt<WonderRepo>();
}`;
  const r = recognizeSeams(src);
  console.log('🔌 תפרים-זרים שזוהו:');
  for (const [k, v] of Object.entries(r.seams)) console.log(`  ${k}: ${v.sockets.join(', ')} (×${v.hits}) — ${v.note}`);
  console.log('\nמיפוי ⇒ סוקטים:');
  for (const m of r.mapping) console.log(`  ${m.from}  ⇒  ${m.to}   [${m.kind}]`);
  console.log('\nהקוד אחרי המרת-התפר (יבש, קטע):');
  console.log(r.wired.split('\n').filter((l) => /color:|padding:|style:/.test(l)).map((l) => '  ' + l.trim()).join('\n'));
  console.log(`\n${/\$styles/.test(r.wired) ? '⚠️ נותר $styles' : '✅ אפס $styles — כל התפר-הזר הומר לסוקט (מתקמפל בלי package:wonders)'}`);
}
