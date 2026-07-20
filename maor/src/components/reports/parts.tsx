/** רכיבי תצוגה משותפים לדוחות — עטיפת סעיף (הדפסה + CSV) וטבלת דוח גנרית. */

import type { ReactNode } from 'react';
import { Btn } from '../ui';
import { downloadCsv, type Cell } from './csv';

/** שורת דוח — תאים + דגל אזהרה (מודגש באדום, למשל יתרה נמוכה). */
export interface Row {
  cells: Cell[];
  warn?: boolean;
}

export function ReportTable(props: { head: string[]; rows: Row[]; foot?: Cell[] }) {
  if (!props.rows.length) return <div className="empty">אין נתונים להצגה</div>;
  return (
    <div style={{ overflowX: 'auto' }}>
      <table className="table">
        <thead>
          <tr>
            {props.head.map((h, i) => (
              <th key={i}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {props.rows.map((r, i) => (
            <tr key={i} style={r.warn ? { color: 'var(--red)', fontWeight: 600 } : undefined}>
              {r.cells.map((c, j) => (
                <td key={j}>{c}</td>
              ))}
            </tr>
          ))}
        </tbody>
        {props.foot && (
          <tfoot>
            <tr style={{ fontWeight: 700 }}>
              {props.foot.map((c, j) => (
                <td key={j} style={{ borderTop: '2px solid var(--line)' }}>
                  {c}
                </td>
              ))}
            </tr>
          </tfoot>
        )}
      </table>
    </div>
  );
}

/**
 * עטיפת סעיף דוח: כותרת, תת-כותרת, כפתורי הדפסה/CSV (מוסתרים בהדפסה),
 * ו-hidden — הסתרת הסעיף כשמדפיסים סעיף אחר (מקבל no-print).
 */
export function Section(props: {
  title: string;
  sub?: string;
  hidden?: boolean;
  onPrint: () => void;
  csvName: string;
  csvRows: () => Cell[][];
  extra?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className={'card' + (props.hidden ? ' no-print' : '')} style={{ marginTop: 16 }}>
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          justifyContent: 'space-between',
          gap: 8,
          flexWrap: 'wrap',
          marginBottom: 10,
        }}
      >
        <div>
          <h2 style={{ fontSize: 17, marginBottom: 2 }}>{props.title}</h2>
          {props.sub && <div style={{ color: 'var(--ink-faint)', fontSize: 13 }}>{props.sub}</div>}
        </div>
        <div className="no-print" style={{ display: 'flex', gap: 6, flexWrap: 'wrap', alignItems: 'center' }}>
          {props.extra}
          <Btn sm onClick={() => downloadCsv(props.csvName, props.csvRows())} title="ייצוא לאקסל — עברית תקינה">
            ⬇ CSV
          </Btn>
          <Btn sm onClick={props.onPrint} title="הדפסת הסעיף בלבד">
            🖨 הדפסה
          </Btn>
        </div>
      </div>
      {props.children}
    </section>
  );
}
