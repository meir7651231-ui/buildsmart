/* @legacy index.html:6545-6680 (refreshIdentity).
 * Placeholder — shows the 10 section names from the legacy profile/identity
 * page, no real data yet. Section #9 (SETTINGS LINKS) contains the live
 * "הגדרות מתקדמות" entry that opens the settings dial we built. */
import { openSettingsDial } from '../store/app-store';

type Section = { id: string; title: string };

/* Headers verbatim from refreshIdentity sections — see comments in
 * index.html:6567 (HERO), 6594 (REGISTER), 6604 (STATS), 6610 (SPENT),
 * 6617 (PERK), 6625 (ACHIEVE), 6635 (RANKS), 6650 (HUB), 6661 (SETTINGS). */
const SECTIONS: Section[] = [
  { id: 'hero',     title: 'כרטיס קבלן' },
  { id: 'register', title: 'אתה במצב הדגמה' },
  { id: 'stats',    title: 'המספרים שלך' },
  { id: 'spent',    title: 'סך הרכש דרך BuildSmart' },
  { id: 'perk',     title: 'ההטבה שלך' },
  { id: 'achieve',  title: 'הישגים' },
  { id: 'ranks',    title: 'דרגות הקבלן' },
  { id: 'hub',      title: 'מועדון BuildSmart' },
];

export function ProfileView() {
  return (
    <section class="profile" aria-label="פרופיל">
      <header class="profile__head">
        <h2 class="profile__title">הגדרות</h2>
        <p class="profile__sub">בבנייה — לעת עתה כותרות סעיפים בלבד מהאב-טיפוס</p>
      </header>

      <ul class="profile__sections">
        {SECTIONS.map((s) => (
          <li key={s.id} class="profile__section">
            <span class="profile__section-t">{s.title}</span>
            <span class="profile__section-tag">בבנייה</span>
          </li>
        ))}
      </ul>

      <div class="profile__sec-h">הגדרות</div>
      <ul class="profile__settings">
        <li class="profile__set-row">
          <button
            type="button"
            class="profile__set-btn"
            aria-label="הגדרות מתקדמות"
            onClick={openSettingsDial}
          >
            <span class="profile__set-ic">⚙️</span>
            <span class="profile__set-l">הגדרות מתקדמות</span>
            <span class="profile__set-a">›</span>
          </button>
        </li>
      </ul>

      <p class="profile__foot">BuildSmart · אב-טיפוס הדגמה<br />הנתונים מתאפסים ברענון הדף</p>
    </section>
  );
}
