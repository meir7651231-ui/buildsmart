// Canvas downscale seam (#85ב web) — re-encodes a captured photo to a small
// JPEG data-URL so it fits the SharedPreferences/localStorage persist budget.
//
// On WEB this resolves to the browser-canvas implementation
// (photo_downscale_web.dart — the same canvas re-encode image_picker_for_web
// applies to its own picks); on mobile it resolves to the IO stub
// (photo_downscale_io.dart) which returns null — there image_picker already
// downscales natively via maxWidth/imageQuality, so no canvas is needed.
// Callers treat null as "no re-encode available" and keep their original
// bytes (אין המצאות — never a fake image, never a silent drop).
export 'photo_downscale_io.dart'
    if (dart.library.js_interop) 'photo_downscale_web.dart';
