/// חוט · tier-of — דרגת מדד-האמינות לפי ניקוד (950/800/סף-אדום), כולל פיגמנטי-הדרגה.
/// המרה נאמנה מ-new/atoms/tier-of.mjs (חוק-4: המקור קדוש).
/// קבוע-השכן CRED_RED_THRESHOLD הוזרק כשקע redThreshold (חוק-1) — אפס import.
dynamic tierOf(dynamic score, dynamic redThreshold, {required String Function(String) term}) {
  if (score >= 950) {
    return {'key': 'titan', 'label': term('tytan'), 'bg': '#fdf3dd', 'c': '#9a6414', 'dot': '#f3c76b'};
  }
  if (score >= 800) {
    return {'key': 'lion', 'label': term('lbyah'), 'bg': '#e4f5ea', 'c': '#12803c', 'dot': '#16a34a'};
  }
  if (score >= redThreshold) {
    return {'key': 'pale', 'label': term('tavn-shypvr'), 'bg': '#fdf1d4', 'c': '#9a6414', 'dot': '#d97706'};
  }
  return {'key': 'red', 'label': term('sykvn-ntyshh'), 'bg': '#fdeaea', 'c': '#b91c1c', 'dot': '#dc2626'};
}
