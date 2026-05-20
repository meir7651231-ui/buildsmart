import { AppBar } from './components/app-bar';
import { TabBar } from './components/tab-bar';
import { route } from './store/app-store';
import { HomeView } from './views/home';
import { CatalogView } from './views/catalog';
import { SitesView } from './views/sites';
import { CartView } from './views/cart';
import { ProfileView } from './views/profile';

function ActiveView() {
  switch (route.value) {
    case 'home':
      return <HomeView />;
    case 'catalog':
      return <CatalogView />;
    case 'sites':
      return <SitesView />;
    case 'cart':
      return <CartView />;
    case 'profile':
      return <ProfileView />;
  }
}

export function App() {
  return (
    <div class="screen">
      <AppBar />
      <main class="content">
        <ActiveView />
      </main>
      <TabBar />
    </div>
  );
}
