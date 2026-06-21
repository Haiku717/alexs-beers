/* Alex's Beers — offline service worker.
   Caches the app so it opens with no internet once it's been loaded once. */
const CACHE = 'alexs-beers-v3';
const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const req = e.request;
  // Only ever cache the app's own files. Anything cross-origin (the shared
  // beer database on Supabase, the Supabase library on the CDN) must always go
  // straight to the network so the shared shelf is live, never stale.
  if (new URL(req.url).origin !== self.location.origin) return;
  const isPage = req.mode === 'navigate' ||
                 (req.headers.get('accept') || '').includes('text/html');

  if (isPage) {
    // Network-first for the app page, so a fresh upload always wins
    // (offline falls back to the cached copy). Stops a bad version sticking.
    e.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put('./index.html', copy));
        return res;
      }).catch(() => caches.match(req).then(hit => hit || caches.match('./index.html')))
    );
    return;
  }

  // Cache-first for icons/manifest etc.
  e.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(req, copy));
      return res;
    }))
  );
});
