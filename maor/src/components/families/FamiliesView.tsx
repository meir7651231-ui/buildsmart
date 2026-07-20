/**
 * CRM המשפחות — רשימה/גריד (נשמר ב-db.ui.famView), חיפוש מנורמל,
 * סינון סטטוס/עיר/קהילה, טופס משפחה וכרטיס משפחה מפורט.
 */
import { useState, type KeyboardEvent } from 'react';
import type { Family } from '../../types/domain';
import { useApp } from '../../store/useApp';
import { normSearch } from '../../lib/validate';
import { hebDateFull } from '../../lib/hebrew';
import { Btn, Empty, PageHead, Select, TextInput } from '../ui';
import { chipStyle, famEnrollments, STATUS_META, tierOf } from './lib';
import { FamilyForm } from './FamilyForm';
import { FamilyDetail } from './FamilyDetail';

function kidsOf(f: Family) {
  return f.members.filter((m) => !m.isParent);
}

function TierDot(props: { f: Family }) {
  const tier = tierOf(props.f.cred.score);
  return (
    <span
      title={'מדד אמינות: ' + props.f.cred.score + ' — ' + tier.label}
      style={{
        display: 'inline-block',
        width: 9,
        height: 9,
        borderRadius: 99,
        background: tier.dot,
        flex: 'none',
      }}
    />
  );
}

export function FamiliesView() {
  const db = useApp((s) => s.db);
  const setDb = useApp((s) => s.setDb);
  const selFamilyId = useApp((s) => s.selFamilyId);
  const selectFamily = useApp((s) => s.selectFamily);

  const [q, setQ] = useState('');
  const [status, setStatus] = useState('all');
  const [city, setCity] = useState('all');
  const [comm, setComm] = useState('all');
  const [formOpen, setFormOpen] = useState(false);

  const selected = db.families.find((f) => f.id === selFamilyId);
  if (selected) return <FamilyDetail family={selected} />;

  const famView = db.ui.famView;
  const toggleView = () =>
    setDb((d) => ({ ui: { ...d.ui, famView: d.ui.famView === 'grid' ? 'list' : 'grid' } }));

  const nq = normSearch(q);
  const qd = q.replace(/\D/g, '');
  const filtered = db.families.filter((f) => {
    if (status !== 'all' && f.status !== status) return false;
    if (city !== 'all' && f.city !== city) return false;
    if (comm !== 'all' && f.community !== comm) return false;
    if (!q.trim()) return true;
    const hay = normSearch([f.name, f.father, f.mother, f.city, ...f.members.map((m) => m.first)].join(' '));
    if (nq && hay.includes(nq)) return true;
    return qd.length >= 2 && ((f.phone || '') + (f.phone2 || '')).replace(/\D/g, '').includes(qd);
  });

  const cityOptions = [...new Set(db.families.map((f) => f.city).filter(Boolean))];
  const commOptions = [...new Set(db.families.map((f) => f.community).filter(Boolean))];
  const totalKids = filtered.reduce((a, f) => a + kidsOf(f).length, 0);

  const openRowKey = (id: string) => (e: KeyboardEvent<HTMLElement>) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      selectFamily(id);
    }
  };

  return (
    <div>
      <PageHead
        title="משפחות"
        sub={filtered.length + ' משפחות · ' + totalKids + ' ילדים'}
        actions={
          <>
            <Btn onClick={toggleView} title="החלפת תצוגה: רשימה / גריד">
              {famView === 'grid' ? '☰ רשימה' : '▦ גריד'}
            </Btn>
            <Btn kind="primary" onClick={() => setFormOpen(true)}>
              + משפחה חדשה
            </Btn>
          </>
        }
      />

      <div style={{ display: 'flex', gap: 10, marginBottom: 14, flexWrap: 'wrap' }}>
        <div style={{ flex: '1 1 260px', minWidth: 220 }}>
          <TextInput value={q} onChange={setQ} placeholder="חיפוש לפי שם משפחה, הורה, ילד או טלפון…" />
        </div>
        <Select
          value={status}
          onChange={setStatus}
          options={[
            { value: 'all', label: 'כל הסטטוסים' },
            { value: 'active', label: 'פעילה' },
            { value: 'pending', label: 'ממתינה' },
            { value: 'inactive', label: 'לא פעילה' },
          ]}
        />
        <Select
          value={city}
          onChange={setCity}
          options={[{ value: 'all', label: 'כל הערים' }, ...cityOptions.map((c) => ({ value: c, label: c }))]}
        />
        <Select
          value={comm}
          onChange={setComm}
          options={[{ value: 'all', label: 'כל הקהילות' }, ...commOptions.map((c) => ({ value: c, label: c }))]}
        />
      </div>

      {db.families.length === 0 ? (
        <Empty>עדיין אין משפחות במערכת — הוסיפו משפחה ראשונה עם "+ משפחה חדשה"</Empty>
      ) : filtered.length === 0 ? (
        <Empty>לא נמצאו משפחות התואמות את החיפוש והסינון</Empty>
      ) : famView === 'grid' ? (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: 12 }}>
          {filtered.map((f) => {
            const st = STATUS_META[f.status];
            const kids = kidsOf(f);
            const parents = [f.father, f.mother].filter(Boolean).join(' ו');
            return (
              <div
                key={f.id}
                className="card"
                role="button"
                tabIndex={0}
                onClick={() => selectFamily(f.id)}
                onKeyDown={openRowKey(f.id)}
                style={{ cursor: 'pointer' }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
                  <TierDot f={f} />
                  <span style={{ fontWeight: 700, fontSize: 15, flex: 1 }}>משפחת {f.name}</span>
                  <span style={chipStyle(st.bg, st.c)}>{st.label}</span>
                </div>
                <div style={{ fontSize: 13, color: 'var(--ink-soft)' }}>
                  {[parents, f.city].filter(Boolean).join(' · ') || '—'}
                </div>
                <div style={{ fontSize: 12, color: 'var(--ink-faint)', marginTop: 4 }}>
                  {kids.length} ילדים · {famEnrollments(db, f).length} חוגים
                  {f.createdAt ? ' · נרשמה ' + hebDateFull(f.createdAt) : ''}
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
                <th>משפחה</th>
                <th>הורים</th>
                <th>טלפון</th>
                <th>ילדים</th>
                <th>חוגים</th>
                <th>סטטוס</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((f) => {
                const st = STATUS_META[f.status];
                const kids = kidsOf(f);
                const kidsLine = kids.length
                  ? kids
                      .slice(0, 3)
                      .map((m) => m.first)
                      .join(', ') + (kids.length > 3 ? ' +' + (kids.length - 3) : '')
                  : '—';
                const enrolls = famEnrollments(db, f).length;
                return (
                  <tr
                    key={f.id}
                    onClick={() => selectFamily(f.id)}
                    onKeyDown={openRowKey(f.id)}
                    tabIndex={0}
                    style={{ cursor: 'pointer' }}
                  >
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                        <TierDot f={f} />
                        <span style={{ fontWeight: 700 }}>משפחת {f.name}</span>
                      </div>
                      <div style={{ fontSize: 12, color: 'var(--ink-faint)' }}>{kidsLine}</div>
                    </td>
                    <td>{[f.father, f.mother].filter(Boolean).join(' ו') || '—'}</td>
                    <td style={{ direction: 'ltr', textAlign: 'right' }}>{f.phone || '—'}</td>
                    <td>{kids.length}</td>
                    <td>{enrolls || '—'}</td>
                    <td>
                      <span style={chipStyle(st.bg, st.c)}>{st.label}</span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {formOpen && <FamilyForm family={null} onClose={() => setFormOpen(false)} />}
    </div>
  );
}
