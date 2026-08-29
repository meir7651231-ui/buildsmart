/// חוט · to-csv — שורות⇒CSV+BOM. חוזה: to-csv.contract.md · שקע: escape
/// זהה-ביט ל-JS: BOM (U+FEFF) בראש · תאים ב-',' · שורות ב-'\n'.
dynamic toCsv(dynamic rows, dynamic escape) {
  return '﻿' +
      rows.map((r) => r.map(escape).join(',')).join('\n');
}
