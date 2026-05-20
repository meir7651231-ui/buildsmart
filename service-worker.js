/* =====================================================================
   BuildSmart — Service Worker
   Provides offline support: caches the app shell on install and serves
   it from cache when the network is unavailable (construction sites
   frequently have no signal). Cache-first for the shell, network-first
   for everything else with a cache fallback.
   ===================================================================== */
var CACHE_NAME = 'buildsmart-v107';
var APP_SHELL = [
  './index.html',
  './manifest.json'
];

/* install — pre-cache the app shell */
self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      return cache.addAll(APP_SHELL);
    }).then(function () {
      return self.skipWaiting();
    })
  );
});

/* activate — clean out old cache versions */
self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(
        keys.filter(function (k) { return k !== CACHE_NAME; })
            .map(function (k) { return caches.delete(k); })
      );
    }).then(function () {
      return self.clients.claim();
    })
  );
});

/* fetch — network-first, fall back to cache when offline */
self.addEventListener('fetch', function (event) {
  if (event.request.method !== 'GET') return;
  event.respondWith(
    fetch(event.request).then(function (response) {
      /* keep the cache fresh with successful responses */
      var copy = response.clone();
      caches.open(CACHE_NAME).then(function (cache) {
        cache.put(event.request, copy);
      }).catch(function () {});
      return response;
    }).catch(function () {
      /* offline — serve from cache, or the app shell as a last resort */
      return caches.match(event.request).then(function (cached) {
        return cached || caches.match('./index.html');
      });
    })
  );
});
