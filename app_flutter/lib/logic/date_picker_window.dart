// Bounds for a `showDatePicker` that is seeded from a STORED date.
//
// `showDatePicker` asserts `firstDate <= initialDate <= lastDate`. A fixed
// window around "now" (e.g. ±2 years) breaks as soon as a stored date drifts
// outside it — a task planned 3 years ago and re-opened for editing threw
// "initialDate must be on or after firstDate" instead of opening the picker.
// [datePickerWindow] keeps the usual ±[years] window and stretches it just
// enough to contain [current], so the stored date is always pickable/visible.

/// A picker window: `first <= initial <= last`, all date-only (midnight).
typedef DatePickerWindow = ({DateTime first, DateTime initial, DateTime last});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The ±[years] window around [now], widened to include [current] when set.
/// [initial] is [current] (or today when null).
DatePickerWindow datePickerWindow(
  DateTime? current,
  DateTime now, {
  int years = 2,
}) {
  final today = _dateOnly(now);
  final initial = _dateOnly(current ?? now);
  var first = DateTime(today.year - years, today.month, today.day);
  var last = DateTime(today.year + years, today.month, today.day);
  if (initial.isBefore(first)) first = initial;
  if (initial.isAfter(last)) last = initial;
  return (first: first, initial: initial, last: last);
}
