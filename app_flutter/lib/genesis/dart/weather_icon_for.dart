// ⚛️ אטום-Dart (דרגת-חוזה) · weatherIconFor
// מוצא: buildsmart/app_flutter/lib/services/weather.dart:70-81 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core).
//
// קלט:  code — קוד-מזג-אוויר WMO.
// פלט:  אימוג'י (0 בהיר · 1-3 מעונן-חלקית · 45/48 ערפל · 51-67 גשם ·
//        71-77 שלג · 80-82 ממטרים · 95-99 סופה).

/// אימוג'י מזג-אוויר לפי קוד WMO [code]. טהור.
String weatherIconFor(int code) {
  if (code <= 0) return '☀️';
  if (code <= 3) return '⛅';
  if (code <= 48) return '🌫️';
  if (code <= 67) return '🌧️';
  if (code <= 77) return '❄️';
  if (code <= 82) return '🌦️';
  return '⛈️';
}
