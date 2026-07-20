/**
 * אשף ההרכבה — המסך של המטמיע בלבד (נפתח עם #builder בכתובת).
 *
 * פאנל צף מעל האפליקציה החיה: כל שינוי (שם, ערכה, צבע, מודולים) מוחל
 * מיידית דרך setConfig — הלקוח רואה את המערכת שלו נולדת מולו.
 * בסיום: "📦 צור חבילה" מוריד config.json + דף מסירה בעברית.
 */
import { useMemo, useState } from 'react';
import { useApp } from '../../store/useApp';
import { clearConfigOverride } from '../../lib/config';
import { DEFAULT_CONFIG, type ModuleKey, type OrgConfig } from '../../types/config';
import { Btn, Chip, Field, TextInput } from '../ui';
import {
  buildHandoffHtml,
  downloadTextFile,
  INTEGRATION_LABELS,
  MODULE_LABELS,
  THEME_LABELS,
} from './handoff';

const DEFAULT_APP_URL = 'https://meir7651231-ui.github.io/buildsmart/maor/';

/** slug לטיני מהשם — מספיק טוב כברירת מחדל, ניתן לעריכה ידנית. */
function suggestSlug(name: string): string {
  const map: Record<string, string> = {
    א: 'a', ב: 'b', ג: 'g', ד: 'd', ה: 'h', ו: 'v', ז: 'z', ח: 'ch', ט: 't',
    י: 'y', כ: 'k', ך: 'k', ל: 'l', מ: 'm', ם: 'm', נ: 'n', ן: 'n', ס: 's',
    ע: 'a', פ: 'p', ף: 'p', צ: 'tz', ץ: 'tz', ק: 'k', ר: 'r', ש: 'sh', ת: 't',
  };
  return name
    .split('')
    .map((ch) => map[ch] ?? (/[a-z0-9]/i.test(ch) ? ch.toLowerCase() : ' '))
    .join('')
    .trim()
    .replace(/\s+/g, '-')
    .slice(0, 30);
}

export function BuilderWizard({ onClose }: { onClose: () => void }) {
  const config = useApp((s) => s.config);
  const setConfig = useApp((s) => s.setConfig);
  const setTheme = useApp((s) => s.setTheme);
  const setAccent = useApp((s) => s.setAccent);
  const toast = useApp((s) => s.toast);
  const [appUrl, setAppUrl] = useState(DEFAULT_APP_URL);
  const [installer, setInstaller] = useState('מאיר — הקמת מערכות לעמותות');
  const [slugTouched, setSlugTouched] = useState(config.slug !== 'default');

  /** עדכון קונפיגורציה חלקי — מוחל חי + נשמר כדריסת ריצה. */
  const patch = (p: Partial<OrgConfig>) => setConfig({ ...config, ...p });

  const setName = (orgName: string) =>
    patch({ orgName, ...(slugTouched ? {} : { slug: suggestSlug(orgName) || 'default' }) });

  const toggleModule = (k: ModuleKey) =>
    patch({ modules: { ...config.modules, [k]: config.modules[k] === false } });

  const toggleIntegration = (k: string) => {
    const cur = config.integrations?.[k]?.enabled ?? false;
    patch({ integrations: { ...(config.integrations ?? {}), [k]: { enabled: !cur } } });
  };

  const pickTheme = (theme: string) => {
    patch({ theme });
    setTheme(theme); // גם העדפת המשתמש — כדי שהתצוגה תתעדכן מיד בכל מקרה
  };

  const onLogo = (file: File | undefined) => {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => patch({ logoDataUri: String(reader.result) });
    reader.readAsDataURL(file);
  };

  const configJson = useMemo(
    () => JSON.stringify({ ...config, slug: config.slug || 'default' }, null, 2),
    [config],
  );

  const createPackage = () => {
    if (!config.orgName.trim()) {
      toast('חסר שם ארגון — זה הדבר היחיד שחובה');
      return;
    }
    downloadTextFile(`config-${config.slug}.json`, configJson, 'application/json');
    downloadTextFile(`handoff-${config.slug}.html`, buildHandoffHtml(config, appUrl, installer));
    toast('📦 החבילה ירדה: config + דף מסירה. את ה-config מעלים ל-public/c/' + config.slug + '/');
  };

  const resetToDefault = () => {
    clearConfigOverride();
    setConfig(DEFAULT_CONFIG);
    setTheme(DEFAULT_CONFIG.theme);
    setAccent(undefined);
    toast('האשף אופס — חזרה לברירת המחדל');
  };

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        bottom: 0,
        insetInlineEnd: 0,
        width: 'min(420px, 92vw)',
        background: 'var(--panel)',
        borderInlineStart: '3px solid var(--accent)',
        boxShadow: 'var(--shadow-lift)',
        zIndex: 300,
        overflowY: 'auto',
        padding: '18px 20px 40px',
      }}
      aria-label="אשף ההרכבה"
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
        <h2 style={{ fontSize: 18, flex: 1 }}>🎛️ אשף ההרכבה</h2>
        <Btn sm onClick={onClose}>✕ סגירה</Btn>
      </div>
      <p style={{ fontSize: 12.5, color: 'var(--ink-faint)', marginBottom: 14 }}>
        כל שינוי מוחל חי על המערכת שמאחור — הלקוח רואה את העמותה שלו נולדת.
      </p>

      <Field label="שם הארגון">
        <TextInput value={config.orgName} onChange={setName} placeholder="למשל: מאור החסד" />
      </Field>
      <Field label="מזהה לקוח (לועזי, לכתובת)">
        <TextInput
          value={config.slug}
          onChange={(v) => {
            setSlugTouched(true);
            patch({ slug: v.toLowerCase().replace(/[^a-z0-9-]/g, '-') });
          }}
          dir="ltr"
        />
      </Field>
      <Field label="לוגו (לא חובה)">
        <input type="file" accept="image/*" onChange={(e) => onLogo(e.target.files?.[0])} />
        {config.logoDataUri && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6 }}>
            <img src={config.logoDataUri} alt="לוגו" style={{ height: 34, borderRadius: 8 }} />
            <Btn sm onClick={() => patch({ logoDataUri: undefined })}>הסרה</Btn>
          </div>
        )}
      </Field>

      <Field label="ערכת נושא">
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {Object.entries(THEME_LABELS).map(([k, label]) => (
            <Chip key={k} on={config.theme === k} onClick={() => pickTheme(k)}>
              {label.split(' ')[0]}
            </Chip>
          ))}
        </div>
      </Field>
      <Field label="צבע מותאם (לא חובה)">
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input
            type="color"
            value={config.accent ?? '#f3c76b'}
            onChange={(e) => {
              patch({ accent: e.target.value });
              setAccent(e.target.value);
            }}
            style={{ width: 46, height: 32, padding: 2 }}
          />
          <Btn sm onClick={() => { patch({ accent: undefined }); setAccent(undefined); }}>
            צבע הערכה
          </Btn>
        </div>
      </Field>

      <Field label="מודולים בחבילה">
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {(Object.keys(MODULE_LABELS) as ModuleKey[]).map((k) => (
            <Chip key={k} on={config.modules[k] !== false} onClick={() => toggleModule(k)}>
              {MODULE_LABELS[k]}
            </Chip>
          ))}
        </div>
      </Field>

      <Field label="הרחבות שנמכרו (יופעלו בפגישת המשך)">
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {Object.entries(INTEGRATION_LABELS).map(([k, label]) => (
            <Chip key={k} on={config.integrations?.[k]?.enabled ?? false} onClick={() => toggleIntegration(k)}>
              {label}
            </Chip>
          ))}
        </div>
      </Field>

      <div style={{ borderTop: '1px dashed var(--line)', margin: '14px 0', paddingTop: 12 }}>
        <Field label="כתובת האתר (לדף המסירה)">
          <TextInput value={appUrl} onChange={setAppUrl} dir="ltr" />
        </Field>
        <Field label="חתימת המטמיע">
          <TextInput value={installer} onChange={setInstaller} />
        </Field>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <Btn kind="primary" onClick={createPackage}>📦 צור חבילה — config + דף מסירה</Btn>
        <Btn onClick={resetToDefault}>איפוס האשף לברירת מחדל</Btn>
      </div>

      <details style={{ marginTop: 14, fontSize: 12 }}>
        <summary style={{ cursor: 'pointer', color: 'var(--ink-faint)' }}>config.json (תצוגה)</summary>
        <pre
          dir="ltr"
          style={{
            background: 'var(--bg)',
            border: '1px solid var(--line)',
            borderRadius: 8,
            padding: 10,
            overflowX: 'auto',
            fontSize: 11,
          }}
        >
          {configJson}
        </pre>
      </details>

      <p style={{ fontSize: 11.5, color: 'var(--ink-faint)', marginTop: 12 }}>
        פרסום ללקוח: מעלים את הקובץ ל-<code dir="ltr">maor/public/c/{config.slug}/config.json</code>{' '}
        בריפו ודוחפים — הכתובת <code dir="ltr">?org={config.slug}</code> חיה תוך דקות. הנתונים של כל
        לקוח מבודדים אוטומטית.
      </p>
    </div>
  );
}
