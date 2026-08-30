/// חוט · tier-of — דרגת מדד-האמינות לפי ניקוד (950/800/סף-אדום), כולל פיגמנטי-הדרגה.
/// המרה נאמנה מ-new/atoms/tier-of.mjs (חוק-4: המקור קדוש).
/// קבוע-השכן CRED_RED_THRESHOLD הוזרק כשקע redThreshold (חוק-1) — אפס import.

/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים. (הוזרק ע"י מתקן-ההסגר)
bool _rqTruthy(dynamic v) =>
    !(v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN)));

dynamic tierOf(dynamic score, dynamic redThreshold, {required String Function(String) term}) {
  if (_rqTruthy(score >= 950)) {
    return {'key': 'titan', 'label': term('tytan'), 'bg': '#fdf3dd', 'c': '#9a6414', 'dot': '#f3c76b'};
  }
  if (_rqTruthy(score >= 800)) {
    return {'key': 'lion', 'label': term('lbyah'), 'bg': '#e4f5ea', 'c': '#12803c', 'dot': '#16a34a'};
  }
  if (_rqTruthy(score >= redThreshold)) {
    return {'key': 'pale', 'label': term('tavn-shypvr'), 'bg': '#fdf1d4', 'c': '#9a6414', 'dot': '#d97706'};
  }
  return {'key': 'red', 'label': term('sykvn-ntyshh'), 'bg': '#fdeaea', 'c': '#b91c1c', 'dot': '#dc2626'};
}
