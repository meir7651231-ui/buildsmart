import 'package:buildsmart/screens/rewards_hub_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Primary dark text on the light theme (per the spec — no `inkLight` token).
const Color _ink = Color(0xFF1A1A1A);

/// 👤 הפרופיל שלי — the native home for the user's account.
///
/// Replaces the menu-dial's ⚙️ → 👤 חשבון group: name + contact + profession,
/// editable in place and persisted through [userProfileProvider]. Reached by
/// tapping the user's name chip beside the logo (wired separately). Below the
/// form, two link rows surface the role picker (showRolePicker) and the rewards
/// hub (RewardsHubScreen) — the other two account leaves.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen());

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// The trade options offered as chips (verbatim from the prototype's
  /// profession step). The screen picks one; saving writes it to the profile.
  static const List<String> _professions = [
    'אינסטלטור',
    'חשמלאי',
    'קבלן שיפוצים',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late String _profession;

  @override
  void initState() {
    super.initState();
    final p = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: p.name);
    _contactController = TextEditingController(text: p.contact);
    _profession = p.profession;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(userProfileProvider.notifier).update(
          name: _nameController.text,
          contact: _contactController.text,
          profession: _profession,
        );
    showToast(context, 'הפרופיל נשמר');
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(userProfileProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          foregroundColor: _ink,
          elevation: 0,
          title: const Text(
            'הפרופיל שלי',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            _HeaderCard(profile: p),
            const SizedBox(height: BsTokens.space5),
            const _SectionLabel('פרטים אישיים'),
            const SizedBox(height: BsTokens.space3),
            _Field(
              label: 'שם מלא',
              controller: _nameController,
              hint: 'שם הקבלן',
            ),
            const SizedBox(height: BsTokens.space4),
            _Field(
              label: 'טלפון או אימייל',
              controller: _contactController,
              hint: 'טלפון או אימייל',
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: BsTokens.space4),
            const _FieldLabel('תחום מקצועי'),
            const SizedBox(height: BsTokens.space2),
            Wrap(
              spacing: BsTokens.space2,
              runSpacing: BsTokens.space2,
              children: [
                for (final trade in _professions)
                  ChoiceChip(
                    label: Text(trade),
                    selected: _profession == trade,
                    showCheckmark: true,
                    backgroundColor: const Color(0xFFF0F0F0),
                    selectedColor: const Color(0xFFFFF0E3),
                    labelStyle: TextStyle(
                      color: _profession == trade ? BsTokens.brandDark : _ink,
                      fontWeight: _profession == trade
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                    side: BorderSide.none,
                    onSelected: (_) => setState(() => _profession = trade),
                  ),
              ],
            ),
            const SizedBox(height: BsTokens.space5),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: BsTokens.brand,
                  padding:
                      const EdgeInsets.symmetric(vertical: BsTokens.space3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  ),
                ),
                child: const Text(
                  'שמור',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space5),
            const _SectionLabel('עוד'),
            const SizedBox(height: BsTokens.space3),
            _LinkRow(
              label: '🔄 החלפת תפקיד',
              onTap: () => showRolePicker(context),
            ),
            const SizedBox(height: BsTokens.space2),
            _LinkRow(
              label: '🎮 מועדון BuildSmart',
              onTap: () =>
                  Navigator.of(context).push(RewardsHubScreen.route()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white header card: avatar + big name + profession + contact lines.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final hasName = profile.name.trim().isNotEmpty;
    final name = hasName ? profile.name : 'אורח';
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E3),
              shape: BoxShape.circle,
            ),
            // Decorative: the full name is read just below.
            child: ExcludeSemantics(
              child: hasName
                  ? Text(
                      profile.name.characters.first,
                      style: const TextStyle(
                        color: BsTokens.brandDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    )
                  : const Icon(Icons.person,
                      color: BsTokens.brandDark, size: 28),
            ),
          ),
          const SizedBox(width: BsTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                if (profile.profession.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.profession,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (profile.contact.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.contact,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A bold uppercase-feel section divider label (e.g. "פרטים אישיים").
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: BsTokens.mutedLight,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      );
}

/// A field/title label sitting above an input (e.g. "תחום מקצועי").
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      );
}

/// A labelled text input — label on top, a white-filled [TextField] below.
///
/// [textDirection] controls how the entered text flows: RTL for Hebrew free
/// text (e.g. the name), LTR for digits/Latin (e.g. a phone or email). The
/// field is right-aligned either way to sit naturally under ambient RTL.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.textDirection = TextDirection.rtl,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: BsTokens.space2),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          textDirection: textDirection,
          style: const TextStyle(color: _ink, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: BsTokens.mutedLight),
            filled: true,
            fillColor: BsTokens.cardLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space3,
              vertical: BsTokens.space3,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              borderSide: const BorderSide(color: BsTokens.brand, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// A tappable white link row with a chevron — for the "עוד" actions.
///
/// [label] carries a decorative leading emoji (e.g. "🔄 החלפת תפקיד"). The visible
/// text keeps the emoji, but it is hidden from assistive tech via
/// [ExcludeSemantics]; the row instead exposes a button role whose semantic
/// label is the clean Hebrew text only.
class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  /// The Hebrew label with the leading emoji (and its trailing space) removed.
  String get _cleanLabel => label.characters.skip(1).toString().trimLeft();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4,
            vertical: BsTokens.space4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Semantics(
            button: true,
            label: _cleanLabel,
            child: Row(
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
