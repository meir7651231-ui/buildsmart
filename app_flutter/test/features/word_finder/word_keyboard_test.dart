import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordKeyboard', () {
    testWidgets('renders each word as a plain, icon-free key', (tester) async {
      WordKey? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [
                WordKey('ברז'),
                WordKey('צינור'),
                WordKey('אטם'),
              ],
              onWordTap: (w) => tapped = w,
            ),
          ),
        ),
      );

      // The Hebrew word renders as text on its key.
      expect(find.text('ברז'), findsOneWidget);
      expect(find.text('צינור'), findsOneWidget);
      expect(find.text('אטם'), findsOneWidget);

      // No key — word keys nor the utility row — renders an Icon.
      expect(find.byType(Icon), findsNothing);

      // Tapping a word routes that exact WordKey to onWordTap.
      await tester.tap(find.text('ברז'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.label, 'ברז');
    });

    testWidgets('utility row exposes הכל and הקלדה without icons', (tester) async {
      var allTapped = false;
      var typeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [WordKey('ברז')],
              onWordTap: (_) {},
              onAll: () => allTapped = true,
              onType: () => typeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('הכל'), findsOneWidget);
      expect(find.text('הקלדה'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);

      await tester.tap(find.text('הכל'));
      await tester.pump();
      expect(allTapped, isTrue);

      await tester.tap(find.text('הקלדה'));
      await tester.pump();
      expect(typeTapped, isTrue);
    });

    testWidgets(
        'showUtilityRow:false omits the הכל/הקלדה row but keeps word keys',
        (tester) async {
      WordKey? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [
                WordKey('ברז', payload: '111'),
                WordKey('צינור', payload: '222'),
              ],
              onWordTap: (w) => tapped = w,
              showUtilityRow: false,
            ),
          ),
        ),
      );

      // The word keys still render (the connections view shows its parts)...
      expect(find.text('ברז'), findsOneWidget);
      expect(find.text('צינור'), findsOneWidget);
      // ...but neither utility key is present — they would be dead no-ops on a
      // surface (the connections view) with no skip/type affordance.
      expect(find.text('הכל'), findsNothing,
          reason: 'showUtilityRow:false must not render the הכל key');
      expect(find.text('הקלדה'), findsNothing,
          reason: 'showUtilityRow:false must not render the הקלדה key');
      // Still icon-free, and word taps still route by identity (payload intact).
      expect(find.byType(Icon), findsNothing);
      await tester.tap(find.text('צינור'));
      await tester.pump();
      expect(tapped, isNotNull);
      expect(tapped!.payload, '222',
          reason: 'a tapped word key still routes with its payload');
    });

    testWidgets('showUtilityRow defaults true → utility row present',
        (tester) async {
      // Explicit default-preservation guard: omitting showUtilityRow keeps the
      // existing behavior for every current call site.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [WordKey('ברז')],
              onWordTap: (_) {},
              onAll: () {},
              onType: () {},
            ),
          ),
        ),
      );
      expect(find.text('הכל'), findsOneWidget);
      expect(find.text('הקלדה'), findsOneWidget);
    });

    testWidgets(
        'a WordKey WITH imageAsset renders an Image inside its BsKey; one '
        'WITHOUT stays clean (no Image)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              // First key carries a (fake) product-thumbnail asset; the second
              // is a plain word key with no image. We never load real bytes —
              // the asset fails to decode and BsKey's errorBuilder collapses the
              // paint to SizedBox.shrink — but the Image WIDGET stays mounted,
              // so a resilient find.byType(Image) presence check still sees it.
              words: const [
                WordKey('מחסום', payload: '111', imageAsset: 'assets/x.png'),
                WordKey('צינור', payload: '222'),
              ],
              onWordTap: (_) {},
              // No utility row → the only keys are the two product/word keys,
              // so an Image count is unambiguous.
              showUtilityRow: false,
            ),
          ),
        ),
      );

      // Both labels still render as plain text (the thumbnail is LEADING the
      // text, the text is untouched — so text-based finds keep working).
      expect(find.text('מחסום'), findsOneWidget);
      expect(find.text('צינור'), findsOneWidget);

      // Exactly ONE Image is present — the one key that supplied an imageAsset.
      // The plain word key renders NO Image (word/chip keys stay clean).
      expect(find.byType(Image), findsOneWidget,
          reason: 'only the key with imageAsset renders an Image');

      // And that Image lives INSIDE the keyed BsKey (the one showing מחסום),
      // not the plain one — a structural guard that the thumbnail attaches to
      // the right key.
      final keyedBsKey = find.widgetWithText(BsKey, 'מחסום');
      expect(keyedBsKey, findsOneWidget);
      expect(
        find.descendant(of: keyedBsKey, matching: find.byType(Image)),
        findsOneWidget,
        reason: 'the thumbnail Image is a descendant of the imageAsset key',
      );
      final plainBsKey = find.widgetWithText(BsKey, 'צינור');
      expect(
        find.descendant(of: plainBsKey, matching: find.byType(Image)),
        findsNothing,
        reason: 'a WordKey without imageAsset renders no Image — stays clean',
      );
    });

    testWidgets(
        'word keys without imageAsset render NO Image at all (clean by default)',
        (tester) async {
      // The default path: no key supplies an imageAsset → the keyboard is
      // entirely Image-free, exactly as before the thumbnail feature.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [
                WordKey('ברז'),
                WordKey('צינור'),
                WordKey('אטם'),
              ],
              onWordTap: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing,
          reason: 'with no imageAsset anywhere the keyboard stays image-free '
              '(full backward compatibility)');
    });

    testWidgets(
        'a thumbnail resolves through the app CDN resolver (ResizeImage over a '
        'non-AssetImage provider), NOT a raw bundled Image.asset', (tester) async {
      // REGRESSION GUARD: the product crops are NOT bundled — they stream from
      // the R2 CDN via resolveProductImage. A raw Image.asset would silently
      // collapse to nothing in a release build. Assert the thumbnail is an
      // Image whose provider is a ResizeImage memory cap wrapping a NON-asset
      // (network) provider — so a revert to Image.asset is caught here.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [
                WordKey('מחסום',
                    payload: '111',
                    imageAsset: 'assets/lipskey/products/x.jpeg'),
              ],
              onWordTap: (_) {},
              showUtilityRow: false,
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<ResizeImage>(),
          reason: 'a raw Image.asset would expose an AssetImage directly; the '
              'thumbnail must cap decode memory via ResizeImage');
      final inner = (image.image as ResizeImage).imageProvider;
      expect(inner, isNot(isA<AssetImage>()),
          reason: 'under the default CDN base the crop resolves to a '
              'network-backed provider, never a bundled AssetImage (the '
              'resolver-bypass regression)');
    });

    testWidgets(
        'a long label beside a thumbnail does not overflow a narrow key',
        (tester) async {
      // OVERFLOW GUARD: a long distinct label (quickLabel + suffixes) beside a
      // 32px thumbnail must wrap/ellipsis, not blow the key width. Constrain a
      // 3-column row hard (~110px per key, a narrow phone) and assert no
      // RenderFlex overflow exception is thrown.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 330,
                child: WordKeyboard(
                  words: const [
                    WordKey('ברז יחיד שחור גדול מאוד (2)',
                        payload: '1',
                        imageAsset: 'assets/lipskey/products/x.jpeg'),
                    WordKey('מסעף כפול ארוך נחושת (3)',
                        payload: '2',
                        imageAsset: 'assets/lipskey/products/y.jpeg'),
                    WordKey('זרוע דוש מאריך נחושת 100', payload: '3'),
                  ],
                  onWordTap: (_) {},
                  showUtilityRow: false,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull,
          reason: 'Flexible + maxLines:2 + ellipsis must prevent RenderFlex '
              'overflow on a long label beside a thumbnail in a narrow key');
    });
  });
}
