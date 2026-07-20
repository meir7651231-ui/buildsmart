/**
 * הגדרות ← ייבוא נתונים — קליטת משפחות ובני משפחה מהמערכת הישנה:
 * 1. קובץ גיבוי JSON (אותו פורמט של הגיבוי המלא) — מיזוג משפחות חדשות בלבד.
 * 2. הדבקת CSV — שורה לכל משפחה: שם משפחה, שם האב, שם האם, טלפון, עיר.
 */
import { useState, type ChangeEvent } from 'react';
import { emptyFamily, type Family } from '../../types/domain';
import { useApp } from '../../store/useApp';
import { parseBackupFile } from '../../store/persist';
import { normalizePhone, normSearch } from '../../lib/validate';
import { Btn, Field, FormError } from '../ui';
import { isoToday, Section, SectionNote } from './lib';

/** מפתח זיהוי כפילויות: שם מנורמל + טלפון מנורמל. */
function famKey(name: string, phone: string): string {
  return normSearch(name) + '|' + normalizePhone(phone);
}

export function ImportSection() {
  const setDb = useApp((s) => s.setDb);
  const upsertFamily = useApp((s) => s.upsertFamily);
  const nextId = useApp((s) => s.nextId);
  const toast = useApp((s) => s.toast);

  const [error, setError] = useState('');
  const [summary, setSummary] = useState('');
  const [csv, setCsv] = useState('');

  /** ייבוא מקובץ גיבוי JSON — מוסיף רק משפחות שאינן קיימות (לפי שם+טלפון). */
  async function onJsonFile(e: ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    setError('');
    setSummary('');
    try {
      const parsed = parseBackupFile(await file.text());
      if (!parsed.families.length) {
        setError('בקובץ הגיבוי אין משפחות לייבוא');
        return;
      }
      const cur = useApp.getState().db;
      const existing = new Set(cur.families.map((f) => famKey(f.name, f.phone)));
      const toAdd = parsed.families.filter((f) => !existing.has(famKey(f.name, f.phone)));
      if (!toAdd.length) {
        setSummary(`בקובץ ${parsed.families.length} משפחות — כולן כבר קיימות במערכת, לא נוסף דבר.`);
        return;
      }
      // עדכון אטומי אחד: מזהים חדשים לכל משפחה ולכל בן משפחה (מונע התנגשות מזהים)
      let added = 0;
      let members = 0;
      setDb((db) => {
        let seq = db.seq;
        const fresh: Family[] = toAdd.map((f) => ({
          ...emptyFamily(),
          ...f,
          id: 'f' + seq++,
          createdAt: f.createdAt || isoToday(),
          members: (f.members ?? []).map((m) => ({ ...m, id: 'm' + seq++ })),
          docs: f.docs ?? [],
          cred: f.cred ?? { score: 500, log: [] },
        }));
        added = fresh.length;
        members = fresh.reduce((n, f) => n + f.members.length, 0);
        return { seq, families: [...db.families, ...fresh] };
      });
      const skipped = parsed.families.length - added;
      setSummary(
        `נוספו ${added} משפחות ו-${members} בני משפחה מהגיבוי` +
          (skipped ? ` · ${skipped} דולגו (כבר קיימות)` : ''),
      );
      toast('נוספו ' + added + ' משפחות');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאה בקריאת הקובץ');
    }
  }

  /** ייבוא מהדבקת CSV: שם משפחה, שם האב, שם האם, טלפון, עיר. */
  function importCsv() {
    setError('');
    setSummary('');
    const lines = csv.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
    let skippedNoName = 0;
    let skippedExisting = 0;
    const rows: { name: string; father: string; mother: string; phone: string; city: string }[] = [];
    lines.forEach((line, i) => {
      const cells = line.split(',').map((c) => c.trim().replace(/^"|"$/g, ''));
      const name = cells[0] ?? '';
      // דילוג על שורת כותרת אם קיימת
      if (i === 0 && ['name', 'שם', 'שם משפחה', 'משפחה'].includes(name.toLowerCase())) return;
      if (!name) {
        skippedNoName++;
        return;
      }
      rows.push({
        name,
        father: cells[1] ?? '',
        mother: cells[2] ?? '',
        phone: cells[3] ?? '',
        city: cells[4] ?? '',
      });
    });
    if (!rows.length) {
      setError('לא נמצאו שורות תקינות — הפורמט: שם משפחה, שם האב, שם האם, טלפון, עיר (שורה לכל משפחה)');
      return;
    }
    const existing = new Set(useApp.getState().db.families.map((f) => famKey(f.name, f.phone)));
    let added = 0;
    for (const r of rows) {
      const key = famKey(r.name, r.phone);
      if (existing.has(key)) {
        skippedExisting++;
        continue;
      }
      existing.add(key);
      upsertFamily({
        ...emptyFamily(),
        id: nextId('f'),
        createdAt: isoToday(),
        name: r.name,
        father: r.father,
        mother: r.mother,
        phone: normalizePhone(r.phone),
        city: r.city,
      });
      added++;
    }
    setSummary(
      `נוספו ${added} משפחות` +
        (skippedExisting ? ` · ${skippedExisting} דולגו (כבר קיימות)` : '') +
        (skippedNoName ? ` · ${skippedNoName} שורות ללא שם דולגו` : ''),
    );
    toast('נוספו ' + added + ' משפחות');
    if (added) setCsv('');
  }

  return (
    <Section
      id="sec-import"
      title="⬆ ייבוא נתונים"
      sub="קליטת משפחות ובני משפחה מהמערכת הישנה — קובץ גיבוי JSON או הדבקת CSV"
    >
      <FormError error={error} />
      {summary && (
        <div
          style={{
            background: '#e4f5ea',
            color: 'var(--green)',
            borderRadius: 8,
            padding: '8px 12px',
            fontSize: 14,
            marginBottom: 12,
          }}
        >
          {summary}
        </div>
      )}

      <h3 style={{ fontSize: 15, fontWeight: 700, marginBottom: 6 }}>מקובץ גיבוי (JSON)</h3>
      <p style={{ fontSize: 13.5, color: 'var(--ink-soft)', marginBottom: 8 }}>
        בחרו קובץ גיבוי של המערכת הישנה — משפחות ובני המשפחה שלהן יתווספו למערכת. משפחות שכבר
        קיימות (לפי שם וטלפון) לא ייובאו שוב. הנתונים הקיימים אינם נדרסים — לשחזור מלא השתמשו
        בסקשן "גיבוי ושחזור".
      </p>
      <label className="btn" style={{ cursor: 'pointer', marginBottom: 18, display: 'inline-flex' }}>
        בחירת קובץ JSON…
        <input
          type="file"
          accept=".json,application/json"
          style={{ display: 'none' }}
          onChange={(e) => void onJsonFile(e)}
        />
      </label>

      <h3 style={{ fontSize: 15, fontWeight: 700, margin: '10px 0 6px' }}>מהדבקת CSV</h3>
      <p style={{ fontSize: 13.5, color: 'var(--ink-soft)', marginBottom: 8 }}>
        קובץ אקסל? שמרו קודם בתור CSV (קובץ ← שמירה בשם ← CSV), פתחו בפנקס רשימות והדביקו כאן.
        שורה לכל משפחה, בסדר הזה: <b>שם משפחה, שם האב, שם האם, טלפון, עיר</b>.
      </p>
      <Field label="שורות CSV">
        <textarea
          rows={5}
          dir="rtl"
          value={csv}
          onChange={(e) => setCsv(e.target.value)}
          placeholder={'כהן, אברהם, שרה, 050-1234567, ירושלים\nלוי, יעקב, רבקה, 052-7654321, בני ברק'}
          style={{ fontFamily: 'monospace', fontSize: 13 }}
        />
      </Field>
      <Btn kind="primary" onClick={importCsv} disabled={!csv.trim()}>
        ייבוא המשפחות מהרשימה
      </Btn>
      <SectionNote>אחרי הייבוא אפשר להשלים לכל משפחה את שאר הפרטים ובני המשפחה במסך המשפחות.</SectionNote>
    </Section>
  );
}
