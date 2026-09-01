# חוזה · `contrastRatio` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:278-283`
(‏`_contrastRatio`, פרטי-במקור ⇒ public).

**שקע:** `Color.computeLuminance()` (בהירות-יחסית 0..1) הומר לשקע `luminanceOf` (חוק-3),
כדי שהאטום לא יתלה ב-dart:ui/Flutter. האטום גנרי על `T`.

## חתימה
```dart
double contrastRatio<T>(T a, T b, {required double Function(T) luminanceOf})
```

## קלט
- `a`, `b` — שני צבעים (T).
- `luminanceOf` — **שקע** (חוק-3): הבהירות-היחסית של צבע (0..1). במקור `c.computeLuminance()`.

## פלט / התנהגות (עוגני-שורה)
- `:279-280` — `la = luminanceOf(a)`, `lb = luminanceOf(b)`.
- `:281-282` — `hi = max(la,lb)`, `lo = min(la,lb)`.
- `:283` — `return (hi + 0.05) / (lo + 0.05)`.
- **תמיד ≥ 1.0** (‏hi≥lo); סימטרי (‏contrastRatio(a,b)==contrastRatio(b,a)).

## דוגמאות (‏luminanceOf = זהות על double)
| # | la | lb | ⇒ |
|---|----|----|---|
| 1 | 1.0 | 0.0 | `21.0` (לבן↔שחור, (1.05)/(0.05)) |
| 2 | 0.0 | 1.0 | `21.0` (סימטרי) |
| 3 | 0.5 | 0.5 | `1.0` (זהה) |
| 4 | 0.5 | 0.0 | `11.0` ((0.55)/(0.05)) |
| 5 | 0.0 | 0.0 | `1.0` ((0.05)/(0.05)) |

## שקעים
- `luminanceOf` — הזרקת-בהירות. הבדיקה מזריקה זהות על double.

## DoD
```
dart run --enable-asserts new/dart/contrast_ratio_test.dart  ⇒ exit 0 + "OK contrastRatio: N asserts passed"
```
