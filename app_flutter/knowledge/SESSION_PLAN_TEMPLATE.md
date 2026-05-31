# Session Plan Template

> מבנה חובה ל-session_plan.md בכל משימה.
> ה-pre-commit (שערים 21, 22, 106) חוסם אם הסעיפים הקריטיים חסרים.

---

## חלק 1 — Owner + Scope + Style (3 שורות חובה)

```
Owner: this session
Scope: <קובץ ספציפי> או <axis ספציפי> — משפט אחד
Style: fix → verify → log lesson per step
```

**אסור scope creep.** אם המשימה מתרחבת — הוסף sub-protocol חדש בתוך אותו קובץ, אל תכתוב מחדש.

---

## חלק 2 — Rules of Engagement

```
- Local only — אין commit/push עד אישור מפורש.
- Phase Ship (צעד 81+) מושהית עד שהמשתמש אומר "תדחוף".
- כשמגיע אישור — re-fetch origin (parallel sessions push too).
```

---

## חלק 3 — P-Table (כל בעיה שזיהית)

| # | Problem | Where | User-visible symptom |
|---|---------|-------|----------------------|
| P1 | תיאור הבאג | path:line | מה המשתמש רואה |
| P2 | ... | ... | ... |

---

## חלק 4 — S — Solution Shape

חוזה במשפט אחד: מה ה-API/type/contract שיפתור את כל הPs.
דוגמה: `SizeToken(label, family, mm)` + family-coherent sort.

---

## חלק 5 — Phases (100 צעדים)

### Phase A — Recon (1-5)
- [1] קרא ... ⬜
- [2] ... ⬜

### Phase B — Tests First (6-20)
- [6] צור test file ⬜
- [7] בדיקה נכשלת לתופעה ... ⬜
- ... (10+ בדיקות לפני implementation)
- [20] הרץ → כולן RED ⬜

### Phase C — Add utility (21-35)
- [21] צור helper ⬜
- ... (helpers טהורים + unit tests)

### Phase D — Wire (36-50)
- [36] החלף call-sites ⬜
- ... (integration)

### Phase E — Integration + visual (51-65)
- [51] full suite ⬜
- ... (visual verification חובה!)

### Phase F — Harness + docs (66-80)
- [66] harness check ⬜
- ... (STATUS/README/CARRY_FORWARD update)

### Phase G — Ship (81-100) — **מושהית עד אישור**
- [81] git add ספציפי ⬜
- ... (commit + push only on approval)

**Marker convention:** ⬜ = pending, ✅ = done, ❌ = blocker, 🔧 = pivoted

---

## חלק 6 — Sub-Protocols (דינמי — מתרחב כשמתגלות בעיות חדשות)

כשbug חדש מתגלה במהלך verification של תיקון קודם:
1. הוסף Pn חדש לטבלה
2. צור sub-protocol עם 8-15 צעדים ייעודיים
3. עדכן את Phase E/G אם צריך

```
### Pn sub-protocol — תיאור
**Strategy:** משפט אחד
- [N] צעד ⬜
- [N+1] ...
- [N+8] בדוק → screenshot ⬜
```

---

## חלק 7 — Audit Log (כל קטגוריה/area שנסקרה)

| Row | Category/Area | Pool/Size | Outcome |
|-----|---------------|-----------|---------|
| 1 | ... | N items | found Pn / **clean run** |

**Clean runs הם finding** — תעד אותם כ-sentinels לsession הבא.

---

## חלק 8 — Live Log (Problem/Solution/Lesson)

```
### LL-NN — step ref — one-line summary
**Problem:** מה קרה
**Solution:** מה תוקן
**Lesson:** התובנה הכללית (לא רק הbug-fix — מה יחול בעתיד)
```

---

## חלק 9 — Closeout (state ב-end of session)

```
### What changed (touched files)
- path/to/file.dart — תיאור קצר
- ...

### Problems closed
- ✅ P1 ...
- ✅ P2 ...

### Pending — gated on user approval
- Phase G ...
```

---

## חלק 10 — Lessons Carry-Forward (3-8 משפטים)

```
1. <משפט קצר שיעזור לsession הבא בלי לקרוא את הכל>
2. ...
```

לאחר סגירת הsession — להעתיק לקחים שמתאימים לCARRY_FORWARD.md (לקובץ הקבוע, חוצה sessions).
