/**
 * מסך הבית — לוח מחוונים: ברכה עם תאריך עברי ולועזי, כרטיסי נתונים,
 * פאנל "היום", פעולות מהירות, "דורש טיפול" ומשפחות אחרונות.
 */
import { useEffect, useMemo, useState, type CSSProperties, type ReactNode } from 'react';
import { useApp } from '../../store/useApp';
import { Btn, PageHead } from '../ui';
import { hebDateFull, holidayOf } from '../../lib/hebrew';
import { featureOn, moduleOn } from '../../lib/config';
import {
  attentionItems,
  birthdaysOn,
  carouselItems,
  DAY_NAMES,
  digestLines,
  EV_META,
  evLabel,
  eventsOnDate,
  fmtD,
  homeStats,
  isoOf,
  recentFamilies,
  ST_META,
  todaySessions,
  type AttentionNav,
  type CarouselItem,
} from './homeData';

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

export function HomeView() {
  const db = useApp((s) => s.db);
  const config = useApp((s) => s.config);
  const cfgName = config.orgName;
  // חוזה המודולים (types/config.ts): מודול כבוי מוסתר מכל משטחי הבית — בלי למחוק נתונים
  const coursesOn = moduleOn(config, 'courses');
  const calendarOn = moduleOn(config, 'calendar');
  const diaryOn = moduleOn(config, 'diary');
  const supportersOn = moduleOn(config, 'supporters');
  const reportsOn = moduleOn(config, 'reports');
  // גייטים ברמת פיצ'ר — מפתח חסר = פעיל (featureOn), בלי למחוק נתונים
  const digestOn = featureOn(config, 'home.digest');
  const carouselOn = featureOn(config, 'home.carousel');
  const careOn = featureOn(config, 'home.care');
  const go = useApp((s) => s.go);
  const selectFamily = useApp((s) => s.selectFamily);
  const selectCourse = useApp((s) => s.selectCourse);
  const markAttnDone = useApp((s) => s.markAttnDone);
  const unmarkAttnDone = useApp((s) => s.unmarkAttnDone);
  const [showDone, setShowDone] = useState(false);

  const now = new Date();
  const todayIso = isoOf(now);

  const c = useMemo(
    () => ({
      stats: homeStats(db, new Date(todayIso + 'T12:00:00')),
      sessions: coursesOn ? todaySessions(db, now) : [],
      events: eventsOnDate(db, now),
      bdays: birthdaysOn(db, now),
      attention: attentionItems(db, now, config.modules),
      digest: digestLines(db, now, config.modules),
      carousel: carouselItems(db, now),
      recent: recentFamilies(db, 5),
      holiday: holidayOf(now),
    }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [db, todayIso, config.modules, coursesOn],
  );

  // מרכז טיפול: הפרדת פריטים פתוחים מפריטים שסומנו "טופל"
  const attnDone = db.attnDone ?? {};
  const openAttn = c.attention.filter((a) => !attnDone[a.key]);
  const doneAttn = c.attention.filter((a) => attnDone[a.key]);

  // ניווט ממוגן-מודולים: לעולם לא מנווט למסך של מודול כבוי (no-op במקום קריסה/דליפה)
  const navTo = (nav: AttentionNav) => {
    if (nav.kind === 'course') selectCourse(nav.id);
    else if (nav.kind === 'family') selectFamily(nav.id);
    else if (nav.kind === 'supporters') {
      if (supportersOn) go('supporters');
    } else if (calendarOn) go('calendar');
  };

  const hour = now.getHours();
  const greet = hour < 12 ? 'בוקר טוב' : hour < 18 ? 'צהריים טובים' : 'ערב טוב';
  const famName = (id: string) => db.families.find((f) => f.id === id)?.name ?? '';
  const s = c.stats;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <PageHead
        title={`${greet}, ${cfgName || db.orgName}`}
        sub={
          `יום ${DAY_NAMES[now.getDay()]}, ${hebDateFull(todayIso)} · ${fmtD(todayIso)}` +
          (c.holiday ? ` · ${c.holiday}` : '')
        }
      />

      {/* תקציר הבוקר — מוסתר כשהפיצ'ר home.digest כבוי */}
      {digestOn && (
        <section className="card" style={{ display: 'flex', flexDirection: 'column', gap: 4, padding: 14 }}>
          <h2 style={{ fontSize: 16.5, marginBottom: 4 }}>☀️ תקציר הבוקר</h2>
          {c.digest.map((l) => (
            <button
              key={l.key}
              type="button"
              style={{
                ...rowBtn,
                padding: '4px 6px',
                ...(l.urgent ? { color: '#b91c1c', fontWeight: 600 } : null),
              }}
              onClick={() => navTo(l.nav)}
            >
              {!l.urgent && <span aria-hidden style={{ color: 'var(--ink-faint)' }}>•</span>}
              <span>{l.text}</span>
            </button>
          ))}
        </section>
      )}

      {/* קרוסלת אירועים קרובים — מוסתרת כשהפיצ'ר home.carousel כבוי */}
      {carouselOn && <Carousel items={c.carousel} navTo={navTo} />}

      {/* כרטיסי נתונים */}
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

      {/* פעולות מהירות — כפתור של מודול כבוי מוסתר */}
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        <Btn kind="primary" onClick={() => go('families')}>+ משפחה חדשה</Btn>
        {coursesOn && (
          <Btn
            onClick={() => (c.sessions.length ? selectCourse(c.sessions[0].course.id) : go('courses'))}
            title={c.sessions.length ? 'ניקוב מהיר — ' + c.sessions[0].course.name : 'אין מפגשים היום'}
          >
            ניקוב מהיר
          </Btn>
        )}
        {calendarOn && <Btn onClick={() => go('calendar')}>מי חוגג השבוע?</Btn>}
        {diaryOn && <Btn onClick={() => go('diary')}>יומן חדרים</Btn>}
        {supportersOn && <Btn onClick={() => go('supporters')}>תורמים</Btn>}
        {reportsOn && <Btn onClick={() => go('reports')}>דוחות</Btn>}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: 14 }}>
        {/* היום */}
        <Panel title={`היום · יום ${DAY_NAMES[now.getDay()]}`} badge={c.holiday ?? undefined}>
          <div style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--ink-faint)' }}>מפגשי חוגים</div>
          {c.sessions.length === 0 && <div style={softEmpty}>אין מפגשי חוגים היום</div>}
          {c.sessions.map((ts, i) => (
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
          {c.events.length === 0 && c.bdays.length === 0 && <div style={softEmpty}>אין אירועים היום</div>}
          {c.events.map((ev) => (
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
          {c.bdays.map((b) => (
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

        {/* דורש טיפול — מוסתר כולו כשהפיצ'ר home.care כבוי */}
        {careOn && (
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
        )}
      </div>

      {/* משפחות אחרונות */}
      <Panel
        title="משפחות אחרונות"
        action={<Btn sm onClick={() => go('families')}>כל המשפחות ←</Btn>}
      >
        {c.recent.length === 0 ? (
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
              {c.recent.map((f) => (
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
    </div>
  );
}
