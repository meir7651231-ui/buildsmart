// ☁️ חולל ע"י web-shell (G59 · הכרעה-31) — מקלט-דחיפה. אל תערוך ידנית.
//   גרסאות מקובעות בכוונה: CDN לא-מקובע משנה את המקלט מתחת לפריסה שלא נגעה בו.
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

const q = new URLSearchParams(self.location.search);
const cfg = { apiKey: q.get('apiKey'), projectId: q.get('projectId'), appId: q.get('appId'), messagingSenderId: q.get('messagingSenderId') || '', authDomain: q.get('authDomain') || '' };
if (cfg.apiKey && cfg.projectId && cfg.appId) {
  firebase.initializeApp(cfg);
  const messaging = firebase.messaging();
  messaging.onBackgroundMessage((payload) => {
    const n = payload.notification || {};
    const d = payload.data || {};
    self.registration.showNotification(n.title || "בדיקת חוזה שכירות", {
      body: n.body || '',
      icon: 'icon.svg',
      dir: 'rtl',
      lang: 'he',
      tag: d.rid ? 'due-' + d.rid : undefined,   // תזכורת אחת לתיק, לא ערימה
      data: d,
    });
  });
  self.addEventListener('notificationclick', (e) => {
    e.notification.close();
    e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((ws) => {
      for (const w of ws) { if ('focus' in w) return w.focus(); }
      return self.clients.openWindow(new URL('.', self.registration.scope).href);   // הורה-ה-scope = שורש-האפליקציה (בלי רגקס — נמלט-לרעה בתבנית)
    }));
  });
}
