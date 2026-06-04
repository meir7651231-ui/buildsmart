import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which of the manager dashboard's four top tabs is active.
/// 0 = 📊 לוח בקרה · 1 = 🚚 הזמנות · 2 = 👥 לקוחות · 3 = 🛠️ ניהול.
///
/// The dashboard SHELL (M1) drives an `IndexedStack` off this provider; the four
/// tab bodies are PLACEHOLDERS this wave (M2–M5 fill them with the real manager
/// content). Mirrors the segmented-toggle provider shape used by the merged
/// "עדכונים" tab (`updatesSubTabProvider`).
final managerTabProvider = StateProvider<int>((_) => 0);
