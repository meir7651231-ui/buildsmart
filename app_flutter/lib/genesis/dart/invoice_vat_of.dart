// ⚛️ אטום-Dart (דרגת-חוזה) · invoiceVatOf
// תפקיד: חילוץ רכיב-המע"מ מסכום-ברוטו (כולל-מע"מ), לאחור: ברוטו − round(ברוטו/(1+שיעור)).
// מוצא: buildsmart/app_flutter/lib/logic/invoice.dart:19-44 (‏invoiceVatOf; חוק-4 — verbatim-נוסחה).
//        ⚠️ קובץ-המקור נמחק מהעץ-החי (find ריק 2026-08-26) — הטיוטה במחצב היא מקור-האמת.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). ה-const `kVatRate` **אינו-בר-שחזור**
//        (הקובץ נמחק · grep ריק) ⇒ הוסקק כ-`vatRate` במקום זיוף-ערך (דיבר-9). `double.round` = שפה/סטנדרט.
//        האח buildInvoiceRows (:20-44) — לא נקרא ⇒ לא-הוטבע.
//
// קלט:  grossTotal — סכום ברוטו כולל-מע"מ (int, אגורות/שקלים לפי-הקורא).
//        vatRate    — שקע: שיעור-המע"מ (double, כשבר; במקור const kVatRate בלתי-בר-שחזור).
// פלט:  int — רכיב-המע"מ = grossTotal − (grossTotal / (1 + vatRate)).round().

/// VAT component extracted backwards from a gross (VAT-inclusive) total.
/// Verbatim formula of invoice.dart, with kVatRate injected as `vatRate`
/// (law-3/דיבר-9; the const's source file was deleted upstream).
int invoiceVatOf(int grossTotal, {required double vatRate}) =>
    grossTotal - (grossTotal / (1 + vatRate)).round();
