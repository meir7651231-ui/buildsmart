// ✨ PremiumAvatar — אווטאר-פרימיום: name + size + status + image?. טבעת-קונכית (conic) סביב,
// מילוי-גרדיאנט דטרמיניסטי לפי-שם עם ראשי-תיבות, נקודת-סטטוס עם טבעת-רקע. תמונה אופציונלית
// גוברת. a11y: Semantics(image/label) · אין-צבע-לבד (טבעת). חוט-טהור: material+dart:math · RTL.
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AvatarStatus { none, online, away, busy }

class PremiumAvatar extends StatelessWidget {
  const PremiumAvatar({
    required this.name,
    this.size = 56,
    this.status = AvatarStatus.none,
    this.image,
    super.key,
  });

  final String name;
  final double size;
  final AvatarStatus status;
  final ImageProvider? image;

  // פלטת-גרדיאנטים דטרמיניסטית (נבחרת לפי-שם)
  static const List<List<Color>> _palettes = [
    [Color(0xFF7A6BFF), Color(0xFF5B4CE0)],
    [Color(0xFF39D6F0), Color(0xFF2A8CF0)],
    [Color(0xFFC66BFF), Color(0xFF8B3BE0)],
    [Color(0xFFFF8A5B), Color(0xFFE0563B)],
    [Color(0xFF34D399), Color(0xFF10A5A0)],
    [Color(0xFFF7B733), Color(0xFFE08C2A)],
  ];
  static const _online = Color(0xFF34D399);
  static const _away = Color(0xFFF7B733);
  static const _busy = Color(0xFFF87171);
  static const _ringLo = Color(0xFF5B4CE0);
  static const _ringHi = Color(0xFFC66BFF);
  static const _ringCyan = Color(0xFF39D6F0);

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  List<Color> get _palette {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _palettes[h % _palettes.length];
  }

  Color? get _statusColor {
    switch (status) {
      case AvatarStatus.online:
        return _online;
      case AvatarStatus.away:
        return _away;
      case AvatarStatus.busy:
        return _busy;
      case AvatarStatus.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = _palette;
    final inner = size - 6; // מקום לטבעת
    final face = Container(
      width: inner,
      height: inner,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: image == null
            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: pal)
            : null,
        image: image != null ? DecorationImage(image: image!, fit: BoxFit.cover) : null,
        boxShadow: [
          BoxShadow(color: pal.last.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: image == null
          ? Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: inner * 0.36,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            )
          : null,
    );

    final sc = _statusColor;
    return Semantics(
      image: image != null,
      label: name,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // טבעת-קונכית
            Positioned.fill(child: CustomPaint(painter: _AvatarRing())),
            Center(child: face),
            // נקודת-סטטוס
            if (sc != null)
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: sc,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF06060B), width: size * 0.05),
                    boxShadow: [BoxShadow(color: sc.withValues(alpha: 0.6), blurRadius: 6)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvatarRing extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1;
    final shader = const SweepGradient(
      colors: [
        PremiumAvatar._ringLo,
        PremiumAvatar._ringCyan,
        PremiumAvatar._ringHi,
        PremiumAvatar._ringLo,
      ],
      stops: [0, 0.4, 0.75, 1],
      transform: GradientRotation(-math.pi / 4),
    ).createShader(rect);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarRing old) => false;
}
