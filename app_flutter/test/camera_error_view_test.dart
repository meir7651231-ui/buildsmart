import 'package:buildsmart/widgets/camera_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the W1 camera black-screen fix (2026-06-08): the barcode/camera
/// scanners now render this view via `MobileScanner.errorBuilder` when the
/// camera can't start (permission denied / no camera), instead of a blank black
/// feed. Pins the user-approved copy.
void main() {
  testWidgets('shows the camera-permission message', (t) async {
    await t.pumpWidget(
      const MaterialApp(home: Builder(builder: cameraPermissionErrorView)),
    );
    expect(find.textContaining('לא ניתן לגשת למצלמה'), findsOneWidget);
    expect(find.textContaining('הרשאת-מצלמה'), findsOneWidget);
  });
}
