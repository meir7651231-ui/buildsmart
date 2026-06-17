// The English (QWERTY) on-screen keyboard layer — used for typing English
// product names when the globe key toggles away from Hebrew.
//
// Letters are authored LTR (their natural order) and, like the Hebrew layout,
// render under Directionality.ltr so the key order stays stable inside the
// otherwise-RTL app.
//
// Lowercase only: there is no Shift/caps key (and [KeyKind] has no `shift`
// member). Product search is case-insensitive, so a single case is enough for
// now. Shift/caps is a future addition.

import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';

/// The three letter rows of the English QWERTY keyboard, authored
/// left-to-right. All keys are [KeyKind.letter]; lowercase only (no Shift).
/// Backspace is NOT included here — the grid appends it to the last row.
const List<List<KbKey>> kEnglishRows = <List<KbKey>>[
  <KbKey>[
    KbKey('q'),
    KbKey('w'),
    KbKey('e'),
    KbKey('r'),
    KbKey('t'),
    KbKey('y'),
    KbKey('u'),
    KbKey('i'),
    KbKey('o'),
    KbKey('p'),
  ],
  <KbKey>[
    KbKey('a'),
    KbKey('s'),
    KbKey('d'),
    KbKey('f'),
    KbKey('g'),
    KbKey('h'),
    KbKey('j'),
    KbKey('k'),
    KbKey('l'),
  ],
  <KbKey>[
    KbKey('z'),
    KbKey('x'),
    KbKey('c'),
    KbKey('v'),
    KbKey('b'),
    KbKey('n'),
    KbKey('m'),
  ],
];
