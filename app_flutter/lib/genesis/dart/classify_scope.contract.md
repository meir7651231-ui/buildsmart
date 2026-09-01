# חוזה · `classifyScope` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:147-167`.

## תפקיד
מסווג reply של מודל ל-scope-סטודיו: token-רחב/מרחבי (‏`scope:` מקודם) מוקדם, אחרת `scope:single:<id>` על id-אמת בלבד, אחרת null (fail-closed → הבהרה). לעולם לא scope-מנוחש.

## חתימה
```dart
String? classifyScope(String reply, {
  required List<String> scopeTokens,
  required List<String> registryIds,
  required String scopeSinglePrefix,
  required String? Function(Iterable<String> ids, String reply) matchId,
})
```

## התנהגות (עוגן edit_prompt.dart:147-167)
1. `r = reply.trim()`; ריק ⇒ null.
2. `t = matchId(scopeTokens, r)`; ≠null ⇒ מחזיר t.
3. `r.contains(scopeSinglePrefix)` ⇒ `id = matchId(registryIds, r)`; ≠null ⇒ מחזיר `'$scopeSinglePrefix$id'`.
4. אחרת ⇒ null.

## שקעים
- `scopeTokens` — `studioScopeTokens(registry)` ⇒ שקע.
- `registryIds` — `registry.elementIds()` (יעד הקריאה-2 ל-matchElementId) ⇒ שקע.
- `matchId(ids, reply)` — `matchElementId(view, reply)`: trim, ריק→null, exact-קודם, אחרת ה-key הכי-ארוך המוכל, מדלג key ריק ⇒ שקע-פונקציה.
- `scopeSinglePrefix` — const `kScopeSinglePrefix` ⇒ שקע.
- RegistryView/FakeRegistryView נבלעו לשקעים.

## דוגמאות-מחייבות (tokens=[scope:all, scope:screen:home, scope:screen:cart]; ids=[btn_save, btn_cancel, lbl_title]; prefix='scope:single:')
| # | reply | ⇒ |
|---|-------|---|
| 1 | '   ' | null |
| 2 | 'scope:all' | 'scope:all' |
| 3 | 'בבקשה scope:screen:home את המסך' | 'scope:screen:home' |
| 4 | 'scope:single:btn_save' | 'scope:single:btn_save' |
| 5 | 'scope:single:ghost' | null (id לא-אמת) |
| 6 | 'install the sink please' | null |
| 7 | '  scope:all  ' | 'scope:all' (trim) |
| 8 | 'scope:screen:cart' | 'scope:screen:cart' |

## DoD
```
dart run --enable-asserts new/dart/classify_scope_test.dart  ⇒ exit 0 + "OK classifyScope: 8 asserts passed"
```
