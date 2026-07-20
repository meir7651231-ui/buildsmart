/**
 * רישום ווידג'טים של לוח הבית — כל מקטע במסך הבית הוא ווידג'ט רשום:
 * { id, label, icon, render, visible } — הסדר וההצגה נשלטים ע"י db.ui.homeLayout.
 *
 * חוזה:
 * - 'hero' (ברכה + פעולות מהירות) תמיד ראשון ואינו ניתן להסרה.
 * - visible(cfg) משמר את כל הגייטינג הקיים (featureOn / moduleOn) — ווידג'ט
 *   שאינו visible מדולג ברינדור גם אם הוא מופיע ב-homeLayout, בלי לגעת בנתונים.
 * - הרינדור עצמו זהה אחד-לאחד למסך הבית המקורי (re-plumbing, לא redesign).
 */
import { useEffect, useMemo, useState, type CSSProperties, type ReactElement, type ReactNode } from 'react';
import type { View } from '../../store/useApp';
import type { Db, Family, OrgEvent } from '../../types/domain';
import type { OrgConfig } from '../../types/config';
import { Btn, PageHead } from '../ui';
import { hebDateFull } from '../../lib/hebrew';
import { featureOn, moduleOn } from '../../lib/config';
import {
  DAY_NAMES,
  EV_META,
  evLabel,
  fmtD,
  ST_META,
  type AttentionItem,
  type AttentionNav,
  type BirthdayHit,
  type CarouselItem,
  type DigestLine,
  type HomeStats,
  type TodaySession,
} from './homeData';

/* ── סגנונות משותפים (verbatim מ-HomeView המקורי) ── */

const rowBtn: CSSProperties = {
  display: 'flex',
  alignItems: 'center',
  gap: 8,
  width: '100%',
  padding: '7px 6px',
  borderRadius: 8,
  textAlign: 'right',
  fontSize: 14,
  cursor: 'pointer',
};

const tagStyle = (bg: string, c: string): CSSProperties => ({
  background: bg,
  color: c,
  borderRadius: 999,
  padding: '2px 10px',
  fontSize: 12,
  fontWeight: 600,
  whiteSpace: 'nowrap',
  flexShrink: 0,
});

const softEmpty: CSSProperties = { color: 'var(--ink-faint)', fontSize: 13.5, padding: '6px 6px' };

/* ── קונטקסט משותף לכל הווידג'טים — מחושב פעם אחת ב-HomeView ── */

/** כל הנתונים הנגזרים של מסך הבית (useMemo ב-HomeView). */
export interface HomeData {
  stats: HomeStats;
  sessions: TodaySession[];
  events: OrgEvent[];
  bdays: BirthdayHit[];
  attention: AttentionItem[];
  digest: DigestLine[];
  carousel: CarouselItem[];
  recent: Family[];
  holiday: string | null;
}

/** מה שווידג'ט מקבל כדי לצייר את עצמו — נתונים + פעולות ניווט מה-store. */
export interface HomeCtx {
  db: Db;
  config: OrgConfig;
  now: Date;
  todayIso: string;
  data: HomeData;
  /** ניווט ממוגן-מודולים — לעולם לא מנווט למסך של מודול כבוי. */
  navTo: (nav: AttentionNav) => void;
  go: (view: View) => void;
  selectFamily: (id: string | null) => void;
  selectCourse: (id: string | null) => void;
  markAttnDone: (key: string) => void;
  unmarkAttnDone: (key: string) => void;
  /** כפתורי כותרת הבית (למשל "עריכת הלוח ✏️") — מוצגים בווידג'ט hero. */
  headActions?: ReactNode;
}

/* ── רכיבי עזר (verbatim מ-HomeView המקורי) ── */

function StatCard(props: { icon: string; label: string; value: string; sub: string; onClick: () => void }) {
  return (
    <button
      type="button"
      className="card"
      onClick={props.onClick}
      title={'מעבר: ' + props.label}
      style={{ textAlign: 'right', cursor: 'pointer', display: 'flex', flexDirection: 'column', gap: 3, padding: 14 }}
    >
      <span style={{ fontSize: 13, color: 'var(--ink-faint)' }}>
        <span aria-hidden>{props.icon}</span> {props.label}
      </span>
      <span style={{ fontSize: 26, fontWeight: 700, lineHeight: 1.1 }}>{props.value}</span>
      <span style={{ fontSize: 12.5, color: 'var(--ink-soft)' }}>{props.sub}</span>
    </button>
  );
}

function Panel(props: { title: string; badge?: string; action?: ReactNode; children: ReactNode }) {
  return (
    <section className="card" style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
        <h2 style={{ fontSize: 16.5, display: 'flex', alignItems: 'center', gap: 8 }}>
          {props.title}
          {props.badge && <span className="chip">{props.badge}</span>}
        </h2>
        {props.action}
      </div>
      {props.children}
    </section>
  );
}

/**
 * קרוסלת אירועים קרובים — מתחלפת כל 5 שניות, נעצרת בריחוף/פוקוס,
 * ומכבדת prefers-reduced-motion (ללא רוטציה אוטומטית). נקודות + חצים לניווט ידני.
 */
function Carousel(props: { items: CarouselItem[]; navTo: (nav: AttentionNav) => void }) {
  const { items } = props;
  const [idx, setIdx] = useState(0);
  const [paused, setPaused] = useState(false);
  const reduced = useMemo(
    () =>
      typeof window !== 'undefined' &&
      !!window.matchMedia &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches,
    [],
  );

  useEffect(() => {
    if (reduced || paused || items.length < 2) return;
    const t = setInterval(() => setIdx((i) => i + 1), 5000);
    return () => clearInterval(t);
  }, [reduced, paused, items.length]);

  const cur = items.length ? items[idx % items.length] : null;
  const step = (dir: 1 | -1) =>
    setIdx((i) => ((i % items.length) + items.length + dir) % items.length);

  return (
    <section
      className="card"
      aria-label="אירועים קרובים"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
      onFocus={() => setPaused(true)}
      onBlur={() => setPaused(false)}
      style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: 14 }}
    >
      {cur ? (
        <button
          type="button"
          key={cur.key}
          onClick={() => props.navTo(cur.nav)}
          title={cur.cta}
          style={{ display: 'flex', alignItems: 'center', gap: 12, width: '100%', textAlign: 'right', cursor: 'pointer' }}
        >
          <span aria-hidden style={{ fontSize: 30, flexShrink: 0 }}>{cur.icon}</span>
          <span style={{ display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
            <span style={{ fontWeight: 700, fontSize: 15.5 }}>{cur.title}</span>
            <span style={{ fontSize: 13, color: 'var(--ink-soft)' }}>{cur.sub}</span>
          </span>
          <span style={{ marginInlineStart: 'auto', fontSize: 13, color: 'var(--ink-faint)', whiteSpace: 'nowrap', flexShrink: 0 }}>
            {cur.cta}
          </span>
        </button>
      ) : (
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <span aria-hidden style={{ fontSize: 30 }}>🎂</span>
          <span style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <span style={{ fontWeight: 700, fontSize: 15.5 }}>אין אירועים קרובים</span>
            <span style={{ fontSize: 13, color: 'var(--ink-soft)' }}>14 הימים הקרובים שקטים</span>
          </span>
        </div>
      )}
      {items.length > 1 && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <button type="button" aria-label="הפריט הקודם" onClick={() => step(-1)} style={{ padding: '0 6px', color: 'var(--ink-faint)' }}>
            ‹
          </button>
          <div style={{ display: 'flex', gap: 6 }} role="tablist" aria-label="פריטי הקרוסלה">
            {items.slice(0, 8).map((it, i2) => {
              const active = i2 === (idx % items.length) % 8;
              return (
                <button
                  key={it.key}
                  type="button"
                  aria-label={`פריט ${i2 + 1}`}
                  aria-current={active}
                  onClick={() => setIdx(i2)}
                  style={{
                    width: 8,
                    height: 8,
                    borderRadius: 99,
                    padding: 0,
                    background: active ? 'var(--accent-deep)' : 'rgba(127, 119, 103, .3)',
                  }}
                />
              );
            })}
          </div>
          <button type="button" aria-label="הפריט הבא" onClick={() => step(1)} style={{ padding: '0 6px', color: 'var(--ink-faint)' }}>
            ›
          </button>
        </div>
      )}
    </section>
  );
}

/* ── רכיבי הווידג'טים עצמם ── */

/** ברכה (PageHead) + שורת פעולות מהירות — תמיד ראשון, לא ניתן להסרה. */
function HeroWidget({ ctx }: { ctx: HomeCtx }) {
  const { db, config, now, todayIso, data, go, selectCourse } = ctx;
  const coursesOn = moduleOn(config, 'courses');
  const calendarOn = moduleOn(config, 'calendar');
  const diaryOn = moduleOn(config, 'diary');
  const supportersOn = moduleOn(config, 'supporters');
  const reportsOn = moduleOn(config, 'reports');
  const hour = now.getHours();
  const greet = hour < 12 ? 'בוקר טוב' : hour < 18 ? 'צהריים טובים' : 'ערב טוב';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <PageHead
        title={`${greet}, ${config.orgName || db.orgName}`}
        sub={
          `יום ${DAY_NAMES[now.getDay()]}, ${hebDateFull(todayIso)} · ${fmtD(todayIso)}` +
          (data.holiday ? ` · ${data.holiday}` : '')
        }
        actions={ctx.headActions}
      />

      {/* פעולות מהירות — כפתור של מודול כבוי מוסתר */}
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        <Btn kind="primary" onClick={() => go('families')}>+ משפחה חדשה</Btn>
        {coursesOn && (
          <Btn
            onClick={() => (data.sessions.length ? selectCourse(data.sessions[0].course.id) : go('courses'))}
            title={data.sessions.length ? 'ניקוב מהיר — ' + data.sessions[0].course.name : 'אין מפגשים היום'}
          >
            ניקוב מהיר
          </Btn>
        )}
        {calendarOn && <Btn onClick={() => go('calendar')}>מי חוגג השבוע?</Btn>}
        {diaryOn && <Btn onClick={() => go('diary')}>יומן חדרים</Btn>}
        {supportersOn && <Btn onClick={() => go('supporters')}>תורמים</Btn>}
        {reportsOn && <Btn onClick={() => go('reports')}>דוחות</Btn>}
      </div>
    </div>
  );
}

/** תקציר הבוקר — מוצג רק כשהפיצ'ר home.digest פעיל. */
function DigestWidget({ ctx }: { ctx: HomeCtx }) {
  return (
    <section className="card" style={{ display: 'flex', flexDirection: 'column', gap: 4, padding: 14 }}>
      <h2 style={{ fontSize: 16.5, marginBottom: 4 }}>☀️ תקציר הבוקר</h2>
      {ctx.data.digest.map((l: DigestLine) => (
        <button
          key={l.key}
          type="button"
          style={{
            ...rowBtn,
            padding: '4px 6px',
            ...(l.urgent ? { color: '#b91c1c', fontWeight: 600 } : null),
          }}
          onClick={() => ctx.navTo(l.nav)}
        >
          {!l.urgent && <span aria-hidden style={{ color: 'var(--ink-faint)' }}>•</span>}
          <span>{l.text}</span>
        </button>
      ))}
    </section>
  );
}

/** כרטיסי נתונים — כרטיס של מודול כבוי מוסתר (כמו במקור). */
function StatsWidget({ ctx }: { ctx: HomeCtx }) {
  const { config, go } = ctx;
  const s = ctx.data.stats;
  const coursesOn = moduleOn(config, 'courses');
  const calendarOn = moduleOn(config, 'calendar');
  const supportersOn = moduleOn(config, 'supporters');
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(170px, 1fr))', gap: 12 }}>
      <StatCard
        icon="👨‍👩‍👧‍👦"
        label="משפחות"
        value={String(s.famTotal)}
        sub={`${s.famActive} פעילות · ${s.famPending} ממתינות · ${s.famInactive} לא פעילות`}
        onClick={() => go('families')}
      />
      <StatCard
        icon="🧒"
        label="בני משפחה"
        value={String(s.membersTotal)}
        sub={`מהם ${s.childrenTotal} ילדים`}
        onClick={() => go('families')}
      />
      {coursesOn && (
        <StatCard
          icon="🎨"
          label="חוגים פעילים"
          value={String(s.activeCourses)}
          sub={`${s.activeEnrollments} שיבוצים פעילים מתוך ${s.enrollTotal}`}
          onClick={() => go('courses')}
        />
      )}
      {calendarOn && (
        <StatCard
          icon="📅"
          label="אירועים פתוחים"
          value={String(s.eventsToday)}
          sub={`היום · ${s.eventsWeek} השבוע`}
          onClick={() => go('calendar')}
        />
      )}
      {supportersOn && (
        <StatCard
          icon="💛"
          label="תרומות"
          value={'₪' + s.donIls.toLocaleString('he-IL')}
          sub={(s.donUsd ? `+ $${s.donUsd.toLocaleString('he-IL')} · ` : '') + `${s.supportersTotal} תורמים`}
          onClick={() => go('supporters')}
        />
      )}
    </div>
  );
}

/** פאנל "היום" — מפגשי חוגים (כשהמודול פעיל), אירועים וימי הולדת. */
function TodayWidget({ ctx }: { ctx: HomeCtx }) {
  const { db, now, data, go, selectFamily, selectCourse } = ctx;
  const famName = (id: string) => db.families.find((f) => f.id === id)?.name ?? '';
  return (
    <Panel title={`היום · יום ${DAY_NAMES[now.getDay()]}`} badge={data.holiday ?? undefined}>
      <div style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--ink-faint)' }}>מפגשי חוגים</div>
      {data.sessions.length === 0 && <div style={softEmpty}>אין מפגשי חוגים היום</div>}
      {data.sessions.map((ts, i) => (
        <button
          key={ts.course.id + '-' + i}
          type="button"
          style={rowBtn}
          onClick={() => selectCourse(ts.course.id)}
          title="לכרטיס החוג"
        >
          <span style={tagStyle('#fdf1d4', '#9a6414')}>{ts.session.time || '—'}</span>
          <span>
            {ts.course.name}
            {ts.session.label ? ' · ' + ts.session.label : ''}
          </span>
          <span style={{ color: 'var(--ink-faint)', fontSize: 12.5, marginInlineStart: 'auto' }}>
            {db.rooms.find((r) => r.id === ts.course.roomId)?.name ?? ''}
          </span>
        </button>
      ))}

      <div style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--ink-faint)', marginTop: 6 }}>אירועים</div>
      {data.events.length === 0 && data.bdays.length === 0 && <div style={softEmpty}>אין אירועים היום</div>}
      {data.events.map((ev) => (
        <button
          key={ev.id}
          type="button"
          style={rowBtn}
          onClick={() => (ev.famId ? selectFamily(ev.famId) : go('calendar'))}
          title={ev.famId ? 'לכרטיס המשפחה' : 'ללוח השנה'}
        >
          <span style={tagStyle(EV_META[ev.type].bg, EV_META[ev.type].c)}>{evLabel(ev)}</span>
          <span>
            {(ev.time ? ev.time + ' · ' : '') + ev.title}
            {ev.famId ? ' · משפחת ' + famName(ev.famId) : ''}
          </span>
          {ev.priority !== 'green' && (
            <span
              aria-hidden
              style={{
                width: 8,
                height: 8,
                borderRadius: 99,
                flexShrink: 0,
                marginInlineStart: 'auto',
                background: ev.priority === 'red' ? '#dc2626' : '#d97706',
              }}
            />
          )}
        </button>
      ))}
      {data.bdays.map((b) => (
        <button
          key={b.member.id}
          type="button"
          style={rowBtn}
          onClick={() => selectFamily(b.member.famId)}
          title="לכרטיס המשפחה"
        >
          <span style={tagStyle('#fbeef3', '#be185d')}>יום הולדת</span>
          <span>
            {b.member.first} ({b.age}) · משפחת {b.member.famName}
          </span>
        </button>
      ))}
    </Panel>
  );
}

/** "דורש טיפול" — כולל מרכז טיפול (סימון טופל/ביטול) — פיצ'ר home.care. */
function AttentionWidget({ ctx }: { ctx: HomeCtx }) {
  const { db, data, navTo, markAttnDone, unmarkAttnDone } = ctx;
  const [showDone, setShowDone] = useState(false);
  // מרכז טיפול: הפרדת פריטים פתוחים מפריטים שסומנו "טופל"
  const attnDone = db.attnDone ?? {};
  const openAttn = data.attention.filter((a) => !attnDone[a.key]);
  const doneAttn = data.attention.filter((a) => attnDone[a.key]);

  return (
    <Panel title="דורש טיפול" badge={openAttn.length ? String(openAttn.length) : undefined}>
      {openAttn.length === 0 && (
        <div style={{ ...softEmpty, color: 'var(--green)', fontWeight: 600 }}>הכל מטופל ✓</div>
      )}
      {openAttn.slice(0, 8).map((a) => (
        <div key={a.key} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
          <button type="button" style={{ ...rowBtn, flex: 1, minWidth: 0 }} onClick={() => navTo(a.nav)}>
            <span style={tagStyle(a.tagBg, a.tagC)}>{a.tag}</span>
            <span>{a.title}</span>
          </button>
          <Btn sm onClick={() => markAttnDone(a.key)} title="סימון הפריט כטופל">
            ✓ טופל
          </Btn>
        </div>
      ))}
      {openAttn.length > 8 && (
        <div style={softEmpty}>+{openAttn.length - 8} פריטים נוספים</div>
      )}
      {doneAttn.length > 0 && (
        <button
          type="button"
          style={{ ...softEmpty, textAlign: 'right', cursor: 'pointer', textDecoration: 'underline' }}
          onClick={() => setShowDone((v) => !v)}
        >
          {showDone ? 'הסתרת שטופלו' : `הצג שטופלו (${doneAttn.length})`}
        </button>
      )}
      {showDone &&
        doneAttn.map((a) => (
          <div
            key={a.key}
            style={{ display: 'flex', alignItems: 'center', gap: 8, opacity: 0.55, fontSize: 13.5, padding: '4px 6px' }}
          >
            <span style={tagStyle(a.tagBg, a.tagC)}>{a.tag}</span>
            <span style={{ textDecoration: 'line-through', minWidth: 0 }}>{a.title}</span>
            <span
              style={{ marginInlineStart: 'auto', fontSize: 12, color: 'var(--ink-faint)', whiteSpace: 'nowrap', flexShrink: 0 }}
            >
              טופל {fmtD(attnDone[a.key])}
            </span>
            <Btn sm onClick={() => unmarkAttnDone(a.key)} title="החזרת הפריט לרשימה הפתוחה">
              ביטול
            </Btn>
          </div>
        ))}
    </Panel>
  );
}

/** משפחות אחרונות — טבלה + מצב ריק. */
function RecentWidget({ ctx }: { ctx: HomeCtx }) {
  const { data, go, selectFamily } = ctx;
  return (
    <Panel
      title="משפחות אחרונות"
      action={<Btn sm onClick={() => go('families')}>כל המשפחות ←</Btn>}
    >
      {data.recent.length === 0 ? (
        <div className="empty">
          אין משפחות עדיין — הוסיפו את המשפחה הראשונה
          <div style={{ marginTop: 12 }}>
            <Btn kind="primary" onClick={() => go('families')}>+ משפחה חדשה</Btn>
          </div>
        </div>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>משפחה</th>
              <th>טלפון</th>
              <th>עיר</th>
              <th>ילדים</th>
              <th>סטטוס</th>
              <th>הצטרפה</th>
            </tr>
          </thead>
          <tbody>
            {data.recent.map((f) => (
              <tr key={f.id} onClick={() => selectFamily(f.id)} style={{ cursor: 'pointer' }} title="לכרטיס המשפחה">
                <td style={{ fontWeight: 600 }}>משפחת {f.name}</td>
                <td dir="ltr" style={{ textAlign: 'right' }}>{f.phone || '—'}</td>
                <td>{f.city || '—'}</td>
                <td>{f.members.filter((m) => !m.isParent).length}</td>
                <td>
                  <span style={tagStyle(ST_META[f.status].bg, ST_META[f.status].c)}>
                    {ST_META[f.status].label}
                  </span>
                </td>
                <td>{fmtD(f.createdAt)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </Panel>
  );
}

/* ── הרישום עצמו ── */

export type WidgetId = 'hero' | 'digest' | 'carousel' | 'stats' | 'today' | 'attention' | 'recent';

export interface HomeWidget {
  id: WidgetId;
  /** שם תצוגה — למסגרת העריכה ולצ'יפים של "הוספת ווידג'ט". */
  label: string;
  icon: string;
  /**
   * רוחב במצב תצוגה: 'half' — חצאים סמוכים בפריסה יושבים זה לצד זה
   * בגריד auto-fit (בדיוק כמו "היום" + "דורש טיפול" במקור); 'full' — שורה מלאה.
   */
  slot: 'full' | 'half';
  /** hero אינו ניתן להסרה — תמיד ראשון בלוח. */
  removable: boolean;
  /** גייטינג קיים — ווידג'ט לא-visible מדולג ברינדור גם אם הוא בפריסה. */
  visible: (cfg: OrgConfig) => boolean;
  render: (ctx: HomeCtx) => ReactElement;
}

export const HOME_WIDGETS: Record<WidgetId, HomeWidget> = {
  hero: {
    id: 'hero',
    label: 'ברכה ופעולות מהירות',
    icon: '🏠',
    slot: 'full',
    removable: false,
    visible: () => true,
    render: (ctx) => <HeroWidget ctx={ctx} />,
  },
  digest: {
    id: 'digest',
    label: 'תקציר הבוקר',
    icon: '☀️',
    slot: 'full',
    removable: true,
    // מוסתר כשהפיצ'ר home.digest כבוי (כמו במקור)
    visible: (cfg) => featureOn(cfg, 'home.digest'),
    render: (ctx) => <DigestWidget ctx={ctx} />,
  },
  carousel: {
    id: 'carousel',
    label: 'אירועים קרובים',
    icon: '🎂',
    slot: 'full',
    removable: true,
    // מוסתרת כשהפיצ'ר home.carousel כבוי (כמו במקור)
    visible: (cfg) => featureOn(cfg, 'home.carousel'),
    render: (ctx) => <Carousel items={ctx.data.carousel} navTo={ctx.navTo} />,
  },
  stats: {
    id: 'stats',
    label: 'כרטיסי נתונים',
    icon: '📊',
    slot: 'full',
    removable: true,
    // הגריד עצמו תמיד מוצג — כרטיסים בודדים מוסתרים לפי מודול (כמו במקור)
    visible: () => true,
    render: (ctx) => <StatsWidget ctx={ctx} />,
  },
  today: {
    id: 'today',
    label: 'היום',
    icon: '📅',
    slot: 'half',
    removable: true,
    // הפאנל תמיד מוצג (גם אירועים וימי הולדת) — רשימת המפגשים בתוכו
    // כפופה למודול החוגים דרך data.sessions (כמו במקור)
    visible: () => true,
    render: (ctx) => <TodayWidget ctx={ctx} />,
  },
  attention: {
    id: 'attention',
    label: 'דורש טיפול',
    icon: '🔔',
    slot: 'half',
    removable: true,
    // מוסתר כולו כשהפיצ'ר home.care כבוי (כמו במקור)
    visible: (cfg) => featureOn(cfg, 'home.care'),
    render: (ctx) => <AttentionWidget ctx={ctx} />,
  },
  recent: {
    id: 'recent',
    label: 'משפחות אחרונות',
    icon: '👨‍👩‍👧‍👦',
    slot: 'full',
    removable: true,
    visible: () => true,
    render: (ctx) => <RecentWidget ctx={ctx} />,
  },
};

/** סדר ברירת המחדל — זהה לסדר המסך המקורי. */
export const DEFAULT_LAYOUT: readonly WidgetId[] = [
  'hero',
  'digest',
  'carousel',
  'stats',
  'today',
  'attention',
  'recent',
];

function isWidgetId(id: string): id is WidgetId {
  return id in HOME_WIDGETS;
}

/**
 * נרמול פריסה שמורה (db.ui.homeLayout) לרשימת מזהים תקפה:
 * undefined/ריק → ברירת המחדל; מזהים לא מוכרים/כפולים מסוננים; hero תמיד ראשון.
 */
export function sanitizeLayout(raw: readonly string[] | undefined): WidgetId[] {
  if (!raw || raw.length === 0) return [...DEFAULT_LAYOUT];
  const out: WidgetId[] = [];
  for (const id of raw) {
    if (isWidgetId(id) && !out.includes(id)) out.push(id);
  }
  const i = out.indexOf('hero');
  if (i > 0) out.splice(i, 1);
  if (i !== 0) out.unshift('hero');
  return out;
}
