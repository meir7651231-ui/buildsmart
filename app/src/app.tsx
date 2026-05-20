import { AppBar } from './components/app-bar';
import { HomeView } from './views/home';
import { MenuSpeedDial } from './components/menu-speed-dial';
import { SearchOverlay } from './components/search-overlay';
import { ProductSheet } from './components/product-sheet';

export function App() {
  return (
    <div class="screen">
      <AppBar />
      <main class="content">
        <HomeView />
      </main>
      <MenuSpeedDial />
      <SearchOverlay />
      <ProductSheet />
    </div>
  );
}
