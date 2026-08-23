/// Throwaway DEMO entry for the RingDive dial (owner "show me live"). Mirrors
/// `_app_cardkeyboard_demo.dart`: a standalone `main` that renders ONLY the
/// RingDive surface so it can be viewed/interacted with before the swap seam
/// (P7) wires it into the real app. NOT reachable from the app's own `main` →
/// byte-identical to production. Run with:
///   flutter run -d web-server -t lib/_app_ringdive_demo.dart \
///     --dart-define=ENABLE_RING_DIVE=true
library;

import 'package:buildsmart/features/ring_dive/ring_dive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _RingDiveDemoApp()));
}

class _RingDiveDemoApp extends StatelessWidget {
  const _RingDiveDemoApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RingDive',
      home: Scaffold(
        backgroundColor: Color(0xFFF4EFE7),
        body: SafeArea(child: Center(child: RingDiveScreen())),
      ),
    );
  }
}
