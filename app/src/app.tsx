import { FloatingHeader } from './components/floating-header';
import { HomeView } from './views/home';
import { MenuSpeedDial } from './components/menu-speed-dial';
import { SearchOverlay } from './components/search-overlay';
import { ProductSheet } from './components/product-sheet';

export function App() {
  return (
    <div class="screen">
      <div class="screen__bg" aria-hidden="true" />
      <FloatingHeader />
      <main class="content">
        <HomeView />
      </main>
      <MenuSpeedDial />
      <SearchOverlay />
      <ProductSheet />
    </div>
  );
}
