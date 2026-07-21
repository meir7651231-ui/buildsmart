/**
 * שלד האפליקציה: ניווט, החלפת מסכים, טוסטים, פלטת פקודות (Ctrl+K)
 * וגיבוי סוף-יום אוטומטי.
 */
import { useEffect, useState, type JSX } from 'react';
import { useApp, type View } from './store/useApp';
import { featureOn, termOf } from './lib/config';
import { BuilderWizard } from './components/builder/BuilderWizard';
import { ImpactWall } from './components/wall/ImpactWall';
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
import { DayGate } from './components/wheel/DayGate';
import { LoginScreen } from './components/cloud/LoginScreen';

/** צבע נקודת הסטטוס של סנכרון הענן — ירוק = synced. */
const SYNC_DOT: Record<string, { color: string; title: string }> = {
  synced: { color: '#3fae5a', title: 'מסונכרן עם הענן' },
  connecting: { color: '#e2b93b', title: 'מתחבר לענן…' },
  error: { color: '#e05252', title: 'שגיאת סנכרון — הנתונים שמורים מקומית' },
  idle: { color: '#9aa0a6', title: 'סנכרון לא פעיל' },
};

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
  const cloud = useApp((s) => s.cloud);
  const cloudSignOut = useApp((s) => s.cloudSignOut);

  useEffect(() => {
    void init();
  }, [init]);

  // אשף ההרכבה — למטמיע בלבד, נפתח עם #builder בכתובת
  const [builderOpen, setBuilderOpen] = useState(() => window.location.hash === '#builder');
  // קיר ההשפעה — מצב ראווה במסך מלא, נפתח עם #wall (feature: home.impactwall)
  const [wallOpen, setWallOpen] = useState(() => window.location.hash === '#wall');
  useEffect(() => {
    const onHash = () => {
      setBuilderOpen(window.location.hash === '#builder');
      setWallOpen(window.location.hash === '#wall');
    };
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, []);

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

  // גיבוי סוף-יום: פעם ביום, אחרי שעת הסיום שנקבעה בפתיחת היום
  // (localStorage 'maor_dayend', ברירת מחדל 17:00), יורד קובץ גיבוי אוטומטית
  useEffect(() => {
    const tick = setInterval(() => {
      try {
        const today = new Date().toISOString().slice(0, 10);
        if (localStorage.getItem('maor_autoexp') === today) return;
        const [eh, em] = (localStorage.getItem('maor_dayend') || '17:00').split(':').map(Number);
        const endMin = (Number.isFinite(eh) ? eh : 17) * 60 + (Number.isFinite(em) ? em : 0);
        const now = new Date();
        if (now.getHours() * 60 + now.getMinutes() < endMin) return;
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

  const toastsEl = (
    <div className="toasts" role="status" aria-live="polite">
      {toasts.map((t) => (
        <div key={t.id} className="toast">
          {t.text}
        </div>
      ))}
    </div>
  );

  // שער הענן: ארגון עם config.firebase מחייב התחברות לפני הכניסה לאפליקציה
  if (cloud.enabled && !cloud.authReady) return <div className="empty">מתחבר…</div>;
  if (cloud.enabled && !cloud.user) {
    return (
      <>
        <LoginScreen />
        {toastsEl}
      </>
    );
  }

  const Current = VIEWS[view];
  const syncDot = SYNC_DOT[cloud.status] ?? SYNC_DOT.idle;

  // מיתוג: שם מהקונפיגורציה גובר על השם השמור בנתונים
  const orgName = config.orgName || dbOrgName;
  // מודולים: בית תמיד; השאר לפי config.modules (חסר = פעיל).
  // הגדרות עברו לאייקון ⚙️ בקצה השמאלי של הסרגל העליון — לא קישור ברצועה.
  const nav = NAV.filter(
    (n) => n.view !== 'settings' && (n.view === 'home' || config.modules[n.view] !== false),
  );

  return (
    <div className="app-shell">
      {/* סרגל עליון — הכרום מתחלף פר-ערכה דרך משתני --nav2-* (themes.css) */}
      <header className="app-top">
        <div className="brand">
          {config.logoDataUri && <img src={config.logoDataUri} alt="" />}
          <span className="brand-name">{orgName}</span>
        </div>
        <nav className="app-nav" aria-label="ניווט ראשי">
          {nav.map((n) => (
            <button
              key={n.view}
              className={view === n.view ? 'active' : ''}
              onClick={() => go(n.view)}
            >
              {/* מונח מותאם מהמילון לששת מסכי המודולים; בית נשאר קבוע */}
              {n.view === 'home' ? n.label : termOf(config, `nav.${n.view}`, n.label)}
            </button>
          ))}
        </nav>
        <div className="top-tools">
          {/* צ'יפ החיפוש — פותח את פלטת הפקודות, אותו מנגנון כמו Ctrl+K */}
          <button
            type="button"
            className="nav-search"
            onClick={() => setPalette(true)}
            title="חיפוש בכל המערכת (Ctrl+K)"
          >
            <span aria-hidden>🔍</span>
            <span className="nav-search-label">חיפוש בכל המערכת</span>
            <kbd aria-hidden>Ctrl K</kbd>
          </button>
          <button
            type="button"
            className={'nav-gear' + (view === 'settings' ? ' active' : '')}
            onClick={() => go('settings')}
            title="הגדרות"
            aria-label="הגדרות"
          >
            <span aria-hidden>⚙️</span>
          </button>
          {cloud.enabled && cloud.user && (
            <div className="nav-user">
              <span
                aria-hidden
                title={syncDot.title}
                style={{
                  width: 8,
                  height: 8,
                  borderRadius: 99,
                  background: syncDot.color,
                  flex: '0 0 auto',
                }}
              />
              <span className="nav-user-mail" title={cloud.user.email}>
                {cloud.user.email}
              </span>
              <button onClick={() => void cloudSignOut()} title="יציאה מהחשבון — הנתונים נשארים במכשיר">
                יציאה
              </button>
            </div>
          )}
        </div>
      </header>

      <main className="app-main">
        {famCount === 0 && <DemoDrop />}
        <DayGate />
        <Current />
      </main>

      {paletteOpen && <CommandPalette />}

      {builderOpen && (
        <BuilderWizard
          onClose={() => {
            window.location.hash = '';
            setBuilderOpen(false);
          }}
        />
      )}

      {wallOpen && featureOn(config, 'home.impactwall') && (
        <ImpactWall
          onClose={() => {
            window.location.hash = '';
            setWallOpen(false);
          }}
        />
      )}

      {toastsEl}
    </div>
  );
}
