# חוזה · normName
`String normName(String s, {required String Function(String) normSearch})`
מפתח-dedup הדוק: normSearch(s) + הסרת כל רווח. 'בן דוד' ≡ 'בןדוד'.
שקע: `normSearch` — נרמול-חיפוש עברי (lowercase · ניקוד · fold-סופיות · trim).
