// ⚛️ אטום-Dart (דרגת-חוזה) · isOwnerEmail
// מוצא: buildsmart/app_flutter/lib/data/board_accounts_local.dart:102-104 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: האם כתובת-המייל שייכת לבעלים המורשים.

/// True when [email] (trimmed, case-insensitive) is an owner account allowed to
/// enter the manager board. Pure → unit-testable.
bool isOwnerEmail(String? email, {required Set<String> kOwnerEmails}) =>
    email != null && kOwnerEmails.contains(email.trim().toLowerCase());
