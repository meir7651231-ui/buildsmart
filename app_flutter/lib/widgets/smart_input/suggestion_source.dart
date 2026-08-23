import 'package:buildsmart/widgets/smart_input/models.dart';

/// A pluggable provider of raw [Suggestion] candidates for the smart-input
/// surface (Phase-1). Implementations are *unranked* — they only decide which
/// phrases are eligible for a given [SmartInputContext] + [query]; ordering /
/// capping / primary-marking is the job of `ranking.dart`.
abstract class SuggestionSource {
  List<Suggestion> candidates(SmartInputContext ctx, String query);
}

/// The simplest source: a fixed phrase list filtered by a case-insensitive
/// `contains(query)`. A blank [query] returns the whole list (every phrase
/// trivially "contains" the empty string). Order is preserved from [phrases].
class StaticSuggestionSource implements SuggestionSource {
  final List<String> phrases;
  const StaticSuggestionSource(this.phrases);

  @override
  List<Suggestion> candidates(SmartInputContext ctx, String query) {
    final q = query.trim().toLowerCase();
    return [
      for (final p in phrases)
        if (q.isEmpty || p.toLowerCase().contains(q)) Suggestion(p),
    ];
  }
}
