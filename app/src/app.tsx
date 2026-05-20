import { AppBar } from './components/app-bar';
import { HomeView } from './views/home';

export function App() {
  return (
    <div class="screen">
      <AppBar />
      <main class="content">
        <HomeView />
      </main>
    </div>
  );
}
