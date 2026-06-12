// Wiring guard for the REAL camera capture in `screens/camera_sheet.dart`
// (wave-3 de-mock). The capture sits behind the injectable
// [taskPhotoPickerProvider] seam (services/task_photo.dart), so we can drive
// the whole flow with a FAKE picker that returns a known data-URL — proving the
// wiring WITHOUT real hardware:
//
//   • a captured photo → confirm → the screen DELIVERS it (pops with the
//     data-URL) and a '📸 התמונה נקלטה' toast is shown;
//   • a user cancel (picker returns null) → a graceful NO-OP: the screen stays
//     open and nothing is delivered.
//
// Real-HARDWARE capture (an actual camera/photos pick) can only be confirmed on
// a device — that is an owner device-test item, NOT covered here.

import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 1x1 transparent PNG as a data-URL — the "known image" the fake delivers.
const String _kFakePhoto =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAA'
    'C0lEQVR42mNk+M8AAAMBAQDJ/pLvAAAAAElFTkSuQmCC';

/// The mobile_scanner platform channel — stubbed so the live [MobileScanner]
/// inside [CameraScreen] does not reach a real camera in the test harness
/// (every method returns a benign empty map; the scanner is not under test).
const MethodChannel _scannerChannel =
    MethodChannel('dev.steenbakker.mobile_scanner/scanner/method');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Dispatch by method with type-correct returns. We report the camera as
    // permission-denied so the scanner falls into its errorBuilder (the realistic
    // no-camera test path) instead of reaching real hardware; the bottom panel
    // (gallery strip + mode chips + shutter) is a Stack sibling and renders
    // regardless. The barcode scanner is not what this test exercises.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_scannerChannel, (call) async {
      switch (call.method) {
        case 'state':
          return 0; // undetermined
        case 'request':
          return false; // permission denied → errorBuilder
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_scannerChannel, null);
  });

  /// Pumps a host screen with a single "open camera" button, the picker seam
  /// overridden by [picker]. Returns once the host is on screen. The result
  /// delivered by [openCameraSheet] is recorded into [delivered].
  Future<void> pumpHost(
    WidgetTester t, {
    required TaskPhotoPicker picker,
    required List<String?> delivered,
    Size surface = const Size(440, 950),
  }) async {
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [taskPhotoPickerProvider.overrideWithValue(picker)],
        child: MaterialApp(
          locale: const Locale('he'),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    delivered.add(await openCameraSheet(ctx));
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await t.pump();
  }

  /// Opens the camera screen and switches to the non-barcode "לפני/אחרי" mode so
  /// the REAL shutter is visible (mode 0 = barcode shows no shutter).
  Future<void> openAndSelectPhotoMode(WidgetTester t) async {
    await t.tap(find.text('open'));
    // Avoid pumpAndSettle: the stubbed scanner may keep a pending future.
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));

    // The mode chip and the shutter share the label text; the chip is the one
    // we can tap to switch modes.
    await t.tap(find.text('לפני/אחרי').last);
    await t.pump(const Duration(milliseconds: 250));
  }

  testWidgets(
    'capture → confirm DELIVERS the real photo (pop with data-URL + toast)',
    (t) async {
      var calls = 0;
      final delivered = <String?>[];
      await pumpHost(
        t,
        delivered: delivered,
        picker: (_) async {
          calls++;
          return _kFakePhoto;
        },
      );

      await openAndSelectPhotoMode(t);

      // Tap the REAL shutter ('צלם לפני/אחרי').
      await t.tap(find.text('צלם לפני/אחרי'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));

      // The fake picker ran, and the confirm dialog is up with a preview.
      expect(calls, 1, reason: 'the injected picker seam was invoked');
      expect(find.text('📸 תצוגה מקדימה'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Confirm → the screen delivers the captured photo and pops.
      await t.tap(find.text('אישור'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));

      expect(
        delivered,
        [_kFakePhoto],
        reason: 'openCameraSheet must resolve to the captured data-URL',
      );
      expect(find.text('📸 התמונה נקלטה'), findsOneWidget);
      // Back on the host — the camera screen popped.
      expect(find.text('open'), findsOneWidget);
    },
  );

  testWidgets(
    'user cancel (picker returns null) → graceful NO-OP, nothing delivered',
    (t) async {
      var calls = 0;
      final delivered = <String?>[];
      await pumpHost(
        t,
        delivered: delivered,
        picker: (_) async {
          calls++;
          return null; // cancelled / unavailable
        },
      );

      await openAndSelectPhotoMode(t);

      await t.tap(find.text('צלם לפני/אחרי'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));

      expect(calls, 1, reason: 'the seam was still invoked');
      // No confirm dialog, no toast, no delivery — and still on the camera
      // screen (the shutter is still visible, the host button is not).
      expect(find.text('📸 תצוגה מקדימה'), findsNothing);
      expect(find.text('📸 התמונה נקלטה'), findsNothing);
      expect(delivered, isEmpty);
      expect(find.text('צלם לפני/אחרי'), findsOneWidget);
    },
  );

  testWidgets(
    'gallery "כל הגלריה" button is wired to the same real seam',
    (t) async {
      var calls = 0;
      final delivered = <String?>[];
      // A wide surface so the whole horizontal gallery strip — including its
      // trailing "כל הגלריה" button — fits without scrolling.
      await pumpHost(
        t,
        delivered: delivered,
        surface: const Size(1200, 950),
        picker: (_) async {
          calls++;
          return _kFakePhoto;
        },
      );

      // Stay in barcode mode (default) — the gallery strip is shown in every
      // mode. Open the camera, then tap the "כל הגלריה" picker button.
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));

      // The trailing "all" button — its label is a two-line Text node.
      final galleryAllBtn = find.text('כל\nהגלריה');
      expect(galleryAllBtn, findsOneWidget);
      await t.tap(galleryAllBtn);
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));

      expect(calls, 1, reason: 'the gallery button invokes the picker seam');
      expect(find.text('📸 תצוגה מקדימה'), findsOneWidget);

      await t.tap(find.text('אישור'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));

      expect(delivered, [_kFakePhoto]);
    },
  );
}
