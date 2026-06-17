// Golden snapshots of the REAL BsKeyboard widget, rendered by Flutter with the
// app's actual Heebo font — a true picture of the built code (not a mockup).
// Regenerate with:  flutter test --update-goldens test/smart_input/keyboard/kb_golden_test.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadHeebo() async {
  final loader = FontLoader('Heebo')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-Bold.ttf'));
  await loader.load();
}

// Material Icons aren't loaded by the test renderer by default, so icon keys
// (backspace / send / globe / enter) would render as tofu boxes. Load the real
// icon font from the Flutter cache so the snapshot matches the running app.
Future<void> _loadIcons() async {
  const path =
      'C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

Widget _frame(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFFECE5DD),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 390, child: child),
        ),
      ),
    );

BsKeyboard _kb({bool english = false, bool showSymbols = false}) => BsKeyboard(
      onKey: (_) {},
      onBackspace: () {},
      onEnter: () {},
      onSend: () {},
      onToggleSymbols: () {},
      onLanguage: () {},
      english: english,
      showSymbols: showSymbols,
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadHeebo();
    await _loadIcons();
  });

  testWidgets('golden: Hebrew layer', (t) async {
    await t.pumpWidget(_frame(_kb()));
    await t.pumpAndSettle();
    await expectLater(
      find.byType(BsKeyboard),
      matchesGoldenFile('goldens/kb_hebrew.png'),
    );
  });

  testWidgets('golden: English layer', (t) async {
    await t.pumpWidget(_frame(_kb(english: true)));
    await t.pumpAndSettle();
    await expectLater(
      find.byType(BsKeyboard),
      matchesGoldenFile('goldens/kb_english.png'),
    );
  });

  testWidgets('golden: symbols (?123) layer', (t) async {
    await t.pumpWidget(_frame(_kb(showSymbols: true)));
    await t.pumpAndSettle();
    await expectLater(
      find.byType(BsKeyboard),
      matchesGoldenFile('goldens/kb_symbols.png'),
    );
  });

  testWidgets('golden: full — suggestion strip + keyboard', (t) async {
    final full = RepaintBoundary(
      key: const Key('full'),
      child: ColoredBox(
        color: const Color(0xFFECE5DD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'מוכן ל',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 15, color: Color(0xFF1F2024)),
              ),
            ),
            ColoredBox(
              color: const Color(0xFFF7F7F9),
              child: SmartChipStrip(
                suggestions: const [
                  Suggestion('מוכן לאיסוף', isPrimary: true),
                  Suggestion('אאסוף ב-14:00'),
                  Suggestion('BS-1041'),
                ],
                onPick: (_) {},
              ),
            ),
            _kb(),
          ],
        ),
      ),
    );
    await t.pumpWidget(_frame(full));
    await t.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('full')),
      matchesGoldenFile('goldens/kb_full.png'),
    );
  });
}
