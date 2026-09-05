/// חוט · is-sendable-support-text — האם טקסט-הודעה שליח (לא-ריק אחרי ניקוי).
/// חוזה: is-sendable-support-text.contract.md
/// חולץ כלשונו מ-maor/src/lib/supportChat.ts:40-43; השכן sanitizeSupportText
/// הוזרק כשקע (חוק-1 — אפס import פנימי). התנהגות זהה למקור-ה-JS (חוק-4).
/// אפס import (dart-core בלבד).
bool isSendableSupportText(
  Object? raw,
  String Function(Object? raw) sanitizeSupportText,
) {
  return sanitizeSupportText(raw).length > 0;
}
