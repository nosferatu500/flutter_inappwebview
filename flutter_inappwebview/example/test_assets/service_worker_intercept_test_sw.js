// Service Worker for integration_test/service_worker_controller/intercept_response.dart.
//
// Takes control immediately, and answers a fetch of the probe file by fetching it again *from the
// worker*. That second fetch is a Service Worker request, so it is what reaches
// `ServiceWorkerClient.shouldInterceptRequest` on Android — the page's own fetch is not.
self.addEventListener('install', (event) => event.waitUntil(self.skipWaiting()));
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));
self.addEventListener('fetch', (event) => {
    if (event.request.url.includes('service_worker_intercept_test_probe.txt')) {
        // `no-store` so the HTTP cache cannot answer instead of the network (and the interceptor).
        event.respondWith(fetch(event.request.url, {cache: 'no-store'}));
    }
});
