/**
 * פאנלים של כרטיס המשפחה: מסמכים (רשומות שם בלבד), מדד אמינות (+/- ולוג),
 * שיבוצים לחוגים (כולל ＋ שיבוץ לחוג) ואירועים מקושרים.
 */
import { useState, type ReactNode } from 'react';
import type { Family, FamilyDoc } from '../../types/domain';
import { useApp } from '../../store/useApp';
import { hebDateFull } from '../../lib/hebrew';
import { Btn, Empty, TextInput } from '../ui';
import { chipStyle, EVENT_META, fmtDate, isoToday, tierOf } from './lib';
import { JoinModal } from './JoinModal';

function SectionCard(props: { title: string; actions?: ReactNode; children: ReactNode }) {
  return (
    <section className="card" style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
        <h2 style={{ fontSize: 16, fontWeight: 700 }}>{props.title}</h2>
        {props.actions}
      </div>
      {props.children}
    </section>
  );
}

/** מסמכים — רשומות שם בלבד (ללא קבצים, כמו במקור). הסרה בדפוס לחיצה-כפולה. */
export function DocsPanel(props: { fam: Family }) {
  const upsertFamily = useApp((s) => s.upsertFamily);
  const nextId = useApp((s) => s.nextId);
  const toast = useApp((s) => s.toast);
  const [name, setName] = useState('');
  const [armedId, setArmedId] = useState<string | null>(null);

  function addDoc() {
    const n = name.trim();
    if (!n) return;
    const doc: FamilyDoc = { id: nextId('d'), name: n, addedAt: isoToday() };
    upsertFamily({ ...props.fam, docs: [...props.fam.docs, doc] });
    setName('');
    toast('המסמך "' + n + '" נרשם בתיק');
  }

  function removeDoc(id: string) {
    if (armedId !== id) {
      setArmedId(id);
      return;
    }
    upsertFamily({ ...props.fam, docs: props.fam.docs.filter((d) => d.id !== id) });
    setArmedId(null);
    toast('המסמך הוסר מהתיק');
  }

  return (
    <SectionCard title="מסמכים בתיק">
      {props.fam.docs.length === 0 && <Empty>אין מסמכים בתיק — הוסיפו ספח, הזמנה או המלצה</Empty>}
      {props.fam.docs.map((d) => (
        <div
          key={d.id}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '8px 11px',
            border: '1px solid var(--line)',
            borderRadius: 10,
            fontSize: 13,
          }}
        >
          <span aria-hidden>🖇</span>
          <span style={{ flex: 1, fontWeight: 600 }}>{d.name}</span>
          <span style={{ color: 'var(--ink-faint)', fontSize: 12 }}>נוסף {fmtDate(d.addedAt)}</span>
          <Btn sm kind={armedId === d.id ? 'danger' : 'plain'} onClick={() => removeDoc(d.id)}>
            {armedId === d.id ? 'לאשר הסרה?' : '✕'}
          </Btn>
        </div>
      ))}
      <div style={{ display: 'flex', gap: 8 }}>
        <div style={{ flex: 1 }}>
          <TextInput value={name} onChange={setName} placeholder={'שם המסמך — למשל: ספח ת"ז — אב.pdf'} />
        </div>
        <Btn onClick={addDoc} disabled={!name.trim()}>
          + הוספה
        </Btn>
      </div>
      <div style={{ fontSize: 12, color: 'var(--ink-faint)' }}>
        רישום שמות מסמכים בלבד — העלאת קבצים תחובר בגרסה המחוברת
      </div>
    </SectionCard>
  );
}

/** מדד אמינות — ציון 0–1000, דרגה, לוג שינויים והתאמות ידניות. */
export function CredPanel(props: { fam: Family }) {
  const addCred = useApp((s) => s.addCred);
  const toast = useApp((s) => s.toast);
  const [overrideVal, setOverrideVal] = useState('');

  const cred = props.fam.cred;
  const tier = tierOf(cred.score);

  function applyOverride() {
    const raw = overrideVal.trim();
    const v = /^\d+$/.test(raw) ? Number(raw) : NaN;
    if (!Number.isInteger(v) || v < 0 || v > 1000) {
      toast('ציון Override חייב להיות 0–1000');
      return;
    }
    addCred(props.fam.id, v - cred.score, 'Override ידני של מנהל → ' + v);
    setOverrideVal('');
    toast('הציון עודכן ידנית');
  }

  return (
    <SectionCard title="מדד אמינות" actions={<span style={chipStyle(tier.bg, tier.c)}>{tier.label}</span>}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
        <span style={{ fontSize: 30, fontWeight: 800, lineHeight: 1 }}>{cred.score}</span>
        <span style={{ fontSize: 12, color: 'var(--ink-faint)', fontWeight: 600 }}>/ 1000</span>
      </div>
      <div style={{ height: 8, borderRadius: 99, background: 'rgba(33,29,23,.08)', overflow: 'hidden' }}>
        <div
          style={{
            height: '100%',
            borderRadius: 99,
            background: tier.dot,
            width: Math.min(100, Math.round(cred.score / 10)) + '%',
          }}
        />
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
        <Btn sm onClick={() => addCred(props.fam.id, 15, 'פעולה קהילתית (תרומה/עזרה)')}>
          + פעולה קהילתית (15)
        </Btn>
        <Btn sm onClick={() => addCred(props.fam.id, 5, 'התאמה ידנית של מנהל')}>
          +5
        </Btn>
        <Btn sm onClick={() => addCred(props.fam.id, -5, 'התאמה ידנית של מנהל')}>
          −5
        </Btn>
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <div style={{ flex: 1 }}>
          <TextInput value={overrideVal} onChange={setOverrideVal} placeholder="Override 0–1000" dir="ltr" />
        </div>
        <Btn sm onClick={applyOverride}>
          עדכון ידני
        </Btn>
      </div>
      {cred.log.length === 0 ? (
        <div style={{ fontSize: 12.5, color: 'var(--ink-faint)' }}>אין עדיין רישומי ניקוד למשפחה זו</div>
      ) : (
        <div style={{ maxHeight: 180, overflowY: 'auto' }}>
          {cred.log.slice(0, 8).map((l, i) => (
            <div
              key={i}
              style={{
                display: 'flex',
                gap: 8,
                alignItems: 'baseline',
                padding: '5px 0',
                borderBottom: '1px solid var(--line)',
                fontSize: 12.5,
              }}
            >
              <span style={{ color: 'var(--ink-faint)', whiteSpace: 'nowrap' }}>{fmtDate(l.date)}</span>
              <span
                style={{
                  fontWeight: 800,
                  color: l.delta > 0 ? '#12803c' : l.delta < 0 ? '#b91c1c' : '#8b8474',
                  direction: 'ltr',
                }}
              >
                {(l.delta > 0 ? '+' : '') + l.delta}
              </span>
              <span style={{ flex: 1 }}>{l.reason}</span>
            </div>
          ))}
        </div>
      )}
    </SectionCard>
  );
}

/** שיבוצים לחוגים של בני המשפחה — כולל ＋ שיבוץ לחוג ישירות מהכרטיס. */
export function EnrollPanel(props: { fam: Family }) {
  const courses = useApp((s) => s.db.courses);
  const enrollments = useApp((s) => s.db.enrollments);
  const [joinOpen, setJoinOpen] = useState(false);
  const memberIds = new Set(props.fam.members.map((m) => m.id));
  const list = enrollments.filter((e) => memberIds.has(e.memberId));

  const STATUS: Record<string, string> = { active: 'פעיל', paused: 'מוקפא ⏸', ended: 'הסתיים' };

  return (
    <SectionCard
      title="קורסים פעילים וניקובים"
      actions={<Btn onClick={() => setJoinOpen(true)}>+ שיבוץ לחוג</Btn>}
    >
      {list.length === 0 ? (
        <Empty>אין שיבוצים פעילים — לחצו על "+ שיבוץ לחוג"</Empty>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="table">
            <thead>
              <tr>
                <th>תלמיד/ה</th>
                <th>קורס</th>
                <th>מסלול</th>
                <th>יתרה</th>
                <th>סטטוס</th>
              </tr>
            </thead>
            <tbody>
              {list.map((e) => {
                const m = props.fam.members.find((x) => x.id === e.memberId);
                const c = courses.find((x) => x.id === e.courseId);
                const rem = e.purchased - e.used;
                const barColor = rem <= 0 ? '#dc2626' : rem <= 2 ? '#d97706' : '#16a34a';
                return (
                  <tr key={e.id}>
                    <td style={{ fontWeight: 600 }}>{m?.first ?? '—'}</td>
                    <td>{c?.name ?? '—'}</td>
                    <td>
                      {(e.plan === 'punch' ? 'כרטיסייה · ' + e.purchased + ' ניקובים' : 'מנוי חודשי') +
                        (e.group ? ' · ' + e.group : '')}
                    </td>
                    <td>
                      {e.plan === 'punch' ? (
                        <span style={{ fontWeight: 700, color: barColor }}>
                          {rem} מתוך {e.purchased}
                        </span>
                      ) : (
                        <span>{e.used} נוכחויות</span>
                      )}
                    </td>
                    <td>{STATUS[e.status] ?? e.status}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
      {joinOpen && <JoinModal family={props.fam} onClose={() => setJoinOpen(false)} />}
    </SectionCard>
  );
}

/** אירועים מיוחדים המקושרים למשפחה (אזכרה/שמחה/תזכורת) — תצוגה בלבד. */
export function EventsPanel(props: { fam: Family }) {
  const events = useApp((s) => s.db.events);
  const list = events.filter((e) => e.famId === props.fam.id && !e.done);

  return (
    <SectionCard title="אירועים מיוחדים">
      {list.length === 0 ? (
        <Empty>אין אירועים מקושרים למשפחה — ניתן להוסיף מתוך לוח השנה</Empty>
      ) : (
        list.map((ev) => {
          const meta = EVENT_META[ev.type] ?? EVENT_META.org;
          return (
            <div
              key={ev.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 9,
                border: '1px solid var(--line)',
                borderRadius: 11,
                padding: '9px 11px',
              }}
            >
              <span style={chipStyle(meta.bg, meta.c)}>{ev.type === 'custom' && ev.customType ? ev.customType : meta.label}</span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 700 }}>{ev.title}</div>
                <div style={{ fontSize: 11.5, color: '#9a6414', fontWeight: 600 }}>
                  {fmtDate(ev.date)}
                  {ev.time ? ' · ' + ev.time : ''}
                  {ev.date ? ' · ' + hebDateFull(ev.date) : ''}
                </div>
              </div>
            </div>
          );
        })
      )}
    </SectionCard>
  );
}
