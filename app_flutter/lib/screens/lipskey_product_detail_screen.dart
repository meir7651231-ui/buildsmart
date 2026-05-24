import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';

class LipskeyProductDetailScreen extends StatefulWidget {
  final LipskeyCatalogProduct product;
  const LipskeyProductDetailScreen({super.key, required this.product});

  @override
  State<LipskeyProductDetailScreen> createState() =>
      _LipskeyProductDetailScreenState();
}

class _LipskeyProductDetailScreenState extends State<LipskeyProductDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _splitController;
  late final AnimationController _shimmerController;
  late final AnimationController _flipController;

  late final Animation<double> _topSlide;
  late final Animation<double> _bottomSlide;
  late final Animation<double> _shimmerOpacity;
  late final Animation<double> _flipAngle;

  final TransformationController _transformController =
      TransformationController();

  double _splitRatio = 0.55;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();

    _splitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _topSlide = Tween<double>(begin: 0, end: -0.45).animate(
      CurvedAnimation(parent: _splitController, curve: Curves.easeOutQuart),
    );

    _bottomSlide = Tween<double>(begin: 0, end: 0.45).animate(
      CurvedAnimation(parent: _splitController, curve: Curves.easeOutQuart),
    );

    _shimmerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeIn),
    );

    _flipAngle = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _splitController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _shimmerController.forward();
    });
  }

  @override
  void dispose() {
    _splitController.dispose();
    _shimmerController.dispose();
    _flipController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _rotateImage() {
    _rotationAngle += pi / 2;
    final center = _transformController.value.getTranslation();
    final rotation = Matrix4.identity()
      ..translate(center.x, center.y)
      ..rotateZ(pi / 2)
      ..translate(-center.x, -center.y);
    _transformController.value = rotation * _transformController.value;
  }

  void _resetTransform() {
    _rotationAngle = 0.0;
    _transformController.value = Matrix4.identity();
  }

  void _triggerFlip() {
    if (_flipController.isAnimating) return;
    if (_flipController.value > 0.5) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  Color _colorFromLabel(String label) => switch (label) {
        'לבן' => Colors.white,
        'שחור' => Colors.black,
        'אפור' => Colors.grey,
        'פרגמון' => const Color(0xFFBFA78A),
        _ => Colors.blueGrey,
      };

  String _assetPath() {
    final padded = widget.product.page.toString().padLeft(2, '0');
    return 'assets/lipskey/pages/page_$padded.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.product.nameHe,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.flip, color: Colors.white),
              onPressed: _triggerFlip,
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _flipAngle,
          builder: (context, _) {
            final angle = _flipAngle.value;
            final isFront = angle < pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isFront ? _buildFrontBody() : _buildBackBody(angle),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontBody() {
    return AnimatedBuilder(
      animation: _splitController,
      builder: (context, _) {
        return LayoutBuilder(builder: (context, constraints) {
          final h = constraints.maxHeight;
          final topH = h * _splitRatio;
          final bottomH = h - topH;
          final topOffset = _topSlide.value * h;
          final bottomOffset = _bottomSlide.value * h;

          return Stack(
            children: [
              // Top panel
              Positioned(
                top: topOffset,
                left: 0,
                right: 0,
                height: topH,
                child: _buildTopPanel(),
              ),
              // Bottom panel
              Positioned(
                top: topH + bottomOffset,
                left: 0,
                right: 0,
                height: bottomH,
                child: _buildBottomPanel(),
              ),
              // Shimmer crack glow
              AnimatedBuilder(
                animation: _shimmerOpacity,
                builder: (context, _) => Positioned(
                  top: topH + topOffset - 2,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: Opacity(
                    opacity: _shimmerOpacity.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white54,
                            Colors.white,
                            Colors.white54,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white30,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Draggable divider
              Positioned(
                top: topH + topOffset - 12,
                left: 0,
                right: 0,
                height: 24,
                child: _buildDivider(h),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildTopPanel() {
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 6.0,
            child: Image.asset(
              _assetPath(),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white30, size: 64),
              ),
            ),
          ),
        ),
        // Reset button (bottom-left of top panel)
        Positioned(
          bottom: 8,
          left: 8,
          child: _ImageActionButton(
            icon: Icons.center_focus_strong,
            onTap: _resetTransform,
          ),
        ),
        // Rotation button (bottom-right of top panel)
        Positioned(
          bottom: 8,
          right: 8,
          child: _ImageActionButton(
            icon: Icons.rotate_90_degrees_cw,
            onTap: _rotateImage,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(double screenH) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) {
        setState(() {
          _splitRatio =
              (_splitRatio + details.delta.dy / screenH).clamp(0.25, 0.80);
        });
      },
      child: Container(
        height: 24,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Color(0x33FFFFFF),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(color: Colors.white24, blurRadius: 12),
          ],
        ),
        child: const Center(
          child: Icon(Icons.drag_handle, color: Colors.white60, size: 20),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final p = widget.product;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(color: Color(0xFF3D5A80), width: 1),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SKU — amber monospace, copyable
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: p.sku));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SKU הועתק'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                '#${p.sku}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.amber,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Category
            Text(
              '${p.categoryEmoji}  ${p.categoryHe}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              p.categoryEn,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 10),
            // Hebrew name
            Text(
              p.nameHe,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // English name
            Text(
              p.nameEn,
              style: const TextStyle(
                color: Color(0x8AFFFFFF),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            // Color chip
            if (p.color != null) ...[
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _colorFromLabel(p.color!),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p.color!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Qty per pack
            if (p.qtyPack != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '📦 ${p.qtyPack} יחידות באריזה',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            // Qty per pallet
            if (p.qtyPallet != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '🏗️ ${p.qtyPallet} יחידות במשטח',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            // Dims
            if (p.dims != null && p.dims!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '📐 ${p.dims!.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            // Page reference
            Text(
              'עמוד ${p.page} בקטלוג',
              style: const TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackBody(double angle) {
    // Mirror the back face so text reads correctly
    final p = widget.product;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        color: const Color(0xFF0D0D1A),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  p.categoryEmoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  p.nameHe,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.nameEn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                _BackSpecRow(label: 'SKU', value: '#${p.sku}'),
                _BackSpecRow(label: 'קטגוריה', value: '${p.categoryEmoji} ${p.categoryHe}'),
                _BackSpecRow(label: 'Category', value: p.categoryEn),
                if (p.color != null) _BackSpecRow(label: 'צבע', value: p.color!),
                if (p.qtyPack != null)
                  _BackSpecRow(label: 'יחידות באריזה', value: '${p.qtyPack}'),
                if (p.qtyPallet != null)
                  _BackSpecRow(label: 'יחידות במשטח', value: '${p.qtyPallet}'),
                if (p.dims != null && p.dims!.isNotEmpty)
                  _BackSpecRow(
                    label: 'מידות',
                    value: p.dims!.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                  ),
                _BackSpecRow(label: 'עמוד בקטלוג', value: '${p.page}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ImageActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _BackSpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _BackSpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
