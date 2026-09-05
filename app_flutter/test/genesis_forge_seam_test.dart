// תפר-הדאטה של אטומי-forge (GENMAX·G12a): null ⇒ תוכן-העיצוב (ביקורת-פיקסל) · רשימה ⇒ fields[i] או '' — לעולם לא תוכן-דמו (§20-ג)
import 'package:buildsmart/genesis/dart-forge-bs/dataviz/dataviz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ForgeStatBlock · ברירת-מחדל = תוכן-העיצוב (Label · 248 · 12% Meta)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ForgeStatBlock())));
    expect(ForgeStatBlock.fieldSlots, 3);
    expect(ForgeStatBlock.fieldDemo, ['Label', '248', '12% Meta']);
    expect(find.text('Label'), findsOneWidget); expect(find.text('248'), findsOneWidget);
  });
  testWidgets('ForgeStatBlock · fields מלאים ⇒ הערכים שלנו, אפס תוכן-דמו', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ForgeStatBlock(fields: ['תלמידים', '1,248', '14 בסיכון']))));
    expect(find.text('תלמידים'), findsOneWidget); expect(find.text('1,248'), findsOneWidget); expect(find.text('14 בסיכון'), findsOneWidget);
    expect(find.text('Label'), findsNothing); expect(find.text('248'), findsNothing); expect(find.text('12% Meta'), findsNothing);
  });
  testWidgets('ForgeStatBlock · fields חלקיים ⇒ חריץ-ריק, לא דמו', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ForgeStatBlock(fields: ['מורים']))));
    expect(find.text('מורים'), findsOneWidget); expect(find.text('248'), findsNothing); expect(find.text('12% Meta'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
