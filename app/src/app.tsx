import { FloatingHeader } from './components/floating-header';
import { Fabs } from './components/fabs';
import { MenuSpeedDial } from './components/menu-speed-dial';
import { SearchPanel } from './components/search/search-panel';
import { BsDial } from './components/bs/bs-dial';
import { ProductSheet } from './components/product-sheet';
import { Toast } from './components/toast';
import { HomeView } from './views/home';
import { ManagerView } from './views/manager';
import { StoreView } from './views/store';
import { CourierView } from './views/courier';
import { WorkerView } from './views/worker';
import { activePersona } from './store/bs-store';
import './store/app-settings';

/* Per R2/R3, menu-driven destinations stay in the dial (no full-window
 * page swaps). View routing is purely persona-driven: each persona has
 * its default view, full stop. */
function ActiveView() {
  switch (activePersona.value) {
    case 'manager':
      return <ManagerView />;
    case 'store':
      return <StoreView />;
    case 'courier':
      return <CourierView />;
    case 'worker':
      return <WorkerView />;
    case 'contractor':
    default:
      return <HomeView />;
  }
}

export function App() {
  return (
    <div class="screen">
      <div class="screen__bg" aria-hidden="true" />
      <FloatingHeader />
      <main class="content">
        <ActiveView />
      </main>
      <Fabs />
      <MenuSpeedDial />
      <SearchPanel />
      <BsDial />
      <ProductSheet />
      <Toast />
    </div>
  );
}
