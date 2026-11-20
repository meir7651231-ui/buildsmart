import 'package:buildsmart/data/legal_texts.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

/// Which legal document the screen opens on.
enum LegalTab {
  /// תנאי שימוש.
  terms,

  /// מדיניות פרטיות.
  privacy,
}

/// תנאי שימוש + מדיניות פרטיות — a clean RTL reader screen (task #26).
///
/// Two documents behind a segmented toggle; content comes verbatim from
/// [kTermsOfUse] / [kPrivacyPolicy] (lib/data/legal_texts.dart) and renders
/// as scrollable [SelectableText] sections ('## ' lines become headers).
/// Reached from הגדרות › מידע, from the app-wide search entries, and from the
/// registration footer on the welcome screen.
class LegalScreen extends StatefulWidget {
  const LegalScreen({this.initialTab = LegalTab.terms, super.key});

  /// The document shown when the screen opens.
  final LegalTab initialTab;

  static Route<void> route({LegalTab initialTab = LegalTab.terms}) =>
      MaterialPageRoute<void>(
        builder: (_) => LegalScreen(initialTab: initialTab),
      );

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late LegalTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final doc = _tab == LegalTab.terms ? kTermsOfUse : kPrivacyPolicy;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: CfgText(
          'legal_screen.t01',
          'תנאי שימוש ופרטיות',
          style: TextStyle(
            color: bsInk(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: Column(
        children: [
          _SegmentedToggle(
            value: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          Padding(
            padding: EdgeInsets.only(top: BsTokens.space2),
            child: Text(
              'עדכון אחרון: $kLegalLastUpdated',
              style: TextStyle(
                color: bsMuted(context),
                fontSize: BsTokens.typeMicro,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              // New key per tab so switching documents resets the scroll.
              key: ValueKey(_tab),
              padding: const EdgeInsets.fromLTRB(
                BsTokens.space4,
                BsTokens.space3,
                BsTokens.space4,
                BsTokens.space6,
              ),
              children: [
                const _PlaceholderNotice(),
                ..._docBlocks(doc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Splits a legal document into widgets: '## ' blocks become section
  /// headers, everything else becomes selectable body paragraphs.
  List<Widget> _docBlocks(String doc) {
    final blocks = doc.trim().split('\n\n');
    return [
      for (final block in blocks)
        if (block.startsWith('## '))
          Padding(
            padding: const EdgeInsets.only(
              top: BsTokens.space4,
              bottom: BsTokens.space1,
            ),
            child: SelectableText(
              block.substring(3),
              style: TextStyle(
                color: bsInk(context),
                fontSize: BsTokens.typeSubhead,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space2),
            child: SelectableText(
              block,
              style: TextStyle(
                color: bsMuted(context),
                fontSize: BsTokens.typeBody,
                height: 1.65,
              ),
            ),
          ),
    ];
  }
}

/// Honest banner: company-identity fields in the documents are bracketed
/// placeholders until the operating company's details exist — אין המצאות.
class _PlaceholderNotice extends StatelessWidget {
  const _PlaceholderNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(BsTokens.space3),
        border: Border.all(color: const Color(0xFFF3DFB6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // the notice box is a FIXED warm-light fill — pin the glyph to its
          // own ink (it inherited the theme ink: light-on-light in dark mode).
          Text('ℹ️', style: TextStyle(fontSize: 16, color: BsTokens.warnText)),
          SizedBox(width: BsTokens.space2),
          Expanded(
            child: Text(
              'פרטי החברה המופיעים במסמכים בסוגריים מרובעים — כגון '
              '[שם החברה] — יושלמו לפני השקה מסחרית.',
              style: TextStyle(
                color: BsTokens.warnText,
                fontSize: BsTokens.typeMicro,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-option segmented toggle (תנאי שימוש / מדיניות פרטיות) — pill container
/// with the selected segment lifted on a white card.
class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({required this.value, required this.onChanged});

  final LegalTab value;
  final ValueChanged<LegalTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space3,
        BsTokens.space4,
        0,
      ),
      padding: const EdgeInsets.all(BsTokens.space1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BsTokens.space3),
      ),
      child: Row(
        children: [
          _segment(context, label: 'תנאי שימוש', tab: LegalTab.terms),
          _segment(context, label: 'מדיניות פרטיות', tab: LegalTab.privacy),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required String label,
    required LegalTab tab,
  }) {
    final selected = value == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tab),
        child: AnimatedContainer(
          duration: BsTokens.microIn,
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
          decoration: BoxDecoration(
            color: selected ? BsTokens.cardLight : Colors.transparent,
            borderRadius: BorderRadius.circular(BsTokens.space2),
            boxShadow: selected ? BsTokens.labelShadow : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              // unselected sits on surfaceContainerHighest → its paired foreground
              // (mutedLight there was 4.43:1 in light — under AA).
              color: selected
                  ? BsTokens.brandDark
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: BsTokens.typeLabel,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
