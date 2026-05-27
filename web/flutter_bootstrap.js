{{flutter_js}}
{{flutter_build_config}}

(async function () {
  if ('serviceWorker' in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations();
    const flutterRegistrations = registrations.filter((registration) => {
      const urls = [
        registration.active?.scriptURL,
        registration.waiting?.scriptURL,
        registration.installing?.scriptURL,
      ].filter(Boolean);

      return urls.some((url) => url.includes('flutter_service_worker.js'));
    });

    if (flutterRegistrations.length > 0) {
      await Promise.all(
        flutterRegistrations.map((registration) => registration.unregister()),
      );

      if ('caches' in window) {
        const cacheKeys = await caches.keys();
        await Promise.all(
          cacheKeys
            .filter((key) => key.startsWith('flutter-'))
            .map((key) => caches.delete(key)),
        );
      }

      if (navigator.serviceWorker.controller != null) {
        const reloadFlag = 'flutter-web-cache-reset';
        if (sessionStorage.getItem(reloadFlag) !== 'done') {
          sessionStorage.setItem(reloadFlag, 'done');
          window.location.reload();
          return;
        }
        sessionStorage.removeItem(reloadFlag);
      }
    }
  }

  await _flutter.loader.load();
}());
