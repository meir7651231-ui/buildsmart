// hop_stack.dart — the product-to-product navigation back-stack for the card sheet
// (P8.75). The sheet swaps the displayed product IN PLACE when the user taps a related
// product (no recursive sheet); this stack records that path so a single 'back' returns
// to the PREVIOUS product, not all the way to the opening variant. Pure and generic —
// no Flutter, no catalog types — so it is unit-tested in isolation.

/// A last-in-first-out product navigation stack. [current] is the top (the product on
/// screen) or null when empty (the sheet then shows its opening variant). [push] hops
/// forward, [back] pops one hop, [clear] resets to the opening variant.
class HopStack<T> {
  HopStack();

  final List<T> _stack = <T>[];

  /// The item currently on top (on screen), or null if the stack is empty.
  T? get current => _stack.isEmpty ? null : _stack.last;

  /// True when there is at least one hop to go back to.
  bool get canGoBack => _stack.isNotEmpty;

  /// How many hops deep the path currently is.
  int get depth => _stack.length;

  /// An immutable view of the path (oldest first) — for breadcrumbs and tests.
  List<T> get path => List<T>.unmodifiable(_stack);

  /// Hop forward to [item] (it becomes [current]).
  void push(T item) => _stack.add(item);

  /// Pop one hop. No-op when already empty.
  void back() {
    if (_stack.isNotEmpty) _stack.removeLast();
  }

  /// Reset to the opening variant (empties the path).
  void clear() => _stack.clear();
}
