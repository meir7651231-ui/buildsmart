import { FloatingHeader } from './components/floating-header';
import { Fabs } from './components/fabs';
import { MenuSpeedDial } from './components/menu-speed-dial';
import { SearchPanel } from './components/search/search-panel';
import { BsDial } from './components/bs/bs-dial';
import { ProductSheet } from './components/product-sheet';
import { HomeView } from './views/home';
import { ManagerView } from './views/manager';
import { StoreView } from './views/store';
import { CourierView } from './views/courier';
import { WorkerView } from './views/worker';
import { activePersona } from './store/bs-store';

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
    </div>
  );
}
