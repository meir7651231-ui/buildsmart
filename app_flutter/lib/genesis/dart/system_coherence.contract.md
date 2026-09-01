# חוזה · `systemCoherence` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_resolver.dart:391-409` (מתודת `systemCoherence` על `ConnectionResolver`; ענף `claude/align-main` — הענף היחיד הנושא את הקובץ).

## תפקיד
האם קו-מוצרים נשאר בתוך מערכת-מוסמכת **אחת** (plan addition B — למשל חלקי-אספקה לא מעורבבים בקו-ניקוז). קצוות נסרקים בסדר-הקו (specs בסדר, ends של כל spec בסדר); קצה שה-type שלו לא-מוכר או נושא systemId==null — מדולג. יותר ממערכת לא-null אחת ⇒ הקו לא-קוהרנטי.

## חתימה
```dart
SystemCoherence systemCoherence(List<ProductConnectorSpec> line, {
  required List<ConnectorType> connectorTypes,   // שקע: במקור שדה-constructor של ה-resolver
  required List<SystemDef> systems,              // שקע: במקור שדה-constructor של ה-resolver
})
// ProductConnectorSpec{productSku, ends:[ConnectorEnd{connectorTypeId}]} — מוטבע-מינימום
// ConnectorType{id, systemId?} — מוטבע-מינימום (connection_schema.dart:64-107; האטום קורא רק id+systemId)
// SystemDef{id, tradeId, nameHe, color} — מוטבע (connection_schema.dart:110-128); stored-only פרט ל-id
// SystemCoherence{coherent, offendingSystem?, offendingSku?} — verbatim (connection_resolver.dart:125-154, בלי ==/hashCode)
```

## התנהגות (עוגן connection_resolver.dart:391-409)
1. נבנים שני מילונים בסמנטיקת map-literal (כפילות-id ⇒ **האחרון מנצח**, עוגן 186-195):
   `systemIdByTypeId = {t.id: t.systemId}` · `systemById = {s.id: s}`.
2. סריקה: לכל spec בסדר-הקו, לכל end בסדרו — `sysId = systemIdByTypeId[end.connectorTypeId]`;
   `sysId == null` (type לא-מוכר **או** systemId==null) ⇒ `continue`.
3. ה-sysId הלא-null הראשון נקבע כ-`firstSystemId`; sysId שונה ממנו ⇒ מוחזר מיד
   `SystemCoherence(coherent:false, offendingSystem: systemById[sysId], offendingSku: spec.productSku)`
   — ה-sku ה**ראשון** בסדר-הקו הנושא קצה שונה-מערכת; `offendingSystem` = ה-SystemDef של המערכת **השונה**
   (null כשאינה ב-systems — הקו עדיין לא-קוהרנטי, עוגן 137-139, 402).
4. אחרת ⇒ `const SystemCoherence(coherent: true)` (offendingSystem/offendingSku = null).

## שקעים (הכרעת-הקידום: 🔌 שכן⇒שקע + ⚛️ הטבעת-טיפוס)
- `_systemIdByTypeId` / `_systemById` (שדות-מופע `late final`, נגזרי-constructor) ⇒ שקעי `connectorTypes` / `systems`; הגזירה (אותה סמנטיקת map-literal) עברה לגוף האטום.
- טיפוסי-שכן מ-connection_schema.dart ⇒ הוטבעו מינימלית (רק השדות הנקראים/מאוחסנים), בתבנית האח `completion.dart`.

## דוגמאות-מחייבות
קבועים: CTs = hot→sys.supply · cold→sys.supply · drain→sys.drain · loose→null; SYS = [sys.supply 'אספקה', sys.drain 'ניקוז'].
| # | line | הזרקות | ⇒ |
|---|------|--------|---|
| 1 | [] | CTs, SYS | coherent:true · nulls |
| 2 | P1(hot), P2(cold) | CTs, SYS | coherent:true (מערכת אחת) |
| 3 | P1(hot), P3(drain) | CTs, SYS | coherent:false · sku=P3 · system.id=sys.drain |
| 4 | P1(hot), PX(xx-לא-מוכר), P2(cold) | CTs, SYS | coherent:true (לא-מוכר מדולג) |
| 5 | P1(hot), PL(loose) | CTs, SYS | coherent:true (systemId=null מדולג) |
| 6 | P1(hot), P3(drain) | CTs, systems=[supply בלבד] | coherent:false · system=null · sku=P3 |
| 7 | PM(ends:[hot,drain]) | CTs, SYS | coherent:false · sku=PM · system.id=sys.drain |
| 8 | P3(drain), P1(hot) | CTs, SYS | coherent:false · sku=P1 · system.id=sys.supply (השונה, לא הראשונה) |
| 9 | P1(hot), P3(drain) | CTs+[hot→sys.drain כפול], SYS | coherent:true (האחרון-מנצח ⇒ שניהם drain) |
| 10 | PX(xx), PL(loose) | CTs, SYS | coherent:true (אפס מערכות שנראו) |

## DoD
```
dart run --enable-asserts new/dart/system_coherence_test.dart  ⇒ exit 0 + "OK systemCoherence: 10 asserts passed"
```
