# חוזה · isBrightImage
`bool isBrightImage(String? assetPath, {required int Function(String?) imageBrightness})`
תמונה שמישה (לא-שחורה): imageBrightness(assetPath) >= kDarkFloor(100).
שקע: `imageBrightness` — בהירות 0-255; null⇒-1; חסר⇒255.
