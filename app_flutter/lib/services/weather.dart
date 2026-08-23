import 'dart:convert';

import 'package:buildsmart/logic/ai_hub_logic.dart' show WeatherDay, kWeather;
import 'package:buildsmart/services/geo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// #45 — REAL weather forecast from Open-Meteo (free, NO API key) for the AI-hub
/// weather-automation tool, located by the device GPS (#100, [currentGeoFix]).
/// Replaces the hardcoded [kWeather] seed; on no-GPS / network / parse failure
/// it falls back to that seed honestly — never a blank screen or a crash.
/// (Schedule-automation off the forecast is a later, owner-confirmed step.)

/// Injectable JSON GET — the test seam. Default hits Open-Meteo over https.
typedef WeatherHttpGet = Future<Map<String, dynamic>> Function(Uri url);

Future<Map<String, dynamic>> _httpGetJson(Uri url) async {
  final res = await http.get(url);
  return jsonDecode(res.body) as Map<String, dynamic>;
}

/// Fetch the next-4-days daily forecast for [lat]/[lon] from Open-Meteo.
Future<Map<String, dynamic>> fetchOpenMeteoDaily({
  required double lat,
  required double lon,
  WeatherHttpGet? get,
}) {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$lat&longitude=$lon'
    '&daily=weather_code,temperature_2m_max'
    '&timezone=auto&forecast_days=4',
  );
  return (get ?? _httpGetJson)(url);
}

/// PURE — Open-Meteo daily JSON → up to 4 [WeatherDay]. Maps the WMO
/// `weather_code` to an emoji + a Hebrew work-scheduling note; tolerant of a
/// short/absent/malformed array (returns what it can, never throws).
List<WeatherDay> weatherDaysFromOpenMeteo(Map<String, dynamic> json) {
  final daily = json['daily'];
  if (daily is! Map) return const [];
  final times = (daily['time'] as List?) ?? const [];
  final codes = (daily['weather_code'] as List?) ?? const [];
  final temps = (daily['temperature_2m_max'] as List?) ?? const [];
  final out = <WeatherDay>[];
  for (var i = 0; i < times.length && i < 4; i++) {
    final code =
        (i < codes.length && codes[i] is num) ? (codes[i] as num).toInt() : 0;
    final t = (i < temps.length && temps[i] is num) ? temps[i] as num : null;
    out.add(WeatherDay(
      day: _dayLabel(i),
      ic: weatherIconFor(code),
      temp: t == null ? '—' : '${t.round()}°',
      note: weatherNoteFor(code),
    ));
  }
  return out;
}

String _dayLabel(int i) => switch (i) {
      0 => 'היום',
      1 => 'מחר',
      2 => 'מחרתיים',
      _ => 'בעוד $i ימים',
    };

/// WMO `weather_code` → emoji (0 clear · 1-3 partly · 45/48 fog · 51-67 rain ·
/// 71-77 snow · 80-82 showers · 95-99 thunder).
String weatherIconFor(int code) {
  if (code <= 0) return '☀️';
  if (code <= 3) return '⛅';
  if (code <= 48) return '🌫️';
  if (code <= 67) return '🌧️';
  if (code <= 77) return '❄️';
  if (code <= 82) return '🌦️';
  return '⛈️';
}

/// WMO `weather_code` → a Hebrew work-scheduling note. Rain/snow/showers/storm
/// carry a ⚠️ so the hub flags the day ([WeatherDay.warn] keys off ⚠️).
String weatherNoteFor(int code) {
  if (code <= 3) return 'מזג אוויר טוב לעבודות חוץ';
  if (code <= 48) return 'ערפל — זהירות בנהיגה לאתר';
  if (code <= 67) return '⚠️ גשם — לדחות יציקות בטון';
  if (code <= 77) return '⚠️ שלג — עבודות פנים בלבד';
  if (code <= 82) return '⚠️ ממטרים — עבודות גמר בלבד';
  return '⚠️ סופה — להימנע מעבודות חוץ';
}

/// The hub's live forecast: GPS → Open-Meteo → mapped days; falls back to the
/// honest [kWeather] seed when GPS or the network is unavailable.
final weatherForecastProvider = FutureProvider<List<WeatherDay>>((ref) async {
  final fix = await currentGeoFix();
  if (fix == null) return kWeather;
  try {
    final json = await fetchOpenMeteoDaily(lat: fix.lat, lon: fix.lng);
    final days = weatherDaysFromOpenMeteo(json);
    return days.isEmpty ? kWeather : days;
  } on Object catch (_) {
    return kWeather;
  }
});
