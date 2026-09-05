// חוט · maps-route-url — מסלול רב-עצירות Google Maps. חוזה: maps-route-url.contract.md
// המרה מ-JS (new/atoms/maps-route-url.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// Uri.encodeComponent ≡ JS encodeURIComponent (אומת: RTL/space/פסיק זהים). אפס-import (dart-core בלבד).
// העוזר הפרטי cleanStop שוקע פנימה — אינו אטום נפרד (זהה למקור).

String? mapsRouteUrl(List<String> stops) {
  // ניקוי עצירה: '|' ליטרלי = מפריד-העצירות של Google ⇒ מוחלף ברווח, ואז trim.
  String cleanStop(String s) => s.replaceAll('|', ' ').trim();
  // filter(Boolean) של JS מסיר מחרוזות-ריקות (falsy) ⇒ isNotEmpty.
  final clean = stops.map(cleanStop).where((s) => s.isNotEmpty).toList();
  if (clean.isEmpty) return null;
  if (clean.length == 1) {
    return 'https://www.google.com/maps/search/?api=1&query=' +
        Uri.encodeComponent(clean[0]);
  }
  final destination = clean[clean.length - 1];
  final waypoints = clean.sublist(0, clean.length - 1);
  return 'https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=' +
      Uri.encodeComponent(destination) +
      '&waypoints=' +
      waypoints.map(Uri.encodeComponent).join('%7C');
}
