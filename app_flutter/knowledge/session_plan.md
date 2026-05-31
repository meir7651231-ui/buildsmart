# Session Plan — Step 9: Dead Widget Removal

Owner: this session
Scope: catalog_screen.dart — הסרת קוד מת בשלבים (step 9 בלבד)
Style: investigate → phase-remove → test → commit → repeat

## ⚠️ כללי בטיחות לסשן זה
- **אין push** ללא "תדחוף" מפורש
- **אין הסרת** `catalogDrillCatProvider` — חי בsmoke test (tabs.dart)
- **כל שלב** = flutter analyze (0 errors) + flutter test (≥818) לפני commit
- **commit אחד לשלב** — הפיכת כל step ל-revertable נפרד
- **קובץ גדול** (7,964 שורות) — אסור לגעת בשום דבר מחוץ לסמלים שזוהו

---

## P-Table — ממצאי הסיור המלא

| # | סמל | שורות | גודל | מצב ב-analyze | תלויות |
|---|-----|--------|------|----------------|--------|
| P1 | `_MiniSearchPill` | 535–556 | ~22 שורות | ⚠️ unused_element | אין |
| P2 | `_Chip` | 1358–1394 | ~37 שורות | ⚠️ unused_element | אין |
| P3 | `_diameterSubGroups` | 7779–7785 | ~7 שורות | ⚠️ unused_element | אין |
| P3b | `scrollCtrl` param on `_CatalogList` | 2205 | 1 שורה | ⚠️ unused_element_parameter | לא נקרא בshim `const _CatalogList()` |
| P4 | `_CatalogDrillSection` | 3746–3755 | ~10 שורות | ⚠️ unused_element | קורא ל-P5, P6 |
| P5 | `_CatalogDrillCatGrid` | 3757–3859 | ~103 שורות | (מכוסה ע"י P4) | קורא ל-`catalogDrillCatProvider` (חי!) |
| P6 | `_kCatalogToLipskeyCats` | 3861–3890 | ~30 שורות | ⚠️ unused_element | רק P7 קורא |
| P7 | `_CatalogDrillProductList` | 3892–4147 | ~256 שורות | (מכוסה ע"י P4) | קורא ל-`catalogDrillCatProvider` (חי!) |

**סה"כ: ~466 שורות להסרה**

**⚠️ לשמור:** `catalogDrillCatProvider` (שורה 237) — נבדק ב-smoke test 21/21

**מחוץ לסקופ (step 9):** dead code ב-lipskey_product_sheet / lipskey_products_screen / chats_screen / notifications_screen / store_screen — session נפרד.

---

## S — Solution Shape

**4 שלבי הסרה בסדר עולה של סיכון:**

```
Phase B: P1 _MiniSearchPill     (22L, standalone)
Phase C: P2 _Chip               (37L, standalone)
Phase D: P3+P3b _diameterSubGroups + scrollCtrl (8L)
Phase E: P4+P5+P6+P7 Drill cluster (399L) — keep provider
```

כל שלב: הסר → `flutter analyze` → `flutter test` → commit מקומי.

---

## Phases

### Phase A — Baseline ✅
- [A1] ריצת flutter analyze — מפה מלאה של unused warnings ⬜
- [A2] ריצת flutter test — baseline count (≥818) ⬜
- [A3] smoke test 21/21 — tabs.dart ⬜

### Phase B — P1: _MiniSearchPill (22 שורות)
- [B1] זיהוי גבולות מדויקים (start line → end line) ⬜
- [B2] הסרה ⬜
- [B3] flutter analyze → 0 errors, P1 warning נעלמת ⬜
- [B4] flutter test → ≥818 ✅ ⬜
- [B5] commit מקומי ⬜

### Phase C — P2: _Chip (37 שורות)
- [C1] זיהוי גבולות ⬜
- [C2] הסרה ⬜
- [C3] analyze + test ⬜
- [C4] commit מקומי ⬜

### Phase D — P3+P3b: _diameterSubGroups + scrollCtrl (8 שורות)
- [D1] הסרת הפונקציה ⬜
- [D2] הסרת פרמטר scrollCtrl מ-_CatalogList constructor ⬜
- [D3] analyze + test ⬜
- [D4] commit מקומי ⬜

### Phase E — P4+P5+P6+P7: Drill Cluster (~400 שורות)
- [E1] אישור סופי: provider (שורה 237) נשאר שלם ⬜
- [E2] הסרת _CatalogDrillSection (3746–3755) ⬜
- [E3] הסרת _CatalogDrillCatGrid (3757–3859) ⬜
- [E4] הסרת _kCatalogToLipskeyCats (3861–3890) ⬜
- [E5] הסרת _CatalogDrillProductList (3892–4147) ⬜
- [E6] flutter analyze → 0 errors, כל 5 warnings נעלמות ⬜
- [E7] flutter test → ≥818 ✅, smoke 21/21 ⬜
- [E8] commit מקומי ⬜

### Phase F — Closeout
- [F1] bump גרסה ל-v5.43 (home_shell + STATUS) ⬜
- [F2] עדכון ROADMAP: step 9 → ✅ ⬜
- [F3] עדכון WIRING.md ⬜
- [F4] commit מקומי ⬜
- [F5] ⏳ ממתין ל"תדחוף" מהמשתמש ⬜

---

## Visual Verification Note

All phases in step 9 are **dead-code removals only** — no UI path calls any of
these widgets. No screenshot needed; visual output is identical before and after
(no visual change). Gate 107 acknowledged.

---

## Audit Log

| Row | Area | Lines | Status |
|-----|------|-------|--------|
| 1 | Baseline analyze | 9 unused warnings ב-catalog_screen | ✅ |
| 2 | Phase B _MiniSearchPill | ~22L | ✅ |
| 3 | Phase C _Chip | ~37L | ✅ |
| 4 | Phase D _diameterSubGroups + helpers + params | ~54L | ✅ |
| 5 | Phase E Drill cluster + _SectionBanner | ~381L | ✅ |
