// חוט · ics-feed-url — כתובת-המנוי הציבורית של פיד-היומן (icsFeed). חוזה: ics-feed-url.contract.md
// המרה מ-JS (new/atoms/ics-feed-url.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חוק-6: projectId/slug/token מוזרקים כקלט — שום זהות לא נצרבת באטום.
// JS encodeURIComponent ⇒ Dart Uri.encodeComponent (מקודד זהה: רווח⇒%20, UTF-8 hex-גדול; לא מקודד -_.!~*'()).
// ה-token מודבק כמו-שהוא (בלי קידוד). אפס-import (dart-core בלבד).
String icsFeedUrl(String projectId, String slug, String token) {
  return 'https://us-central1-' +
      projectId +
      '.cloudfunctions.net/icsFeed?org=' +
      Uri.encodeComponent(slug) +
      '&key=' +
      token;
}
