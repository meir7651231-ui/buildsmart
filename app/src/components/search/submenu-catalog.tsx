/* @legacy index.html:6046-6056 (CATALOG top categories — verbatim).
 * 11 categories with emoji + label, rendered as .ssub rows inside the
 * search rail. Catalog lives under the search FAB (not the menu FAB). */
import { showToast } from '../../store/toast-store';

type CatalogCat = { id: string; emoji: string; title: string };

const CATALOG_CATS: CatalogCat[] = [
  { id: 'taps',       emoji: '🚰', title: 'ברזים וכיורים' },
  { id: 'toilets',    emoji: '🚽', title: 'אסלות' },
  { id: 'showers',    emoji: '🚿', title: 'מקלחות ואמבטיות' },
  { id: 'heating',    emoji: '♨️', title: 'חימום מים' },
  { id: 'kitchen',    emoji: '🍽️', title: 'מטבח' },
  { id: 'drainage',   emoji: '🕳️', title: 'ניקוז וצנרת' },
  { id: 'sanitary',   emoji: '🚾', title: 'גופי תברואה' },
  { id: 'endparts',   emoji: '🔗', title: 'אביזרי קצה וחיבורים' },
  { id: 'building',   emoji: '🧱', title: 'בנייה ומחיצות' },
  { id: 'finishing',  emoji: '🎨', title: 'גמר' },
  { id: 'acc',        emoji: '🧰', title: 'אביזרים נלווים' },
];

export function CatalogSubmenu() {
  return (
    <div class="ssub">
      {CATALOG_CATS.map((c) => (
        <button
          key={c.id}
          type="button"
          class="ssub__row"
          onClick={() => showToast(`${c.title} — בבנייה`)}
          aria-label={c.title}
        >
          <span class="ssub__icon">
            <span class="ssub__emoji">{c.emoji}</span>
          </span>
          <span class="ssub__label">{c.title}</span>
        </button>
      ))}
    </div>
  );
}
