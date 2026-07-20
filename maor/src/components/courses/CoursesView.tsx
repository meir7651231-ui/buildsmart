/**
 * מסך ניהול הקורסים — גריד/רשימה (db.ui.crsView), חיפוש וסינון לפי קטגוריה
 * וסמסטר, קורס חדש, וכרטיס קורס מלא בבחירה.
 */
import { useEffect, useMemo, useState } from 'react';
import type { Course } from '../../types/domain';
import { useApp, useCourse } from '../../store/useApp';
import { normSearch } from '../../lib/validate';
import { Btn, Empty, PageHead, Select, TextInput } from '../ui';
import { CourseForm } from './CourseForm';
import { CourseDetail } from './CourseDetail';
import { CourseWheel } from '../wheel/CourseWheel';
import { DAY_LETTERS, TINTS, chipStyle, enrollCount, modelMeta } from './lib';

export function CoursesView() {
  const selCourseId = useApp((s) => s.selCourseId);
  const selected = useCourse(selCourseId);
  const [wheelOpen, setWheelOpen] = useState(false);

  // פלטת הפקודות מסמנת דגל ב-sessionStorage (וגם משדרת אירוע, למקרה
  // שהמסך כבר פתוח) — הגלגל נפתח מיד עם הכניסה לחוגים.
  useEffect(() => {
    const check = () => {
      try {
        if (sessionStorage.getItem('maor_open_wheel') === '1') {
          sessionStorage.removeItem('maor_open_wheel');
          setWheelOpen(true);
        }
      } catch {
        /* sessionStorage חסום */
      }
    };
    check();
    window.addEventListener('maor:open-wheel', check);
    return () => window.removeEventListener('maor:open-wheel', check);
  }, []);

  return (
    <>
      {selected ? <CourseDetail course={selected} /> : <CoursesList onOpenWheel={() => setWheelOpen(true)} />}
      {wheelOpen && <CourseWheel onClose={() => setWheelOpen(false)} />}
    </>
  );
}

function CoursesList(props: { onOpenWheel: () => void }) {
  const db = useApp((s) => s.db);
  const setDb = useApp((s) => s.setDb);
  const selectCourse = useApp((s) => s.selectCourse);

  const [q, setQ] = useState('');
  const [cat, setCat] = useState('all');
  const [sem, setSem] = useState('all');
  const [formOpen, setFormOpen] = useState(false);

  const view = db.ui.crsView;
  const teacherName = (id: string) => db.teachers.find((t) => t.id === id)?.name ?? '—';

  const cats = useMemo(() => [...new Set(db.courses.map((c) => c.cat).filter(Boolean))], [db.courses]);
  const sems = useMemo(() => [...new Set(db.courses.map((c) => c.semester).filter(Boolean))], [db.courses]);

  const shown = useMemo(() => {
    const nq = normSearch(q);
    return db.courses.filter((c) => {
      if (cat !== 'all' && c.cat !== cat) return false;
      if (sem !== 'all' && c.semester !== sem) return false;
      if (nq) {
        const hay = normSearch([c.name, teacherName(c.teacherId), c.cat, c.audience ?? ''].join(' '));
        if (!hay.includes(nq)) return false;
      }
      return true;
    });
  }, [db.courses, db.teachers, q, cat, sem]);

  function toggleView() {
    setDb((d) => ({ ui: { ...d.ui, crsView: d.ui.crsView === 'grid' ? 'list' : 'grid' } }));
  }

  const countColor = (c: Course, n: number) =>
    n >= (c.maxStudents || 999) ? '#dc2626' : n >= (c.maxStudents || 999) * 0.8 ? '#9a6414' : '#8b8474';

  return (
    <div>
      <PageHead
        title="ניהול קורסים"
        sub={
          shown.length === db.courses.length
            ? db.courses.length + ' קורסים פעילים'
            : shown.length + ' מתוך ' + db.courses.length + ' קורסים — מסונן'
        }
        actions={
          <>
            <Btn onClick={props.onOpenWheel} title="גלגל מזל שבוחר חוג לפי הסינון שלכם">
              🎡 מצא חוג
            </Btn>
            <Btn onClick={toggleView} title="החלפת תצוגה: גריד / רשימה">
              {view === 'list' ? '▦ גריד' : '☰ רשימה'}
            </Btn>
            <Btn kind="primary" onClick={() => setFormOpen(true)}>
              + קורס חדש
            </Btn>
          </>
        }
      />

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', margin: '14px 0' }}>
        <div style={{ flex: 1, minWidth: 200 }}>
          <TextInput value={q} onChange={setQ} placeholder="חיפוש לפי שם, מורה, קהל או קטגוריה…" />
        </div>
        <div style={{ width: 170 }}>
          <Select
            value={cat}
            onChange={setCat}
            options={[{ value: 'all', label: 'כל הקטגוריות' }, ...cats.map((x) => ({ value: x, label: x }))]}
          />
        </div>
        <div style={{ width: 150 }}>
          <Select
            value={sem}
            onChange={setSem}
            options={[{ value: 'all', label: 'כל הסמסטרים' }, ...sems.map((x) => ({ value: x, label: x }))]}
          />
        </div>
      </div>

      {shown.length === 0 ? (
        <Empty>
          {db.courses.length === 0 ? 'עדיין אין קורסים — לחצו על "+ קורס חדש"' : 'אין קורסים תואמים לסינון'}
        </Empty>
      ) : view === 'grid' ? (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill,minmax(280px,1fr))', gap: 14 }}>
          {shown.map((c, i) => {
            const mm = modelMeta(c);
            const n = enrollCount(db, c.id);
            return (
              <div
                key={c.id}
                className="card"
                role="button"
                tabIndex={0}
                style={{ padding: 0, overflow: 'hidden', cursor: 'pointer' }}
                onClick={() => selectCourse(c.id)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    selectCourse(c.id);
                  }
                }}
              >
                <div
                  style={{
                    height: 90,
                    background: TINTS[i % TINTS.length],
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 30,
                    fontWeight: 800,
                    color: 'rgba(33,29,23,.38)',
                  }}
                >
                  {c.name[0]}
                </div>
                <div style={{ padding: '13px 15px 14px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
                    <div style={{ fontWeight: 800, fontSize: 14.5 }}>{c.name}</div>
                    <span style={chipStyle(mm.bg, mm.c)}>{mm.label}</span>
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--ink-faint)', marginTop: 2 }}>
                    {(c.audience || 'כללי') + ' · מורה: ' + teacherName(c.teacherId)}
                  </div>
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      marginTop: 11,
                      paddingTop: 10,
                      borderTop: '1px solid var(--line)',
                      fontSize: 12,
                    }}
                  >
                    <span style={{ fontWeight: 700 }}>{c.price ? '₪' + c.price + ' לחודש' : '—'}</span>
                    <span style={{ fontWeight: 700, color: countColor(c, n) }}>
                      {n + '/' + (c.maxStudents || '∞') + ' תלמידים'}
                    </span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="card" style={{ padding: 0, overflowX: 'auto' }}>
          <table className="table">
            <thead>
              <tr>
                <th>שם חוג</th>
                <th>קהל</th>
                <th>מורה</th>
                <th>מסלול</th>
                <th>יום</th>
                <th>תלמידים</th>
                <th>מחיר</th>
                <th>הנחה 1</th>
                <th>הנחה 2</th>
              </tr>
            </thead>
            <tbody>
              {shown.map((c) => {
                const mm = modelMeta(c);
                const n = enrollCount(db, c.id);
                return (
                  <tr key={c.id} style={{ cursor: 'pointer' }} onClick={() => selectCourse(c.id)}>
                    <td style={{ fontWeight: 700 }}>{c.name}</td>
                    <td style={{ fontSize: 12, color: 'var(--ink-faint)' }}>{c.audience || 'כללי'}</td>
                    <td>{teacherName(c.teacherId)}</td>
                    <td style={{ fontSize: 12 }}>{mm.label}</td>
                    <td style={{ fontSize: 12 }}>{DAY_LETTERS[c.weekday] + ' ' + (c.time || '')}</td>
                    <td style={{ fontWeight: 700, color: countColor(c, n) }}>{n + '/' + (c.maxStudents || '∞')}</td>
                    <td style={{ fontWeight: 800 }}>{c.price ? '₪' + c.price : '—'}</td>
                    <td style={{ color: '#12803c', fontWeight: 700 }}>
                      {c.price1 ? '₪' + c.price1 + (c.price1Name ? ' · ' + c.price1Name : '') : '—'}
                    </td>
                    <td style={{ color: '#7c3aed', fontWeight: 700 }}>
                      {c.price2 ? '₪' + c.price2 + (c.price2Name ? ' · ' + c.price2Name : '') : '—'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {formOpen && <CourseForm course={null} onClose={() => setFormOpen(false)} />}
    </div>
  );
}
