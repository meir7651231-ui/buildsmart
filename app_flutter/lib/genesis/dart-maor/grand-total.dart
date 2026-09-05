/// חוט · grand-total — הסכום הכולל של כל הקופות. חוזה: grand-total.contract.md
/// חולץ כלשונו מ-maor/src/components/tzedaka/lib.ts:64-66; השכן boxTotal
/// הוזרק כשקע (חוק-1 — אפס import פנימי). זהה-לחלוטין למקור-ה-JS (חוק-4).
num grandTotal(List boxes, num Function(dynamic) boxTotal) {
  return boxes.fold<num>(0, (a, b) => a + boxTotal(b));
}
