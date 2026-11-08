// Service worker: เก็บตัวแอปไว้ในเครื่องเพื่อให้ติดตั้งและเปิดเร็ว
// ข้อมูลพัสดุเก็บบน Supabase (ต้องมีอินเทอร์เน็ต) ไฟล์นี้เก็บเฉพาะตัวแอปให้เปิดเร็ว
const CACHE = 'parcel-map-v2';
const APP_FILES = ['./', './index.html', './manifest.json', './config.js', './icon-192.png', './icon-512.png'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(APP_FILES)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // ไฟล์ของแอปเอง: ลองเน็ตก่อน ถ้าไม่ได้ค่อยใช้ที่เก็บไว้
  if (url.origin === location.origin) {
    e.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(req, copy));
          return res;
        })
        .catch(() => caches.match(req).then((r) => r || caches.match('./index.html')))
    );
  }
});
