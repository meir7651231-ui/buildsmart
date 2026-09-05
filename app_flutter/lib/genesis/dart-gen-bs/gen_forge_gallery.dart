// 🖼️ ראווה — אטומים שחושלו ע"י pure-forge (מהמקור HTML), עטופים ב-PureScope. אפס-ציור-יד.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/forged/forged_list.dart';
import '../dart-ui-bs/forged/forged_status.dart';
import '../dart-ui-bs/forged/forged_nav.dart';
import '../dart-ui-bs/forged/forged_text.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: DsPure.canvas, brightness: Brightness.dark),
        builder: (c, ch) => Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        home: PureScope(
          theme: DsPure.indigo,
          child: Scaffold(
            backgroundColor: DsPure.canvas,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('PURE-FORGE · אטומים שחושלו מה-HTML',
                      style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, letterSpacing: 2, color: DsPure.skin.mut)),
                  const SizedBox(height: 14),
                  const ForgedList(), const SizedBox(height: 16),
                  const ForgedStatus(), const SizedBox(height: 16),
                  const ForgedNav(), const SizedBox(height: 16),
                  const ForgedText(),
                ]),
              ),
            ),
          ),
        ),
      );
}
