/**
 * מודאל רישום תרומה — תאריך, סכום, מטבע (₪/$) וקטגוריה.
 * הצבירה (count/ils/usd/first/last) מתעדכנת אוטומטית ב-addDonation שב-store;
 * מספר האסמכתה D-{seq} מוצג בטוסט.
 */
import { useState } from 'react';
import type { Supporter } from '../../types/domain';
import { useApp } from '../../store/useApp';
import { hebDateFull } from '../../lib/hebrew';
import { Btn, Field, FormError, Modal, Select, TextInput } from '../ui';
import { isoToday } from './lib';

export function DonationModal(props: { supporter: Supporter; onClose: () => void }) {
  const addDonation = useApp((s) => s.addDonation);
  const toast = useApp((s) => s.toast);

  const [date, setDate] = useState(isoToday());
  const [amount, setAmount] = useState('');
  const [cur, setCur] = useState<'₪' | '$'>('₪');
  const [cat, setCat] = useState(props.supporter.cat || '');
  const [error, setError] = useState('');

  function save() {
    const amt = Math.round(Number(amount) * 100) / 100;
    if (!amount.trim() || !isFinite(amt) || amt <= 0) {
      setError('הקלידו סכום תרומה תקין');
      return;
    }
    if (!date) {
      setError('בחרו תאריך תרומה');
      return;
    }
    // מספר האסמכתה נגזר מה-seq הנוכחי — בדיוק כפי ש-addDonation שב-store מחשב אותו
    const rid = 'D-' + useApp.getState().db.seq;
    addDonation(props.supporter.id, { date, amount: amt, cur, cat: cat.trim() });
    toast(
      'נרשמה תרומה ' +
        (cur === '$' ? '$' : '₪') +
        amt.toLocaleString('he-IL') +
        ' — קבלה ' +
        rid +
        ' · הציון עודכן',
    );
    props.onClose();
  }

  return (
    <Modal title={'רישום תרומה — ' + props.supporter.name} onClose={props.onClose}>
      <FormError error={error} />
      <div className="form-grid">
        <Field label="תאריך">
          <TextInput value={date} onChange={setDate} type="date" dir="ltr" />
        </Field>
        <Field label="סכום">
          <TextInput value={amount} onChange={setAmount} type="number" dir="ltr" placeholder="0" />
        </Field>
        <Field label="מטבע">
          <Select
            value={cur}
            onChange={(v) => setCur(v === '$' ? '$' : '₪')}
            options={[
              { value: '₪', label: '₪ שקל' },
              { value: '$', label: '$ דולר' },
            ]}
          />
        </Field>
        <Field label="קטגוריה">
          <TextInput value={cat} onChange={setCat} placeholder="מלגות, פעילות, כללי…" />
        </Field>
      </div>
      {date && (
        <div style={{ fontSize: 12.5, color: 'var(--ink-faint)', marginBottom: 4 }}>
          {hebDateFull(date)}
        </div>
      )}
      <div className="modal-actions">
        <Btn kind="primary" onClick={save}>
          רישום התרומה
        </Btn>
        <Btn onClick={props.onClose}>ביטול</Btn>
      </div>
    </Modal>
  );
}
