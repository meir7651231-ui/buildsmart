// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-מערכת. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_audit_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'package:flutter/material.dart';

class GenAppAuditScreen extends StatelessWidget {
  const GenAppAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_audit_c0,
      subtitle: gen_app_audit_c1,
      icon: gen_app_audit_c2,
      children: [
        DsSection(title: gen_app_audit_c3, children: [
        DsEmpty(label: gen_app_audit_c4),
        ]),
      ],
    );
  }
}
