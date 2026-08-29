// The browser's background listener for push — the piece the website was missing.
//
// A page can only receive a notification while it is open. Everything a person
// actually wants a notification FOR happens while it is closed, and that is what
// a service worker is: a small script the browser keeps alive on its own so it
// can wake for a push and draw the notification. Without this file the site
// registered no receiver at all, so nothing arrived on the web no matter what
// the server sent. (Mobile was never affected — the platform SDK owns that path,
// which is why the gap stayed invisible.)
//
// SCOPE MATTERS: it must be served from the site ROOT (/firebase-messaging-sw.js)
// so its scope covers every page. Flutter copies web/ verbatim into build/web,
// which puts it there. It is also listed in firebase.json's no-cache header
// group — a stale service worker is a receiver frozen on old code, and it can
// outlive several deploys.
//
// The compat SDK (not the modular one) is deliberate: a service worker has no
// bundler, and importScripts is how it gets a library. Versions are pinned; an
// unpinned CDN URL would silently change the receiver under a deploy that
// touched nothing.

importScripts(
  'https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js',
);

// Mirrors FirebaseOptions.web in lib/firebase_options.dart. All of these values
// are public client identifiers — the same ones already compiled into the app
// bundle — not secrets. They are duplicated here because a service worker runs
// outside the Flutter app and cannot read Dart constants; if firebase_options
// changes, this must change with it.
firebase.initializeApp({
  apiKey: 'AIzaSyDA7iDvD23dhQR5WQu62tyNj2wgyewlzog',
  authDomain: 'buildsmart-b0b78.firebaseapp.com',
  projectId: 'buildsmart-b0b78',
  storageBucket: 'buildsmart-b0b78.firebasestorage.app',
  messagingSenderId: '483064122180',
  appId: '1:483064122180:web:d1f6bac271c87324ca6511',
});

const messaging = firebase.messaging();

// A background push. The server sends a `notification` block, which the browser
// renders on its own, so this handler exists to attach the routing payload — the
// data the click handler below needs to land on the right conversation.
messaging.onBackgroundMessage((payload) => {
  const n = payload.notification || {};
  const data = payload.data || {};
  self.registration.showNotification(n.title || 'BuildSmart', {
    body: n.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    dir: 'rtl',
    lang: 'he',
    // One notification per conversation rather than a pile of them: a second
    // message in the same thread replaces the first instead of stacking.
    tag: data.threadId ? `thread-${data.threadId}` : undefined,
    data,
  });
});

// The click. This is the whole feature as far as the person is concerned: the
// notification is a LINK, and it has to land on the conversation it announced,
// not merely open the site.
//
// Focus an existing tab when there is one — opening a second copy of a running
// app is its own small betrayal — and hand it the thread id through postMessage,
// because a focused tab does not reload and would otherwise ignore the URL.
// Only when nothing is open do we launch a fresh page with the id in the query
// string, which the app reads on startup.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const threadId = (event.notification.data || {}).threadId;
  const target = threadId ? `/?thread=${encodeURIComponent(threadId)}` : '/';

  event.waitUntil(
    self.clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((all) => {
        for (const client of all) {
          if ('focus' in client) {
            if (threadId) {
              client.postMessage({ type: 'bs-open-thread', threadId });
            }
            return client.focus();
          }
        }
        return self.clients.openWindow(target);
      }),
  );
});
