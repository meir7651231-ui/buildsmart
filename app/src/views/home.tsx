export function HomeView() {
  return (
    <section class="home">
      <div class="hero">
        <p class="hero__eyebrow">גרסה 0.1</p>
        <h2 class="hero__title">ברוך הבא ל-BuildSmart</h2>
        <p class="hero__subtitle">
          האפליקציה החדשה בבנייה — שלד תשתית מוכן.
        </p>
      </div>

      <div class="card">
        <h3 class="card__title">מה הלאה</h3>
        <ul class="card__list">
          <li>הוצאת התמונות מ-base64 לקבצי נכסים</li>
          <li>פיצול CSS למודולים</li>
          <li>מיגרציה של view-by-view מהאב-טיפוס</li>
          <li>חיבור Capacitor לבילד iOS / Android</li>
        </ul>
      </div>
    </section>
  );
}
