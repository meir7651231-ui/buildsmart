/**
 * שלד האפליקציה: ניווט, החלפת מסכים, טוסטים, פלטת פקודות (Ctrl+K)
 * וגיבוי סוף-יום אוטומטי.
 */
import { useEffect, type JSX } from 'react';
import { useApp, type View } from './store/useApp';
import { HomeView } from './components/home/HomeView';
import { FamiliesView } from './components/families/FamiliesView';
import { CoursesView } from './components/courses/CoursesView';
import { CalendarView } from './components/calendar/CalendarView';
import { DiaryView } from './components/diary/DiaryView';
import { SupportersView } from './components/supporters/SupportersView';
import { ReportsView } from './components/reports/ReportsView';
import { SettingsView } from './components/settings/SettingsView';
import { CommandPalette } from './components/palette/CommandPalette';
import { DemoDrop } from './components/DemoDrop';

const NAV: { view: View; icon: string; label: string }[] = [
  { view: 'home', icon: '🏠', label: 'בית' },
  { view: 'families', icon: '👨‍👩‍👧‍👦', label: 'משפחות' },
  { view: 'courses', icon: '🎨', label: 'חוגים' },
  { view: 'calendar', icon: '📅', label: 'לוח שנה' },
  { view: 'diary', icon: '📖', label: 'יומן חדרים' },
  { view: 'supporters', icon: '💛', label: 'תורמים' },
  { view: 'reports', icon: '📊', label: 'דוחות' },
  { view: 'settings', icon: '⚙️', label: 'הגדרות' },
];

const VIEWS: Record<View, () => JSX.Element> = {
  home: HomeView,
  families: FamiliesView,
  courses: CoursesView,
  calendar: CalendarView,
  diary: DiaryView,
  supporters: SupportersView,
  reports: ReportsView,
  settings: SettingsView,
};

export default function App() {
  const ready = useApp((s) => s.ready);
  const view = useApp((s) => s.view);
  const go = useApp((s) => s.go);
  const dbOrgName = useApp((s) => s.db.orgName);
  const famCount = useApp((s) => s.db.families.length);
  const config = useApp((s) => s.config);
  const toasts = useApp((s) => s.toasts);
  const paletteOpen = useApp((s) => s.paletteOpen);
  const setPalette = useApp((s) => s.setPalette);
  const init = useApp((s) => s.init);
  const exportBackup = useApp((s) => s.exportBackup);

  useEffect(() => {
    void init();
  }, [init]);

  // קיצורי מקלדת גלובליים
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        setPalette(!useApp.getState().paletteOpen);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [setPalette]);

  // גיבוי סוף-יום: פעם ביום, אחרי 17:00, יורד קובץ גיבוי אוטומטית
  useEffect(() => {
    const tick = setInterval(() => {
      try {
        const today = new Date().toISOString().slice(0, 10);
        if (localStorage.getItem('maor_autoexp') === today) return;
        if (new Date().getHours() < 17) return;
        if (!useApp.getState().db.families.length) return;
        localStorage.setItem('maor_autoexp', today);
        exportBackup();
      } catch {
        /* localStorage חסום — נדלג */
      }
    }, 60_000);
    return () => clearInterval(tick);
  }, [exportBackup]);

  if (!ready) return <div className="empty">טוען…</div>;

  const Current = VIEWS[view];

  // מיתוג: שם מהקונפיגורציה גובר על השם השמור בנתונים
  const orgName = config.orgName || dbOrgName;
  // מודולים: בית והגדרות תמיד; השאר לפי config.modules (חסר = פעיל)
  const nav = NAV.filter(
    (n) => n.view === 'home' || n.view === 'settings' || config.modules[n.view] !== false,
  );

  return (
    <div className="app-shell">
      <nav className="app-nav" aria-label="ניווט ראשי">
        <div className="brand">{orgName}</div>
        {nav.map((n) => (
          <button key={n.view} className={view === n.view ? 'active' : ''} onClick={() => go(n.view)}>
            <span aria-hidden>{n.icon}</span>
            {n.label}
          </button>
        ))}
        <div className="spacer" />
        <button onClick={() => setPalette(true)} title="Ctrl+K">
          <span aria-hidden>⌨️</span>חיפוש מהיר
        </button>
      </nav>

      <main className="app-main">
        {famCount === 0 && <DemoDrop />}
        <Current />
      </main>

      {paletteOpen && <CommandPalette />}

      <div className="toasts" role="status" aria-live="polite">
        {toasts.map((t) => (
          <div key={t.id} className="toast">
            {t.text}
          </div>
        ))}
      </div>
    </div>
  );
}
