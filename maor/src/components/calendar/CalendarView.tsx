/**
 * לוח שנה חודשי — רשת ראשון–שבת (RTL) עם ניווט חודשים, כפתור "היום",
 * מצב חודש עברי מלא (א׳–ל׳), חגים, אירועים (כולל חזרה שנתית לפי
 * התאריך העברי), מפגשי חוגים, ורשימת אירועים קרובים ל-14 יום.
 */
import { useMemo, useState, type CSSProperties } from 'react';
import { useApp } from '../../store/useApp';
import { Btn, Empty, PageHead } from '../ui';
import type { OrgEvent } from '../../types/domain';
import {
  buildGregorianGrid,
  buildHebrewGrid,
  DAY_NAMES,
  EV_META,
  HOLIDAY_META,
  isoOf,
  SESSION_META,
  upcomingRows,
  type CalCell,
  type DayItem,
} from './calLib';
import { EventModal } from './EventModal';

const MAX_PILLS = 3;

const pillStyle = (bg: string, c: string, prC: string): CSSProperties => ({
  fontSize: 11,
  fontWeight: 600,
  padding: '2px 6px',
  borderRadius: 6,
  background: bg,
  color: c,
  borderRight: '3px solid ' + prC,
  whiteSpace: 'nowrap',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  textAlign: 'right',
  width: '100%',
  cursor: 'pointer',
  display: 'block',
});

interface ModalState {
  ev: OrgEvent | null;
  date: string;
}

function DayCell(props: { cell: CalCell; onAdd: () => void; onItem: (it: DayItem) => void }) {
  const { cell, onAdd, onItem } = props;
  const pills = cell.items.slice(0, MAX_PILLS);
  const more = cell.items.length - MAX_PILLS;
  return (
    <div
      role="button"
      tabIndex={0}
      title={'הוספת אירוע — ' + cell.iso.split('-').reverse().join('/')}
      onClick={onAdd}
      onKeyDown={(e) => e.key === 'Enter' && e.target === e.currentTarget && onAdd()}
      style={{
        minHeight: 96,
        padding: '6px 7px',
        borderTop: '1px solid var(--line)',
        borderLeft: '1px solid var(--line)',
        background: cell.isToday ? 'rgba(243, 199, 107, 0.28)' : cell.inMonth ? 'var(--panel)' : '#f7f4ec',
        cursor: 'pointer',
        minWidth: 0,
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 4 }}>
        <span
          style={{
            fontSize: 12,
            fontWeight: 700,
            minWidth: 21,
            height: 21,
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            borderRadius: 999,
            padding: '0 5px',
            background: cell.isToday ? 'var(--amber-deep)' : 'transparent',
            color: cell.isToday ? '#fff' : cell.inMonth ? 'var(--ink-soft)' : 'var(--ink-faint)',
            whiteSpace: 'nowrap',
          }}
        >
          {cell.hebDay}
        </span>
        <span style={{ fontSize: 11, color: 'var(--ink-faint)', fontWeight: 600, whiteSpace: 'nowrap' }}>
          {cell.dayNum}
        </span>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 3, marginTop: 5 }}>
        {cell.holiday && (
          <span style={{ ...pillStyle(HOLIDAY_META.bg, HOLIDAY_META.c, 'transparent'), cursor: 'default' }} title={cell.holiday}>
            {cell.holiday}
          </span>
        )}
        {pills.map((it) => (
          <button
            key={it.key}
            type="button"
            title={it.title}
            onClick={(e) => {
              e.stopPropagation();
              onItem(it);
            }}
            style={{
              ...pillStyle(it.bg, it.c, it.prC),
              ...(it.skipped || it.ev?.done ? { textDecoration: 'line-through', opacity: 0.55 } : null),
            }}
          >
            {it.label}
          </button>
        ))}
        {more > 0 && (
          <span style={{ fontSize: 10, color: 'var(--ink-faint)', fontWeight: 600 }}>+{more} נוספים</span>
        )}
      </div>
    </div>
  );
}

export function CalendarView() {
  const db = useApp((s) => s.db);
  const selectCourse = useApp((s) => s.selectCourse);
  const upsertEvent = useApp((s) => s.upsertEvent);
  const toast = useApp((s) => s.toast);

  const now = new Date();
  const [ym, setYm] = useState({ y: now.getFullYear(), m: now.getMonth() });
  const [hebMode, setHebMode] = useState(false);
  const [hebAnchor, setHebAnchor] = useState(isoOf(now));
  const [modal, setModal] = useState<ModalState | null>(null);

  const grid = useMemo(
    () => (hebMode ? buildHebrewGrid(db, hebAnchor) : buildGregorianGrid(db, ym.y, ym.m)),
    [db, hebMode, hebAnchor, ym],
  );
  const upcoming = useMemo(() => upcomingRows(db, 14), [db]);

  function prevMonth() {
    if (hebMode) {
      if (grid.prevIso) setHebAnchor(grid.prevIso);
      return;
    }
    setYm((p) => (p.m === 0 ? { y: p.y - 1, m: 11 } : { y: p.y, m: p.m - 1 }));
  }
  function nextMonth() {
    if (hebMode) {
      if (grid.nextIso) setHebAnchor(grid.nextIso);
      return;
    }
    setYm((p) => (p.m === 11 ? { y: p.y + 1, m: 0 } : { y: p.y, m: p.m + 1 }));
  }
  function goToday() {
    const t = new Date();
    setYm({ y: t.getFullYear(), m: t.getMonth() });
    setHebAnchor(isoOf(t));
  }
  function toggleHeb() {
    if (!hebMode) {
      // מעבר לגריד עברי — עוגן באמצע החודש המוצג כדי לשמור על ההקשר.
      setHebAnchor(isoOf(new Date(ym.y, ym.m, 15)));
    } else {
      // חזרה לגריד לועזי — לחודש שבו נמצא א׳ בחודש העברי המוצג.
      const first = grid.cells.find((c) => c.inMonth);
      if (first) setYm({ y: first.date.getFullYear(), m: first.date.getMonth() });
    }
    setHebMode((v) => !v);
  }

  function onItem(it: DayItem) {
    if (it.ev) setModal({ ev: it.ev, date: it.ev.date });
    else if (it.courseId) selectCourse(it.courseId);
  }

  function markCallDone(ev: OrgEvent) {
    upsertEvent({ ...ev, done: true });
    toast('השיחה סומנה כבוצעה');
  }

  return (
    <div>
      <PageHead
        title={hebMode ? grid.hebLabel : grid.monthLabel}
        sub={hebMode ? 'לוח שנה · חודש עברי · ' + grid.monthLabel : 'לוח שנה · ' + grid.hebLabel}
        actions={
          <>
            <Btn onClick={prevMonth} title="חודש קודם">
              ›
            </Btn>
            <Btn onClick={nextMonth} title="חודש הבא">
              ‹
            </Btn>
            <Btn onClick={toggleHeb} title="החלפת הגריד: חודש עברי מלא (א׳–ל׳) או חודש לועזי">
              {hebMode ? 'גריד עברי ✓' : 'גריד לועזי'}
            </Btn>
            <Btn onClick={goToday}>היום</Btn>
            <Btn kind="primary" onClick={() => setModal({ ev: null, date: isoOf(new Date()) })}>
              + אירוע חדש
            </Btn>
          </>
        }
      />

      <div className="card" style={{ padding: 0, overflow: 'hidden', marginTop: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)' }}>
          {DAY_NAMES.map((n) => (
            <div
              key={n}
              style={{
                padding: 8,
                textAlign: 'center',
                fontSize: 12,
                fontWeight: 600,
                color: 'var(--ink-faint)',
                background: '#faf8f2',
              }}
            >
              {n}
            </div>
          ))}
          {grid.cells.map((cell) => (
            <DayCell
              key={cell.iso}
              cell={cell}
              onAdd={() => setModal({ ev: null, date: cell.iso })}
              onItem={onItem}
            />
          ))}
        </div>
      </div>

      <div
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          gap: 12,
          alignItems: 'center',
          marginTop: 10,
          fontSize: 12,
          color: 'var(--ink-soft)',
        }}
      >
        <span style={{ fontWeight: 600, color: 'var(--ink-faint)' }}>מקרא:</span>
        {[
          SESSION_META,
          EV_META.org,
          EV_META.reminder,
          EV_META.call,
          { ...HOLIDAY_META },
          EV_META.memorial,
        ].map((m) => (
          <span key={m.label} style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 10, height: 10, borderRadius: 3, background: m.bg, border: '1px solid ' + m.c }} />
            {m.label}
          </span>
        ))}
      </div>

      <section className="card" style={{ marginTop: 16 }}>
        <h2 style={{ fontSize: 16.5, marginBottom: 8 }}>אירועים ותזכורות קרובים</h2>
        {upcoming.length === 0 && <Empty>אין אירועים קרובים</Empty>}
        {upcoming.map((u) => (
          <div
            key={u.key}
            style={{
              display: 'flex',
              gap: 10,
              padding: '9px 0',
              borderBottom: '1px solid #ece7db',
              alignItems: 'flex-start',
            }}
          >
            <div
              style={{
                width: 46,
                flex: 'none',
                textAlign: 'center',
                border: '1px solid var(--line)',
                borderRadius: 10,
                padding: '4px 2px',
                background: 'var(--panel)',
              }}
            >
              <div style={{ fontSize: 15, fontWeight: 700, lineHeight: 1.1 }}>{u.dayGem}</div>
              <div style={{ fontSize: 10, color: 'var(--ink-faint)', fontWeight: 600 }}>{u.monHeb}</div>
            </div>
            <div style={{ minWidth: 0, flex: 1 }}>
              <div style={{ fontSize: 13.5, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 6 }}>
                <span
                  aria-hidden
                  style={{ width: 8, height: 8, borderRadius: 999, background: u.prC, flex: 'none' }}
                />
                <span style={{ minWidth: 0 }}>{u.title}</span>
              </div>
              <div style={{ fontSize: 12, color: 'var(--ink-faint)', marginTop: 1 }}>{u.sub}</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4, flex: 'none' }}>
              <span
                style={{
                  fontSize: 10.5,
                  fontWeight: 600,
                  padding: '2px 8px',
                  borderRadius: 999,
                  background: u.bg,
                  color: u.c,
                  whiteSpace: 'nowrap',
                }}
              >
                {u.typeLabel}
              </span>
              <div style={{ display: 'flex', gap: 4 }}>
                <Btn sm onClick={() => setModal({ ev: u.ev, date: u.ev.date })} title="עריכת האירוע">
                  ✎
                </Btn>
                {u.ev.type === 'call' && (
                  <Btn sm onClick={() => markCallDone(u.ev)} title="סמן שיחה כבוצעה">
                    ✓ בוצע
                  </Btn>
                )}
              </div>
            </div>
          </div>
        ))}
      </section>

      {modal && <EventModal ev={modal.ev} date={modal.date} onClose={() => setModal(null)} />}
    </div>
  );
}
