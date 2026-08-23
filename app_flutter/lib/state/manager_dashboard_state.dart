import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which of the manager dashboard's four top tabs is active.
/// 0 = 📊 לוח בקרה · 1 = 🚚 הזמנות · 2 = 👥 לקוחות · 3 = 🛠️ ניהול.
///
/// The dashboard SHELL drives an `IndexedStack` off this provider; all four tab
/// bodies are live and complete (M2–M5). Mirrors the segmented-toggle provider
/// shape used by the merged "עדכונים" tab (`updatesSubTabProvider`).
final managerTabProvider = StateProvider<int>((_) => 0);
