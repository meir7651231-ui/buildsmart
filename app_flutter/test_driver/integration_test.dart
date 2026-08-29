// Host-side driver for the Android emulator integration test. Writes each
// `binding.takeScreenshot(name)` from integration_test/ to screenshots/<name>.png
// so the CI workflow can upload it as a downloadable artifact (the on-device
// proof that the KB_GLOBAL keyboard renders on real Android).

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('screenshots/$name.png');
      await file.create(recursive: true);
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}
