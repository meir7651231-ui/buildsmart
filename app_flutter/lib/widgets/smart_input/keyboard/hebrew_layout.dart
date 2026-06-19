// The approved Hebrew on-screen keyboard layout.
//
// Hebrew has no shift/caps — there is no Shift key (and [KeyKind] has no
// `shift` member). Letters are authored LTR and rendered under
// Directionality.ltr so the key order stays stable inside the otherwise-RTL
// app; the framework would mirror the row order under RTL otherwise.

import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';

/// The three letter rows of the Hebrew keyboard, authored left-to-right.
///
/// Row 1 carries the digit superscripts `1`..`0`; its first two keys are
/// punctuation (maqaf and geresh), the remaining eight are letters. Rows 2 and
/// 3 are all letters. Backspace is NOT included here — the grid appends it to
/// the last row.
const List<List<KbKey>> kHebrewRows = <List<KbKey>>[
  <KbKey>[
    KbKey('־', kind: KeyKind.punct, output: '־', superscript: '1'),
    KbKey('׳', kind: KeyKind.punct, output: '׳', superscript: '2'),
    KbKey('ק', superscript: '3'),
    KbKey('ר', superscript: '4'),
    KbKey('א', superscript: '5'),
    KbKey('ט', superscript: '6'),
    KbKey('ו', superscript: '7'),
    KbKey('ן', superscript: '8'),
    KbKey('ם', superscript: '9'),
    KbKey('פ', superscript: '0'),
  ],
  <KbKey>[
    KbKey('ש'),
    KbKey('ד'),
    KbKey('ג'),
    KbKey('כ'),
    KbKey('ע'),
    KbKey('י'),
    KbKey('ח'),
    KbKey('ל'),
    KbKey('ך'),
    KbKey('ף'),
  ],
  <KbKey>[
    KbKey('ז'),
    KbKey('ס'),
    KbKey('ב'),
    KbKey('ה'),
    KbKey('נ'),
    KbKey('מ'),
    KbKey('צ'),
    KbKey('ת'),
    KbKey('ץ'),
  ],
];

/// The bottom row, authored left-to-right: send, the `?123` layer switch, the
/// language globe, the wide space bar (labelled `עברית`), period, and enter.
const List<KbKey> kBottomRow = <KbKey>[
  KbKey('שלח', kind: KeyKind.send),
  KbKey('?123', kind: KeyKind.symbols),
  KbKey('globe', kind: KeyKind.language),
  KbKey('עברית', kind: KeyKind.space, output: ' ', flex: 4),
  KbKey('.', kind: KeyKind.period, output: '.'),
  KbKey('↵', kind: KeyKind.enter),
];

/// The `?123` symbols layer. Row 1 is the digits `1`..`0`; row 2 is common
/// punctuation; row 3 is currency and symbols. There is NO separate
/// back-to-letters key here — the single bottom-row layer-switch key relabels
/// (`?123` on letters -> `אבג` on symbols). Backspace is appended by the grid.
const List<List<KbKey>> kSymbolsRows = <List<KbKey>>[
  <KbKey>[
    KbKey('1', kind: KeyKind.punct, output: '1'),
    KbKey('2', kind: KeyKind.punct, output: '2'),
    KbKey('3', kind: KeyKind.punct, output: '3'),
    KbKey('4', kind: KeyKind.punct, output: '4'),
    KbKey('5', kind: KeyKind.punct, output: '5'),
    KbKey('6', kind: KeyKind.punct, output: '6'),
    KbKey('7', kind: KeyKind.punct, output: '7'),
    KbKey('8', kind: KeyKind.punct, output: '8'),
    KbKey('9', kind: KeyKind.punct, output: '9'),
    KbKey('0', kind: KeyKind.punct, output: '0'),
  ],
  <KbKey>[
    KbKey('.', kind: KeyKind.punct),
    KbKey(',', kind: KeyKind.punct),
    KbKey('?', kind: KeyKind.punct),
    KbKey('!', kind: KeyKind.punct),
    KbKey("'", kind: KeyKind.punct),
    KbKey('"', kind: KeyKind.punct),
    KbKey('-', kind: KeyKind.punct),
    KbKey('/', kind: KeyKind.punct),
    KbKey(':', kind: KeyKind.punct),
    KbKey(';', kind: KeyKind.punct),
  ],
  <KbKey>[
    KbKey('₪', kind: KeyKind.punct),
    KbKey('@', kind: KeyKind.punct),
    KbKey('#', kind: KeyKind.punct),
    KbKey('%', kind: KeyKind.punct),
    KbKey('(', kind: KeyKind.punct),
    KbKey(')', kind: KeyKind.punct),
    KbKey('&', kind: KeyKind.punct),
    KbKey('+', kind: KeyKind.punct),
  ],
];
