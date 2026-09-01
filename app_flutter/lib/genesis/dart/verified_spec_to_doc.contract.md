# חוזה · `verifiedSpecToDoc`

מוצא: `buildsmart/app_flutter/lib/data/repositories/verified_spec_seed.dart:33-49`.

`Map<String, dynamic> verifiedSpecToDoc(VerifiedSpec s)` — שדה-מפה של `verified_specs/{sku}`.

- `ends` → `[{type: <EndType.name>, size}]`; `maxTempC` מספר.
- `pressureRating`/`pexType`/`systemOverride` נכתבים רק כשלא-null (`systemOverride` כ-`.name`).
- טיפוסי-שכן מוטבעים: `EndType`, `WaterSystem` (enums), `ConnectorEnd` (type,size), `VerifiedSpec` (השדות הנקראים).
- Map רגילה — בלי Firestore/Timestamp. טהור, אפס import.
