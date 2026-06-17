// Suggestion source for the chat composer (Phase-2 live wiring).
//
// Offers two pools of canned Hebrew phrases above the chat keyboard: generic
// quick-replies plus the verbatim order-stage labels from `supplier_data.dart`
// (so a store/courier can answer "where's my order" in one tap). Unranked — it
// only decides which phrases are eligible; ordering/capping is `ranking.dart`'s
// job, exactly like `StaticSuggestionSource`.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/suggestion_source.dart';

/// Generic one-tap replies offered in the chat composer. Verbatim Hebrew.
const List<String> kChatQuickReplies = <String>[
  'קיבלתי, תודה',
  'בסדר גמור',
  'אעדכן אותך בהקדם',
  'מעולה',
  'מוכן לאיסוף',
  'אאסוף בהקדם',
  'תודה רבה',
  'בדרך אליך',
];

/// Canned quick-replies + order-stage phrases offered in the chat composer.
///
/// The eligible pool is [kChatQuickReplies] followed by the Hebrew values of
/// [kOrderStageLabel]. A blank/whitespace [query] returns the whole pool; a
/// non-blank [query] keeps pool entries whose text contains the trimmed query
/// (case-insensitive), preserving pool order.
class ChatSuggestionSource implements SuggestionSource {
  const ChatSuggestionSource();

  @override
  List<Suggestion> candidates(SmartInputContext ctx, String query) {
    final pool = <String>[...kChatQuickReplies, ...kOrderStageLabel.values];
    final q = query.trim().toLowerCase();
    return [
      for (final p in pool)
        if (q.isEmpty || p.toLowerCase().contains(q)) Suggestion(p),
    ];
  }
}
