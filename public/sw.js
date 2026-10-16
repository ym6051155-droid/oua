const CACHE_NAME = "ahlia-shell-v1";
const SHELL = ["/", "/login", "/register", "/manifest.json"];
self.addEventListener("install", event => { event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(SHELL))); self.skipWaiting(); });
self.addEventListener("activate", event => { event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;
  event.respondWith(caches.match(req).then(cached => {
    const network = fetch(req).then(response => {
      if (response.ok && (req.mode === "navigate" || /\.(css|js|woff2?|png|svg|json)$/.test(new URL(req.url).pathname)) {
        const copy = response.clone(); caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
      }
      return response;
    }).catch(() => cached || caches.match("/"));
    return cached || network;
  }));
});