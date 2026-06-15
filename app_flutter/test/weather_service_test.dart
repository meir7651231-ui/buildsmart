// #45 — Open-Meteo → WeatherDay mapping (pure, no network). The AI-hub weather
// tool renders real forecast from the device GPS; this pins the WMO weather_code
// → emoji/note/temp transform that turns the API payload into work guidance.
import 'package:buildsmart/services/weather.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weatherDaysFromOpenMeteo maps WMO codes → icon/note/temp (#45)', () {
    final json = <String, dynamic>{
      'daily': {
        'time': ['2026-06-16', '2026-06-17', '2026-06-18', '2026-06-19'],
        'weather_code': [0, 3, 61, 95],
        'temperature_2m_max': [31.4, 28.0, 19.2, 17.0],
      },
    };
    final days = weatherDaysFromOpenMeteo(json);
    expect(days, hasLength(4));
    expect(days[0].ic, '☀️');
    expect(days[0].temp, '31°', reason: '31.4 rounds to 31');
    expect(days[0].warn, isFalse);
    expect(days[1].ic, '⛅');
    expect(days[2].ic, '🌧️');
    expect(days[2].warn, isTrue, reason: 'rain (code 61) flags a ⚠️ note');
    expect(days[3].ic, '⛈️');
    expect(days[3].warn, isTrue, reason: 'thunderstorm (95) flags a ⚠️ note');
  });

  test('icon + note thresholds (#45)', () {
    expect(weatherIconFor(0), '☀️');
    expect(weatherIconFor(61), '🌧️');
    expect(weatherIconFor(95), '⛈️');
    expect(weatherNoteFor(61).contains('⚠️'), isTrue);
    expect(weatherNoteFor(0).contains('⚠️'), isFalse);
  });

  test('tolerant of malformed / empty payloads — never throws (#45)', () {
    expect(weatherDaysFromOpenMeteo(const {}), isEmpty);
    expect(weatherDaysFromOpenMeteo(const {'daily': 'nope'}), isEmpty);
    expect(
      weatherDaysFromOpenMeteo(const {
        'daily': {'time': [], 'weather_code': [], 'temperature_2m_max': []},
      }),
      isEmpty,
    );
  });
}
