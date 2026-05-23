import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';

/// Opens the camera bottom sheet.
void openCameraSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CameraSheet(parentContext: context),
  );
}

// ─── sheet ────────────────────────────────────────────────────────────────────

class _CameraSheet extends StatelessWidget {
  const _CameraSheet({required this.parentContext});
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grip
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gallery pick — prominent row at top
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  showToast(parentContext, 'בחירה מהגלריה — בבנייה');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // LEFT (end in RTL) — chevron
                      Icon(Icons.chevron_left, color: Colors.white38, size: 20),
                      Spacer(),
                      // RIGHT (start in RTL) — label + icon
                      Text(
                        'בחירה מהגלריה',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.photo_library_outlined,
                          color: BsTokens.brand, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 4),

          // Camera options
          _CameraTile(
            emoji: '📷',
            title: 'סריקת ברקוד',
            subtitle: 'EAN · Code-128 · QR',
            onTap: () {
              Navigator.pop(context);
              openBarcodeScanner(parentContext);
            },
          ),
          _CameraTile(
            emoji: '📸',
            title: 'צילום לפני/אחרי',
            subtitle: 'תיעוד אתר ועבודה',
            onTap: () {
              Navigator.pop(context);
              showToast(parentContext, 'צילום לפני/אחרי — בבנייה');
            },
          ),
          _CameraTile(
            emoji: '📸',
            title: 'אישור מסירה',
            subtitle: 'POD + חתימה דיגיטלית',
            onTap: () {
              Navigator.pop(context);
              showToast(parentContext, 'אישור מסירה — בבנייה');
            },
          ),
          _CameraTile(
            emoji: '🏷️',
            title: 'הפקת ברקודים',
            subtitle: 'יצוא ברקוד לפריט',
            onTap: () {
              Navigator.pop(context);
              showToast(parentContext, 'הפקת ברקודים — בבנייה');
            },
          ),
          _CameraTile(
            emoji: '📸',
            title: 'צילום משימה',
            subtitle: 'שליחה לאישור מנהל',
            onTap: () {
              Navigator.pop(context);
              showToast(parentContext, 'צילום משימה — בבנייה');
            },
          ),
        ],
      ),
    );
  }
}

// ─── tile ─────────────────────────────────────────────────────────────────────

class _CameraTile extends StatelessWidget {
  const _CameraTile({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // LEFT — chevron
            const Icon(Icons.chevron_left, color: Colors.white24, size: 18),
            const Spacer(),
            // MIDDLE — title + subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // RIGHT — emoji circle
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
