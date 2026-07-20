/**
 * פלטת פקודות (Ctrl+K) — חיפוש מהיר בכל המערכת:
 * מסכים, משפחות, בני משפחה, חוגים, תורמים, אירועים ופעולות.
 *
 * App מרנדר את הרכיב רק כאשר paletteOpen=true; סגירה דרך setPalette(false).
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { allMembers, useApp, type View } from '../../store/useApp';
import { normSearch } from '../../lib/validate';

/** פריט בר-הפעלה בפלטה: אייקון + כותרת + שורת משנה + פעולה. */
interface Cmd {
  key: string;
  icon: string;
  title: string;
  sub: string;
  /** מונחי חיפוש מנורמלים (normSearch) — מחרוזות שלמות + מילים בודדות. */
  terms: string[];
  run: () => void;
}

/** פקודות ניווט — זהות לתפריט הראשי ב-App (משוכפל כאן כי NAV אינו מיוצא). */
const NAV_CMDS: { view: View; icon: string; label: string }[] = [
  { view: 'home', icon: '🏠', label: 'בית' },
  { view: 'families', icon: '👨‍👩‍👧‍👦', label: 'משפחות' },
  { view: 'courses', icon: '🎨', label: 'חוגים' },
  { view: 'calendar', icon: '📅', label: 'לוח שנה' },
  { view: 'diary', icon: '📖', label: 'יומן חדרים' },
  { view: 'supporters', icon: '💛', label: 'תורמים' },
  { view: 'reports', icon: '📊', label: 'דוחות' },
  { view: 'settings', icon: '⚙️', label: 'הגדרות' },
];

const DAY_NAMES = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי'];

const MAX_RESULTS = 12;

/** תאריך ISO ‏(YYYY-MM-DD) → תצוגה DD/MM/YYYY. */
function fmtDate(iso: string): string {
  const [y, m, d] = iso.split('-');
  return y && m && d ? `${d}/${m}/${y}` : iso;
}

/** בונה מונחי חיפוש מנורמלים ממחרוזות גולמיות — המחרוזת השלמה וגם כל מילה. */
function toTerms(raw: (string | undefined)[]): string[] {
  const out = new Set<string>();
  for (const r of raw) {
    if (!r) continue;
    const whole = normSearch(r);
    if (whole) out.add(whole);
    for (const word of r.split(/\s+/)) {
      const n = normSearch(word);
      if (n) out.add(n);
    }
  }
  return [...out];
}

/** ספרות בלבד — לחיפוש טלפונים בלי מקפים/רווחים. */
function digits(s: string): string {
  return s.replace(/\D/g, '');
}

export function CommandPalette() {
  const db = useApp((s) => s.db);
  const go = useApp((s) => s.go);
  const selectFamily = useApp((s) => s.selectFamily);
  const selectCourse = useApp((s) => s.selectCourse);
  const setPalette = useApp((s) => s.setPalette);
  const exportBackup = useApp((s) => s.exportBackup);

  const [q, setQ] = useState('');
  const [sel, setSel] = useState(0);
  const listRef = useRef<HTMLDivElement>(null);

  /** ניווט + פעולות — מוצגים גם כשאין שאילתה. */
  const baseCmds = useMemo<Cmd[]>(() => {
    const nav: Cmd[] = NAV_CMDS.map((n) => ({
      key: 'nav-' + n.view,
      icon: n.icon,
      title: n.label,
      sub: 'מעבר למסך',
      terms: toTerms([n.label, 'מסך', 'ניווט', 'מעבר']),
      run: () => {
        go(n.view);
        setPalette(false);
      },
    }));
    const actions: Cmd[] = [
      {
        key: 'act-new-family',
        icon: '➕',
        title: 'משפחה חדשה',
        sub: 'מעבר למסך המשפחות לרישום',
        terms: toTerms(['משפחה חדשה', 'הוספה', 'רישום', 'קליטה']),
        run: () => {
          selectFamily(null);
          setPalette(false);
        },
      },
      {
        key: 'act-backup',
        icon: '⬇️',
        title: 'הורדת גיבוי מלא',
        sub: 'קובץ גיבוי JSON יורד למחשב',
        terms: toTerms(['הורדת גיבוי מלא', 'גיבוי', 'ייצוא', 'שמירה', 'backup']),
        run: () => {
          exportBackup();
          setPalette(false);
        },
      },
    ];
    return [...nav, ...actions];
  }, [go, selectFamily, exportBackup, setPalette]);

  /** ישויות מהנתונים — משפחות, בני משפחה, חוגים, תורמים ואירועים פתוחים. */
  const entityCmds = useMemo<Cmd[]>(() => {
    const out: Cmd[] = [];
    for (const f of db.families) {
      out.push({
        key: 'fam-' + f.id,
        icon: '👨‍👩‍👧‍👦',
        title: 'משפחת ' + f.name,
        sub: [f.city, f.phone].filter(Boolean).join(' · '),
        terms: toTerms([
          f.name,
          'משפחת ' + f.name,
          f.father,
          f.mother,
          f.city,
          f.community,
          digits(f.phone),
          digits(f.phone2),
        ]),
        run: () => {
          selectFamily(f.id);
          setPalette(false);
        },
      });
    }
    for (const m of allMembers(db)) {
      out.push({
        key: 'mem-' + m.famId + '-' + m.id,
        icon: m.isParent ? '🧑' : m.gender === 'f' ? '👧' : '👦',
        title: (m.first + ' ' + m.famName).trim(),
        sub: ['משפחת ' + m.famName, m.phone].filter(Boolean).join(' · '),
        terms: toTerms([m.first, m.famName, m.school, m.grade, digits(m.phone), m.idNum]),
        run: () => {
          selectFamily(m.famId);
          setPalette(false);
        },
      });
    }
    for (const c of db.courses) {
      const teacher = db.teachers.find((t) => t.id === c.teacherId);
      out.push({
        key: 'crs-' + c.id,
        icon: '🎨',
        title: c.name,
        sub: ['יום ' + (DAY_NAMES[c.weekday] ?? ''), c.time, teacher?.name].filter(Boolean).join(' · '),
        terms: toTerms([c.name, c.cat, c.semester, c.audience, teacher?.name, 'חוג', 'קורס']),
        run: () => {
          selectCourse(c.id);
          setPalette(false);
        },
      });
    }
    for (const sp of db.supporters) {
      out.push({
        key: 'sup-' + sp.id,
        icon: '💛',
        title: sp.name,
        sub: [sp.cat, sp.phone].filter(Boolean).join(' · '),
        terms: toTerms([sp.name, sp.cat, sp.forWho, sp.email, digits(sp.phone), sp.idNum, 'תורם', 'תרומה', 'תומכת']),
        run: () => {
          go('supporters');
          setPalette(false);
        },
      });
    }
    for (const ev of db.events) {
      if (ev.done) continue;
      out.push({
        key: 'ev-' + ev.id,
        icon: '📅',
        title: ev.title,
        sub: [fmtDate(ev.date), ev.time].filter(Boolean).join(' · '),
        terms: toTerms([ev.title, ev.customType, 'אירוע', 'תזכורת', 'לוח']),
        run: () => {
          go('calendar');
          setPalette(false);
        },
      });
    }
    return out;
  }, [db, go, selectFamily, selectCourse, setPalette]);

  /** דירוג: התאמת תחילית מדויקת קודם, אחריה הכלה. עד 12 תוצאות. */
  const results = useMemo<Cmd[]>(() => {
    const nq = normSearch(q);
    if (!nq) return baseCmds.slice(0, MAX_RESULTS);
    const prefix: Cmd[] = [];
    const contains: Cmd[] = [];
    for (const c of [...baseCmds, ...entityCmds]) {
      if (prefix.length >= MAX_RESULTS) break;
      if (c.terms.some((t) => t.startsWith(nq))) prefix.push(c);
      else if (c.terms.some((t) => t.includes(nq))) contains.push(c);
    }
    return [...prefix, ...contains].slice(0, MAX_RESULTS);
  }, [q, baseCmds, entityCmds]);

  // איפוס הבחירה כשהשאילתה משתנה, והצמדה לטווח כשהתוצאות מתקצרות.
  useEffect(() => {
    setSel(0);
  }, [q]);
  useEffect(() => {
    setSel((i) => Math.min(i, Math.max(0, results.length - 1)));
  }, [results]);

  // מקלדת: חצים לניווט, Enter להפעלה, Escape לסגירה.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        setPalette(false);
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        setSel((i) => Math.min(i + 1, Math.max(0, results.length - 1)));
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        setSel((i) => Math.max(i - 1, 0));
      } else if (e.key === 'Enter') {
        const r = results[sel];
        if (r) {
          e.preventDefault();
          r.run();
        }
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [results, sel, setPalette]);

  // גלילת הפריט הנבחר לתוך שדה הראייה.
  useEffect(() => {
    listRef.current?.querySelector('button.sel')?.scrollIntoView({ block: 'nearest' });
  }, [sel, results]);

  return (
    <div
      className="palette-back"
      role="presentation"
      onMouseDown={(e) => e.target === e.currentTarget && setPalette(false)}
    >
      <div className="palette" role="dialog" aria-label="חיפוש מהיר">
        <input
          autoFocus
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="חיפוש: מסך, משפחה, שם, חוג, תורם או פעולה…"
          aria-label="חיפוש מהיר בכל המערכת"
        />
        <div className="results" ref={listRef} role="listbox" aria-label="תוצאות חיפוש">
          {results.map((c, i) => (
            <button
              key={c.key}
              type="button"
              className={i === sel ? 'sel' : ''}
              role="option"
              aria-selected={i === sel}
              onMouseEnter={() => setSel(i)}
              onClick={c.run}
            >
              <span aria-hidden>{c.icon}</span>
              <span style={{ fontWeight: 600 }}>{c.title}</span>
              {c.sub && (
                <span style={{ color: 'var(--ink-faint)', fontSize: 12.5, marginInlineStart: 'auto' }}>{c.sub}</span>
              )}
            </button>
          ))}
          {results.length === 0 && (
            <div className="empty" style={{ padding: '24px 16px' }}>
              לא נמצאו תוצאות עבור "{q}"
            </div>
          )}
        </div>
        <div
          style={{
            display: 'flex',
            gap: 14,
            padding: '8px 16px',
            borderTop: '1px solid var(--line)',
            color: 'var(--ink-faint)',
            fontSize: 12,
          }}
        >
          <span>↑↓ ניווט</span>
          <span>Enter בחירה</span>
          <span>Esc סגירה</span>
        </div>
      </div>
    </div>
  );
}
