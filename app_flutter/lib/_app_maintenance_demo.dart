/// DEMO entry for the maintenance & purchasing module (אחזקה ורכש).
/// Standalone `main` rendering ONLY the module — NOT reachable from the app's
/// own `main`, so production is byte-identical. Run / build with:
///   flutter run -d web-server -t lib/_app_maintenance_demo.dart
///   flutter build web -t lib/_app_maintenance_demo.dart
library;

import 'package:buildsmart/features/maintenance/mx_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MxApp()));
}
