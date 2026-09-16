{{flutter_js}}
{{flutter_build_config}}

(async () => {
  // Retire Flutter's old offline cache while keeping saved player progress.
  try {
    if ('serviceWorker' in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      await Promise.all(registrations.map((registration) => {
        const worker = registration.active || registration.waiting || registration.installing;
        if (worker && new URL(worker.scriptURL).pathname.endsWith('/flutter_service_worker.js')) {
          return registration.unregister();
        }
      }));
    }
    if ('caches' in window) {
      await Promise.all(['flutter-app-cache', 'flutter-temp-cache', 'flutter-app-manifest']
        .map((name) => caches.delete(name)));
    }
  } catch (error) {
    console.warn('Could not retire the previous Flutter cache.', error);
  }

  // Bypass an already cached main.dart.js during this migration.
  for (const build of _flutter.buildConfig.builds) {
    if (build.mainJsPath) {
      build.mainJsPath += '?release=viewport-cache-fix-1';
    }
  }
  _flutter.loader.load();
})();
