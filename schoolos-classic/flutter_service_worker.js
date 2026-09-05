'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"firebase-messaging-sw.js": "2a2983a6c96c2735ec25d203145bf534",
"favicon.png": "f25dd50759ac36ee163849ea3868455d",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"flutter_bootstrap.js": "93f94eefaff050757d91c901c69a07dc",
"assets/NOTICES": "bb800946f725c18c1f1e16f6d1d7cc0c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/AssetManifest.bin": "f2329a46ffdab3db60623ddd5fce1b78",
"assets/assets/lipskey/categories/garden.png": "ea396a005015ae070f6844606fb8fb36",
"assets/assets/lipskey/categories/pipes.png": "6dda6686984f7cd919c3d8efca04db56",
"assets/assets/lipskey/categories/ppr.png": "33f20ab30e9e76021cf5a82b59381993",
"assets/assets/lipskey/categories/other.png": "32383ac6f9ea2f76b733ea2ea3bb52b9",
"assets/assets/lipskey/categories/clamps.png": "5c558b080ae35d349a2843386fd3160e",
"assets/assets/lipskey/categories/faucets.png": "7bfb618767be097804bfe1b21667bbec",
"assets/assets/lipskey/categories/shower_bath.png": "e95c79cd4aae2496d397bd414ddc1a71",
"assets/assets/lipskey/categories/drainage.png": "2dc1b972729691f0e289035664e2d6b9",
"assets/assets/lipskey/categories/smartlock.png": "4685803a4884ccf513c4d794ec583bc0",
"assets/assets/lipskey/categories/toilets.png": "40783f19f22e0b98e2427959e5ea4b29",
"assets/assets/lipskey/categories/connectors.png": "50bc2b5504394ca69d60979f23f09090",
"assets/assets/fonts/JetBrainsMono-Bold.ttf": "79e9a0365a86aeb48c8d51212b215c9b",
"assets/assets/fonts/Heebo-ExtraBold.ttf": "b2379a925c9f5f1feb3fb0a2a0b0bae6",
"assets/assets/fonts/Heebo.ttf": "8c24700558e6d8f4c2d971cb4a6109ad",
"assets/assets/fonts/Heebo-Bold.ttf": "bbd6e2b3cf979777d518825ba66fa261",
"assets/assets/fonts/Heebo-SemiBold.ttf": "985d776e52069c747743ce490daaff7c",
"assets/assets/fonts/Heebo-Regular.woff2": "e9c7cfef7fb82d3c05b26ff038b44eb0",
"assets/assets/fonts/JetBrainsMono-Regular.ttf": "3c265c5a740649823327d74a46a84d54",
"assets/assets/fonts/Heebo-Regular.ttf": "b6252952a232384c240a25f621fffedd",
"assets/assets/fonts/FrankRuhlLibre.ttf": "ebc976487074831f0b7a12e43e36da20",
"assets/assets/fonts/JetBrainsMono-ExtraBold.ttf": "8d83c4826bd219efd19fe257fe0165ec",
"assets/FontManifest.json": "c5d57fdb9f771ff45ec2445c39fbae1a",
"assets/AssetManifest.json": "013a90483662944393063959d0218c09",
"assets/fonts/MaterialIcons-Regular.otf": "3104788330bc241456a66d550abdfd2c",
"assets/AssetManifest.bin.json": "b3a7997cf3101199f0496857369bde36",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"index.html": "d5706e8726397332b7e4db864e1a99bd",
"/": "d5706e8726397332b7e4db864e1a99bd",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"main.dart.js": "d769e7495de0988acd9ed6b25bef69d1",
"manifest.json": "bacdcf467ac2913935213ca7c40873dc",
"icons/Icon-512.png": "ab7423867da116fab43ccb21fc6d6d25",
"icons/og-image.png": "7f8ec28dafb1d75afd28cb1f0d5552b9",
"icons/Icon-maskable-512.png": "81e362acd349a1876a2ec2f74bc56327",
"icons/Icon-maskable-192.png": "3d88a5ce37a2d46a6dbf58bd440a3771",
"icons/Icon-192.png": "1847bc3295756fdac082b3b81a1c5835",
"version.json": "17dd1b2094c06c83d0dad5ebf5fd52a8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
