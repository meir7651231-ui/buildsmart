// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__finder_screen:_ChipScroll (בנייה-חכמה main) · Stateful+State
import 'package:flutter/material.dart';

class ChipScroll extends StatefulWidget {
  const ChipScroll({required this.children});
  final List<Widget> children;
  @override
  State<ChipScroll> createState() => ChipScrollState();
}

class ChipScrollState extends State<ChipScroll> {
  final _ctrl = ScrollController();
  bool _more = false; // hidden chips remain toward the end edge

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_recompute);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  void _recompute() {
    if (!_ctrl.hasClients) return;
    final more = _ctrl.offset < _ctrl.position.maxScrollExtent - 0.5;
    if (more != _more) setState(() => _more = more);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _recompute();
            return false;
          },
          child: ListView(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 7),
            children: widget.children,
          ),
        ),
        if (_more)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                key: const Key('chip-scroll-more'),
                width: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Color(0x00FFFFFF), Colors.white],
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.chevron_left, size: 18, color: _mute,
                    textDirection: TextDirection.ltr),
              ),
            ),
          ),
      ],
    );
  }
}

const _mute = Color(0xFF888888);
