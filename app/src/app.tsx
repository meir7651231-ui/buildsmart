import { FloatingHeader } from './components/floating-header';
import { HomeView } from './views/home';
import { Fabs } from './components/fabs';
import { MenuSpeedDial } from './components/menu-speed-dial';
import { SearchPanel } from './components/search/search-panel';
import { BsPanel } from './components/bs/bs-panel';
import { ProductSheet } from './components/product-sheet';

export function App() {
  return (
    <div class="screen">
      <div class="screen__bg" aria-hidden="true" />
      <FloatingHeader />
      <main class="content">
        <HomeView />
      </main>
      <Fabs />
      <MenuSpeedDial />
      <SearchPanel />
      <BsPanel />
      <ProductSheet />
    </div>
  );
}
