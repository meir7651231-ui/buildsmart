// Compact horizontal flow diagram for a plumbing chain. Renders each product
// as a node and each adjacent-pair connection as a colored edge labelled by
// joint type (thread/press/compression). Materials get a coloured stripe on
// the node so the user can see the system at a glance.
//
// Built as a CustomPaint widget so it scrolls horizontally and stays
// performant for chains of 20+ products without rebuilding a widget tree
// per item.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter/material.dart';

class ChainDiagram extends StatelessWidget {
  const ChainDiagram({
    super.key,
    required this.chain,
    this.bottleneckSku,
    this.height = 96,
    this.nodeSize = 64,
    this.gap = 56,
  });

  /// The product sequence to render (left → right in RTL becomes right → left
  /// because the widget hosts a horizontal ListView).
  final List<LipskeyCatalogProduct> chain;

  /// When provided, the matching node is drawn with a red warning ring so the
  /// user can see at a glance which product is throttling the flow.
  final String? bottleneckSku;

  final double height;
  final double nodeSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (chain.length < 2) return const SizedBox.shrink();
    final width = chain.length * nodeSize + (chain.length - 1) * gap + 24;
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        reverse: true, // start from the right (RTL)
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _ChainPainter(
              chain: chain,
              bottleneckSku: bottleneckSku,
              nodeSize: nodeSize,
              gap: gap,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChainPainter extends CustomPainter {
  _ChainPainter({
    required this.chain,
    required this.bottleneckSku,
    required this.nodeSize,
    required this.gap,
  });
  final List<LipskeyCatalogProduct> chain;
  final String? bottleneckSku;
  final double nodeSize;
  final double gap;

  static const _materialColors = {
    'HDPE': Color(0xFF22D3EE), // cyan — cold supply
    'PEX': Color(0xFFFB923C), // orange — pex
    'נחושת': Color(0xFFEA580C), // copper
    'פליז': Color(0xFFEAB308), // brass
    'PVC': Color(0xFF94A3B8), // gray — drainage
    'PP': Color(0xFF64748B),
    'רב-שכבתי': Color(0xFFA855F7), // purple — multi-layer
    'ceramic': Color(0xFFE2E8F0),
    'rubber': Color(0xFF334155),
    'פלדה': Color(0xFF475569),
    'נירוסטה': Color(0xFFCBD5E1),
  };

  static const _defaultColor = Color(0xFF7C8AA5);

  Color _colorOf(LipskeyCatalogProduct p) {
    final mat = kVerifiedSpecs[p.sku]?.material;
    return _materialColors[mat] ?? _defaultColor;
  }

  /// Returns (label, color) for the connection between two adjacent products.
  /// Inspects their ends and picks the first joint that mates.
  ({String label, Color color}) _edgeStyle(
      LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
    final sa = kVerifiedSpecs[a.sku];
    final sb = kVerifiedSpecs[b.sku];
    if (sa == null || sb == null) {
      return (label: '?', color: _defaultColor);
    }
    for (final eA in sa.ends) {
      for (final eB in sb.ends) {
        if (eA.directMatesWith(eB)) {
          switch (eA.type) {
            case EndType.bspMale:
            case EndType.bspFemale:
              return (
                label: 'הברגה ${eA.size}',
                color: const Color(0xFFEAB308)
              );
            case EndType.pexPress:
              return (
                label: 'PEX ${eA.size}',
                color: const Color(0xFFFB923C)
              );
            case EndType.copperPress:
              return (
                label: 'נחושת ${eA.size}',
                color: const Color(0xFFEA580C)
              );
            case EndType.drainOpening:
              return (label: 'פתח DN${eA.size}', color: _defaultColor);
            default:
              break;
          }
        }
        if (eA.pipeSharedWith(eB)) {
          return (
            label: 'צינור DN${eA.size}',
            color: const Color(0xFF22D3EE)
          );
        }
      }
    }
    return (label: '?', color: _defaultColor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (chain.isEmpty) return;
    final centerY = size.height / 2;

    // Iterate from RIGHT to LEFT so visual order matches RTL reading.
    for (var i = 0; i < chain.length; i++) {
      final rightX = size.width - 12 - i * (nodeSize + gap) - nodeSize / 2;

      // Edge (incoming from the previous-right product)
      if (i > 0) {
        final prevRightX =
            size.width - 12 - (i - 1) * (nodeSize + gap) - nodeSize / 2;
        final style = _edgeStyle(chain[i - 1], chain[i]);
        final paint = Paint()
          ..color = style.color
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        // Draw line between centres, but stop at the node circumferences
        final x0 = prevRightX - nodeSize / 2;
        final x1 = rightX + nodeSize / 2;
        canvas.drawLine(Offset(x0, centerY), Offset(x1, centerY), paint);
        // Direction arrow head — flow runs from the start (right) towards
        // the end (left) in this RTL diagram. Draw a small filled triangle
        // pointing left at the midpoint.
        final arrowX = (x0 + x1) / 2;
        final arrowPath = Path()
          ..moveTo(arrowX - 4, centerY)
          ..lineTo(arrowX + 3, centerY - 4)
          ..lineTo(arrowX + 3, centerY + 4)
          ..close();
        canvas.drawPath(arrowPath, Paint()..color = style.color);
        // Edge label centered above
        final tp = TextPainter(
          text: TextSpan(
            text: style.label,
            style: TextStyle(
              color: style.color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: gap + 12);
        tp.paint(
            canvas,
            Offset(arrowX - tp.width / 2, centerY - tp.height - 8));
      }

      // Node — coloured ring + emoji
      final p = chain[i];
      final color = _colorOf(p);
      final isBottleneck = bottleneckSku != null && p.sku == bottleneckSku;
      final isEndpoint = i == 0 || i == chain.length - 1;

      // Bottleneck gets a red warning ring underneath the material ring
      if (isBottleneck) {
        final warnPaint = Paint()
          ..color = const Color(0xFFEF4444)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(
            Offset(rightX, centerY), nodeSize / 2 + 4, warnPaint);
      }
      // Endpoint gets a thicker accent ring so the user can see start/end
      final ringPaint = Paint()
        ..color = color
        ..strokeWidth = isEndpoint ? 4.0 : 2.5
        ..style = PaintingStyle.stroke;
      final fillPaint = Paint()
        ..color = color.withValues(alpha: isEndpoint ? 0.25 : 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(rightX, centerY), nodeSize / 2, fillPaint);
      canvas.drawCircle(Offset(rightX, centerY), nodeSize / 2, ringPaint);

      // Start/end badge — small dot above the endpoint to call it out
      if (isEndpoint) {
        canvas.drawCircle(
            Offset(rightX, centerY - nodeSize / 2 - 6),
            3.5,
            Paint()..color = color);
      }

      // Emoji label
      final emoji = TextPainter(
        text: TextSpan(
          text: p.typeEmoji,
          style: const TextStyle(fontSize: 22),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      emoji.paint(canvas,
          Offset(rightX - emoji.width / 2, centerY - emoji.height / 2 - 4));

      // SKU below node
      final sku = TextPainter(
        text: TextSpan(
          text: '#${p.sku}',
          style: const TextStyle(
            color: Color(0xFF7C8AA5),
            fontSize: 8,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: nodeSize + 8);
      sku.paint(
          canvas,
          Offset(rightX - sku.width / 2, centerY + nodeSize / 2 + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ChainPainter old) =>
      old.chain.length != chain.length ||
      List.generate(chain.length, (i) => old.chain[i].sku != chain[i].sku)
          .any((x) => x);
}
