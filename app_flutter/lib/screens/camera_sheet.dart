import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';

void openCameraSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CameraSheet(parentContext: context),
  );
}

// ─── mock gallery data ────────────────────────────────────────────────────────

const _kGallery = [
  (color: Color(0xFF2A3A2A), icon: Icons.construction,       label: 'אתר A'),
  (color: Color(0xFF3A2A2A), icon: Icons.inventory_2,        label: 'מלאי'),
  (color: Color(0xFF2A2A3A), icon: Icons.local_shipping,     label: 'משלוח'),
  (color: Color(0xFF3A3A2A), icon: Icons.handyman,           label: 'כלים'),
  (color: Color(0xFF2A3A3A), icon: Icons.assignment,         label: 'משימה'),
  (color: Color(0xFF3A2A3A), icon: Icons.storefront,         label: 'חנות'),
  (color: Color(0xFF2A2A2A), icon: Icons.photo_camera,       label: 'אחרונה'),
];

// ─── filter modes ─────────────────────────────────────────────────────────────

const _kFilters = [
  (emoji: '📷', label: 'סריקת ברקוד',    sub: 'EAN · QR · Code-128'),
  (emoji: '📸', label: 'לפני/אחרי',      sub: 'תיעוד אתר ועבודה'),
  (emoji: '📸', label: 'אישור מסירה',    sub: 'POD + חתימה'),
  (emoji: '🏷️', label: 'הפקת ברקודים',  sub: 'יצוא ברקוד לפריט'),
  (emoji: '📸', label: 'צילום משימה',    sub: 'שליחה לאישור מנהל'),
];

// ─── sheet ────────────────────────────────────────────────────────────────────

class _CameraSheet extends StatefulWidget {
  const _CameraSheet({required this.parentContext});
  final BuildContext parentContext;

  @override
  State<_CameraSheet> createState() => _CameraSheetState();
}

class _CameraSheetState extends State<_CameraSheet> {
  int _selectedFilter = 0;

  void _onFilterTap(int i) {
    setState(() => _selectedFilter = i);
    if (i == 0) {
      Navigator.pop(context);
      openBarcodeScanner(widget.parentContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grip
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Gallery row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'גלריה אחרונה',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _kGallery.length + 1, // +1 for "all photos" button
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == _kGallery.length) return _AllPhotosThumb(parentContext: widget.parentContext);
                final g = _kGallery[i];
                return _GalleryThumb(
                  color: g.color,
                  icon: g.icon,
                  label: g.label,
                  onTap: () => showToast(widget.parentContext, '${g.label} — בבנייה'),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 8),

          // ── Filters ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'מצב מצלמה',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ..._kFilters.asMap().entries.map((e) {
            final i = e.key;
            final f = e.value;
            final selected = _selectedFilter == i;
            return _FilterTile(
              emoji: f.emoji,
              label: f.label,
              sub: f.sub,
              selected: selected,
              onTap: () => _onFilterTap(i),
            );
          }),
        ],
      ),
    );
  }
}

// ─── gallery thumb ────────────────────────────────────────────────────────────

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 80,
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white54, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllPhotosThumb extends StatelessWidget {
  const _AllPhotosThumb({required this.parentContext});
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        showToast(parentContext, 'גלריה מלאה — בבנייה');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 80,
          color: const Color(0xFF222222),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, color: BsTokens.brand, size: 28),
              SizedBox(height: 6),
              Text('כל התמונות', style: TextStyle(color: BsTokens.brand, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── filter tile ──────────────────────────────────────────────────────────────

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected
            ? BsTokens.brand.withValues(alpha: 0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // LEFT — selected indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? BsTokens.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            // MIDDLE — label + sub
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? BsTokens.brand : Colors.white,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // RIGHT — emoji circle
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? BsTokens.brand.withValues(alpha: 0.15)
                    : const Color(0xFF2A2A2A),
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
