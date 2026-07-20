/**
 * מסך הבית — לוח מחוונים: ברכה עם תאריך עברי ולועזי, כרטיסי נתונים,
 * פאנל "היום", פעולות מהירות, "דורש טיפול" ומשפחות אחרונות.
 */
import { useMemo, type CSSProperties, type ReactNode } from 'react';
import { useApp } from '../../store/useApp';
import { Btn, PageHead } from '../ui';
import { hebDateFull, holidayOf } from '../../lib/hebrew';
import {
  attentionItems,
  birthdaysOn,
  DAY_NAMES,
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

export function HomeView() {
  const db = useApp((s) => s.db);
  const go = useApp((s) => s.go);
  const selectFamily = useApp((s) => s.selectFamily);
  const selectCourse = useApp((s) => s.selectCourse);

  const now = new Date();
  const todayIso = isoOf(now);

  const c = useMemo(
    () => ({
      stats: homeStats(db, new Date(todayIso + 'T12:00:00')),
      sessions: todaySessions(db, now),
      events: eventsOnDate(db, now),
      bdays: birthdaysOn(db, now),
      attention: attentionItems(db, now),
      recent: recentFamilies(db, 5),
      holiday: holidayOf(now),
    }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [db, todayIso],
  );

  const navTo = (nav: AttentionNav) => {
    if (nav.kind === 'course') selectCourse(nav.id);
    else if (nav.kind === 'family') selectFamily(nav.id);
    else go('calendar');
  };

  const hour = now.getHours();
  const greet = hour < 12 ? 'בוקר טוב' : hour < 18 ? 'צהריים טובים' : 'ערב טוב';
  const famName = (id: string) => db.families.find((f) => f.id === id)?.name ?? '';
  const s = c.stats;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <PageHead
        title={`${greet}, ${db.orgName}`}
        sub={
          `יום ${DAY_NAMES[now.getDay()]}, ${hebDateFull(todayIso)} · ${fmtD(todayIso)}` +
          (c.holiday ? ` · ${c.holiday}` : '')
        }
      />

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
        <StatCard
          icon="🎨"
          label="חוגים פעילים"
          value={String(s.activeCourses)}
          sub={`${s.activeEnrollments} שיבוצים פעילים מתוך ${s.enrollTotal}`}
          onClick={() => go('courses')}
        />
        <StatCard
          icon="📅"
          label="אירועים פתוחים"
          value={String(s.eventsToday)}
          sub={`היום · ${s.eventsWeek} השבוע`}
          onClick={() => go('calendar')}
        />
        <StatCard
          icon="💛"
          label="תרומות"
          value={'₪' + s.donIls.toLocaleString('he-IL')}
          sub={(s.donUsd ? `+ $${s.donUsd.toLocaleString('he-IL')} · ` : '') + `${s.supportersTotal} תורמים`}
          onClick={() => go('supporters')}
        />
      </div>

      {/* פעולות מהירות */}
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        <Btn kind="primary" onClick={() => go('families')}>+ משפחה חדשה</Btn>
        <Btn
          onClick={() => (c.sessions.length ? selectCourse(c.sessions[0].course.id) : go('courses'))}
          title={c.sessions.length ? 'ניקוב מהיר — ' + c.sessions[0].course.name : 'אין מפגשים היום'}
        >
          ניקוב מהיר
        </Btn>
        <Btn onClick={() => go('calendar')}>מי חוגג השבוע?</Btn>
        <Btn onClick={() => go('diary')}>יומן חדרים</Btn>
        <Btn onClick={() => go('supporters')}>תורמים</Btn>
        <Btn onClick={() => go('reports')}>דוחות</Btn>
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

        {/* דורש טיפול */}
        <Panel title="דורש טיפול" badge={c.attention.length ? String(c.attention.length) : undefined}>
          {c.attention.length === 0 && (
            <div style={{ ...softEmpty, color: 'var(--green)', fontWeight: 600 }}>הכל מטופל ✓</div>
          )}
          {c.attention.slice(0, 8).map((a) => (
            <button key={a.key} type="button" style={rowBtn} onClick={() => navTo(a.nav)}>
              <span style={tagStyle(a.tagBg, a.tagC)}>{a.tag}</span>
              <span>{a.title}</span>
            </button>
          ))}
          {c.attention.length > 8 && (
            <div style={softEmpty}>+{c.attention.length - 8} פריטים נוספים</div>
          )}
        </Panel>
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
