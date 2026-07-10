import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbSuppliersNodes;
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SuppliersScreen());

  static final List<KbToolNode> _kbNodes = kbSuppliersNodes();

  @override
  Widget build(BuildContext context) {
    final Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: BsTokens.inkLight,
          elevation: 0,
          title: const CfgText(
            'suppliers_screen.title',
            'ספקים ומותגים',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          children: [
            _SupplierTile(
              emoji: '🏭',
              title: 'ליפסקי ברקן',
              subtitle: 'אינסטלציה וסניטציה • 66 מוצרים',
              onTap: () => Navigator.push(context, LipskeyBrandScreen.route()),
            ),
          ],
        ),
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}
