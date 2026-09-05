// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__worker_settings_screen:_SectionCard (בנייה-חכמה main) · Stateful+State
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class WorkerSettingsSectionCard extends StatefulWidget {
  const WorkerSettingsSectionCard({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  @override
  State<WorkerSettingsSectionCard> createState() => WorkerSettingsSectionCardState();
}

class WorkerSettingsSectionCardState extends State<WorkerSettingsSectionCard> {
  // Closed by default — the spec wants every section collapsed on entry.
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Accordion header — tapping toggles the section. ListTile keeps the
          // ≥48dp tap target; the rotating chevron is the open/closed cue.
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Text(widget.emoji, style: const TextStyle(fontSize: 22)),
            title: Text(
              widget.title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.chevron_left, color: Colors.black54),
            ),
            onTap: _toggle,
          ),
          // Body — revealed only when expanded; kept out of the tree entirely
          // while collapsed so the section starts as a tidy header strip.
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...widget.children,
                const SizedBox(height: 8),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
