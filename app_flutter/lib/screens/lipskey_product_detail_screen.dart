import 'dart:math';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LipskeyProductDetailScreen extends StatefulWidget {
  final LipskeyCatalogProduct product;

  const LipskeyProductDetailScreen({super.key, required this.product});

  static Route<void> route(LipskeyCatalogProduct product) =>
      MaterialPageRoute(builder: (_) => LipskeyProductDetailScreen(product: product));

  @override
  State<LipskeyProductDetailScreen> createState() => _LipskeyProductDetailScreenState();
}

class _LipskeyProductDetailScreenState extends State<LipskeyProductDetailScreen>
    with TickerProviderStateMixin {
  // ── 360° rotation ─────────────────────────────────────────────────────────
  double _rotY = 0.0;
  double _rotX = 0.0;
  double _scale = 1.0;
  double _baseScale = 1.0;

  late AnimationController _inertiaCtrl;
  late Animation<double> _inertiaAnim;

  // spec panel
  late AnimationController _specCtrl;
  late Animation<double> _specAnim;
  bool _specOpen = false;

  // entrance
  late AnimationController _fadeCtrl;

  LipskeyCatalogProduct get p => widget.product;

  @override
  void initState() {
    super.initState();
    _inertiaCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _specCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _specAnim = CurvedAnimation(parent: _specCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) => _fadeCtrl.forward());
  }

  @override
  void dispose() {
    _inertiaCtrl.dispose();
    _specCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── gesture ───────────────────────────────────────────────────────────────
  void _onPanStart(DragStartDetails _) => _inertiaCtrl.stop();

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _rotY += d.delta.dx * 0.01;
      _rotX = (_rotX - d.delta.dy * 0.01).clamp(-pi / 3, pi / 3);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final vel = d.velocity.pixelsPerSecond.dx * 0.0002;
    final target = _rotY + vel * 8;
    _inertiaAnim = Tween<double>(begin: _rotY, end: target)
        .animate(CurvedAnimation(parent: _inertiaCtrl, curve: Curves.decelerate));
    _inertiaCtrl.addListener(() => setState(() => _rotY = _inertiaAnim.value));
    _inertiaCtrl.forward(from: 0);
  }

  void _onScaleStart(ScaleStartDetails _) => _baseScale = _scale;

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_baseScale * d.scale).clamp(0.4, 5.0);
      _rotY += d.focalPointDelta.dx * 0.008;
      _rotX = (_rotX - d.focalPointDelta.dy * 0.008).clamp(-pi / 3, pi / 3);
    });
  }

  void _toggleSpec() {
    setState(() => _specOpen = !_specOpen);
    _specOpen ? _specCtrl.forward() : _specCtrl.reverse();
  }

  void _resetView() => setState(() { _rotY = 0; _rotX = 0; _scale = 1.0; });

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        extendBodyBehindAppBar: true,
        appBar: _appBar(context),
        body: FadeTransition(
          opacity: _fadeCtrl,
          child: Stack(children: [
            // radial glow background
            Positioned.fill(child: _buildGlow()),

            // 360 viewer — fills screen
            Positioned.fill(child: _build360Viewer()),

            // hint strip at top (fades after first drag)
            Positioned(
              top: 100, left: 0, right: 0,
              child: _buildHint(),
            ),

            // spec panel slides from bottom
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: AnimatedBuilder(
                animation: _specAnim,
                builder: (_, __) => _buildSpecPanel(),
              ),
            ),

            // control buttons — right side
            Positioned(
              right: 16,
              bottom: _specOpen ? _kSpecHeight + 16 : 100,
              child: _buildControls(),
            ),
          ]),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(p.nameHe,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline,
                color: _specOpen ? const Color(0xFF64FFDA) : const Color(0xFF888888)),
            onPressed: _toggleSpec,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF888888)),
            onPressed: _resetView,
          ),
        ],
      );

  // ── glow ──────────────────────────────────────────────────────────────────
  Widget _buildGlow() => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.7,
            colors: [
              const Color(0xFF3D5A80).withOpacity(0.25),
              Colors.transparent,
            ],
          ),
        ),
      );

  // ── hint ──────────────────────────────────────────────────────────────────
  Widget _buildHint() => const Center(
        child: Text(
          '← גרור לסיבוב · צבוט להגדלה →',
          style: TextStyle(color: Colors.black12, fontSize: 12, letterSpacing: 0.3),
        ),
      );

  // ── 360° viewer ───────────────────────────────────────────────────────────
  Widget _build360Viewer() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0008) // perspective
            ..rotateY(_rotY)
            ..rotateX(_rotX)
            ..scale(_scale),
          child: _buildFaceSwitch(),
        ),
      ),
    );
  }

  // front vs back face
  Widget _buildFaceSwitch() {
    final norm = _rotY % (2 * pi);
    final absNorm = norm < 0 ? norm + 2 * pi : norm;
    final showBack = absNorm > pi / 2 && absNorm < 3 * pi / 2;

    if (showBack) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(pi), // counter-rotate so text reads correctly
        child: _buildBackFace(),
      );
    }
    return _buildFrontFace();
  }

  Widget _buildFrontFace() {
    final asset = p.imageAsset;
    if (asset == null) return _emojiCard(p.categoryEmoji);

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64FFDA).withOpacity(0.18),
            blurRadius: 50,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _emojiCard(p.categoryEmoji),
      ),
    );
  }

  Widget _buildBackFace() => Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF3D5A80).withOpacity(0.3), blurRadius: 30),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: _buildSpecContent(compact: true),
      );

  Widget _emojiCard(String emoji) => Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 80))),
      );

  // ── controls ──────────────────────────────────────────────────────────────
  Widget _buildControls() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(icon: Icons.add, onTap: () => setState(() => _scale = (_scale + 0.4).clamp(0.4, 5.0))),
          const SizedBox(height: 8),
          _Btn(icon: Icons.remove, onTap: () => setState(() => _scale = (_scale - 0.4).clamp(0.4, 5.0))),
          const SizedBox(height: 8),
          _Btn(icon: Icons.rotate_right, onTap: () => setState(() => _rotY += pi / 6)),
          const SizedBox(height: 8),
          _Btn(icon: Icons.rotate_left, onTap: () => setState(() => _rotY -= pi / 6)),
        ],
      );

  // ── spec panel ────────────────────────────────────────────────────────────
  static const double _kSpecHeight = 300;

  Widget _buildSpecPanel() {
    final h = _kSpecHeight * _specAnim.value;
    if (h < 2) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: h,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: _buildSpecContent(compact: false),
        ),
      ),
    );
  }

  Widget _buildSpecContent({required bool compact}) {
    final ts = compact ? 0.8 : 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          Center(
            child: Container(
              width: 36, height: 3,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

        // SKU — tappable to copy
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: p.sku));
            if (!compact) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('מק"ט הועתק'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text('#${p.sku}',
              style: TextStyle(
                fontFamily: 'monospace',
                color: const Color(0xFFFFB300),
                fontSize: 13 * ts,
                fontWeight: FontWeight.w700,
              )),
        ),

        SizedBox(height: compact ? 4 : 8),

        // Category
        Row(children: [
          Text(p.categoryEmoji, style: TextStyle(fontSize: 16 * ts)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(p.categoryHe,
                style: TextStyle(color: const Color(0xFF888888), fontSize: 12 * ts)),
          ),
        ]),

        SizedBox(height: compact ? 3 : 6),

        // Name
        Text(p.nameHe,
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: 14 * ts,
              fontWeight: FontWeight.w700,
            )),
        if (p.nameEn.isNotEmpty)
          Text(p.nameEn,
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: 11 * ts,
                fontStyle: FontStyle.italic,
              )),

        if (!compact) ...[
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
          const SizedBox(height: 10),

          if (p.color != null) _row('🎨', 'צבע', p.color!),
          if (p.qtyPack != null) _row('📦', 'כמות באריזה', '${p.qtyPack}'),
          if (p.qtyPallet != null) _row('🏗️', 'כמות במשטח', '${p.qtyPallet}'),
          if (p.dims != null)
            for (final e in p.dims!.entries)
              if (e.value != null) _row('📐', e.key, '${e.value}'),

          const SizedBox(height: 12),
          Text('עמוד ${p.page} · קטלוג ליפסקי ברקן 2024',
              style: const TextStyle(color: Colors.black12, fontSize: 11)),
        ],
      ],
    );
  }

  Widget _row(String emoji, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black38, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13)),
        ]),
      );
}

// ── small round button ────────────────────────────────────────────────────────
class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, color: Colors.black54, size: 20),
        ),
      );
}
