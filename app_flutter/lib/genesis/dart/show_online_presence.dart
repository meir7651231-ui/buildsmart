// ⚛️ אטום-Dart (דרגת-חוזה) · showOnlinePresence
// מוצא: buildsmart/app_flutter/lib/screens/chats_screen.dart:229 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): ChatLastSeen.

enum ChatLastSeen { everyone, contacts, nobody }

/// "זמן מקוון אחרון" privacy: online presence is shown unless set to nobody.
bool showOnlinePresence(ChatLastSeen p) => p != ChatLastSeen.nobody;
