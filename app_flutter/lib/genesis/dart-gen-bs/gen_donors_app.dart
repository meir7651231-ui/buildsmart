// 🖼️ רתמת-הרצה (חוק-7 · שחזור-עם-דאטה) — מלבישה את המסך-המחולל gen_donors בנתוני-תורם לדוגמה
// ומריצה אותו כאפליקציה. הדאטה כאן = הזרקת-לוח (stub); המסך עצמו נגזר מהמשפט דרך generate.mjs.
import 'package:flutter/material.dart';
import '../dart-screens-bs/gen_donors.g.dart';

void main() => runApp(const _DonorsApp());

class _DonorsApp extends StatelessWidget {
  const _DonorsApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Heebo',
          scaffoldBackgroundColor: const Color(0xFF0C0C0E), // DsPure.canvas — שחור-חמים (העיצוב החדש)
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7A6BF0), brightness: Brightness.dark),
        ),
        builder: (c, ch) => Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        home: Scaffold(
          backgroundColor: const Color(0xFF0C0C0E),
          appBar: AppBar(title: const Text('תורמים ותרומות'), centerTitle: true, backgroundColor: const Color(0xFF151517)),
          body: GenDonorsComposed(
            onTap: () {},
            validator: (v) => null,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('כרטיס תורם — משפחת כהן', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            controller: TextEditingController(),
            name: 'משפחת כהן · ירושלים',
            number: false,
            value: '₪ 1,250',
            t: const GenDonorsTokens(),
          ),
        ),
      );
}
