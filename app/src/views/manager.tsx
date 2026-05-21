import { RegressionPanel } from '../components/regression/regression-panel';

export function ManagerView() {
  return (
    <div class="mgr">
      <header class="mgr__head">
        <span class="mgr__head-emoji" aria-hidden="true">👔</span>
        <div>
          <h2 class="mgr__title">מנהל המערכת</h2>
          <p class="mgr__sub">לוח-בקרה, ניהול, בדיקות איכות</p>
        </div>
      </header>
      <RegressionPanel />
    </div>
  );
}
