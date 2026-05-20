import { navigate, type Route } from '../store/app-store';

type QuickAction = {
  label: string;
  helper: string;
  target: Route;
};

const ACTIONS: QuickAction[] = [
  { label: 'קטלוג', helper: 'הוסף מוצרים לעגלה', target: 'catalog' },
  { label: 'פרויקטים', helper: 'תקציב ומשימות פעילים', target: 'sites' },
  { label: 'עגלה', helper: 'תכנן משלוחים', target: 'cart' },
  { label: 'הגדרות', helper: 'פרופיל והעדפות', target: 'profile' },
];

export function HomeView() {
  return (
    <section class="home">
      <div class="hero">
        <p class="hero__eyebrow">גרסה 0.1</p>
        <h2 class="hero__title">ברוך הבא ל-BuildSmart</h2>
        <p class="hero__subtitle">שלד אפליקציה חדש — מסכים יתווספו בהדרגה.</p>
      </div>

      <div class="grid grid--2">
        {ACTIONS.map((action) => (
          <button
            key={action.target}
            type="button"
            class="action"
            onClick={() => navigate(action.target)}
          >
            <span class="action__label">{action.label}</span>
            <span class="action__helper">{action.helper}</span>
          </button>
        ))}
      </div>
    </section>
  );
}
