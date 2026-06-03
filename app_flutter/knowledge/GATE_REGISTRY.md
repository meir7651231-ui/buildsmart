# GATE_REGISTRY — מרשם שערי הפרוטוקול

> **מטרה:** מניעת קולידה במספרי שערים (לקח #66, #67 — 2026-06-03).
> לפני הוספת שער חדש: בדוק כאן + עדכן "הבא הפנוי" אחרי הוספה.
>
> **כלל:** שמור שער → הוסף לטבלה → commit. לעולם לא שני agents
> מוסיפים שערים ב-session אחד ללא תיאום מראש.

---

## הבא הפנוי: **117**

_(עדכן שורה זו בכל פעם שמוסיפים שער)_

---

## מפת שערים — לפי קבוצה

### קבוצה א׳ — בסיס (1–20)
| שער | תיאור | הוסף ב |
|-----|--------|--------|
| 1 | ענף עבודה | v1 |
| 2 | 11 קבצי ידע קיימים | v1 |
| 3 | WIRING.md קיים | v1 |
| 4 | pubspec.yaml תקין | v1 |
| 5 | ענף שמעוקב | v1 |
| 10 | GitHub Actions קיים | v1 |
| 11 | version.g.dart קיים+תקין (היה home_shell) | v1→v5.92 |
| 12 | version.g.dart↔STATUS מסונכרן (gen_version אוטומטי, לקח #72) | v1→v5.92 |
| 13 | ROADMAP מכיל קבוצה א' | v1 |
| 14 | STATUS מכיל גרסה | v1 |
| 15 | hooksPath = .githooks | v1 |

### קבוצה ב׳ — בטיחות קוד (25–80)
| שער | תיאור | הוסף ב |
|-----|--------|--------|
| 24 | WIRING.md עודכן עם lib changes | v1 |
| 25 | לא לגעת ב-Preact-shared | v1 |
| 31 | flutter analyze — 0 errors | v1 |
| 32 | flutter test — 0 regressions | v1 |
| 33 | flutter build web — builds clean | v1 |
| 34 | לא לשנות known_failing.txt ידנית | v1 |
| 35 | critical tests — כל 6 קיימים | v1 |
| 36 | בדיקת BsTokens בקבצי tokens | v1 |
| 37 | providers.dart consistent | v1 |
| 38 | state/ לא מחוקים | v1 |
| 39 | screens/ לא מחוקים | v1 |
| 40 | WIRING.md לא מחוקה | v1 |
| 41 | אין בדיקות עם count > 0 | v1 |
| 42 | בדיקות חדשות בקובץ _test.dart | v1 |
| 46 | אין משטחים כהים (0xFF111111) | v1 |
| 47 | אין dialog/sheet ללא אישור | v1 |
| 48 | אין print() ב-production | v1 |
| 49 | אין TODO/FIXME חדשים | v1 |
| 50 | אין import dart:html | v1 |
| 51 | אין hard-coded URLs | v1 |
| 52 | אין secrets/keys | v1 |
| 53 | אין .env ב-staged | v1 |
| 54 | אין ColoredBox כהה | v1 |
| 58 | אין dart-define ללא docs | v1 |
| 59 | ~~גרסה עלתה (home_shell)~~ **בוטל** — build אוטומטי מ-git (לקח #72) | v1→v5.92 |
| 60 | אין dependencies חדשות ללא וידוא | v1 |
| 61 | מחרוזות עברית — Preact-shared | v1 |
| 62 | RTL — אין left/right קשיח | v1 |
| 63 | אין TextAlign.left/right | v1 |
| 64 | אין emoji שלא מהלגאסי | v1 |
| 65 | אין Direction.ltr ב-Hebrew | v1 |
| 67 | לא בדיקה ב-app/ ללא Flutter | v1 |
| 68 | לא נגיעה ב-knowledge/inspections | v1 |
| 69 | אין 0xFF111111 ב-light surfaces | v1 |
| 70 | אין שינוי .gitignore לסודות | v1 |
| 74 | ProviderContainer ידני אסור | v1 |
| 75 | providers.dart לא נמחק | v1 |
| 76 | commit message לא ריק | v1 |
| 78 | אין binaries ב-staged | v1 |
| 80 | pubspec.lock — לא override versions | v1 |

### קבוצה ג׳ — hook integrity (81–100)
| שער | תיאור | הוסף ב |
|-----|--------|--------|
| 81 | hook מסונכרן (.githooks ↔ .git/hooks) | v1 |
| 83 | hooksPath מוגדר ב-git config | v1 |
| 88 | אין שינוי MASTER_PROTOCOL ללא הוראה | v1 |
| 89 | אין מחיקת tests | v1 |
| 90 | אין מחיקת state files | v1 |
| 91 | working tree ללא unstaged רלוונטיים | v1 |
| 92 | STATUS.md עודכן עם state changes | v1 |
| 93 | ROADMAP עודכן עם השלמת צעד | v1 |
| 94 | knowledge_protocol_test יעבור | v1 |
| 95 | RTL — מספרים ב-LTR isolate | v1 |
| 96 | pubspec.yaml version לא השתנה ללא bump | v1 |
| 97 | .gitignore לא מסיר .claude/ | v1 |
| 98 | settings.json ב-repo | v1 |
| 99 | 4 שכבות אכיפה קיימות | v1 |
| 100 | סיכום | v1 |

### קבוצה ד׳ — ידע ופרוטוקול (101–114)
| שער | תיאור | הוסף ב |
|-----|--------|--------|
| 101 | stuck_log קיים | v1 |
| 102 | retry אחרי כשלון → stuck_log חדש | v1 |
| 103 | אנטי-פטרנים לא חוזרים בקוד | v1 |
| 104 | stuck_regression_test מעודכן | v1 |
| 106 | session_plan עם Owner + Scope | v1 |
| 107 | UI change → visual verification log | v1 |
| 108 | CARRY_FORWARD קיים | v1 |
| 109 | סגירת sub-protocol → לקח חדש | v1 |
| 110 | audit log על קטגוריה שנסקרה | v1 |
| 111 | ANTIPATTERN count = tests count | v1 |
| 112 | stubs מאוחדים ≤20 שורות | v1 |
| 113 | asset-generation → contact-sheet (+assets/** ידני — לקח #72) | קטלגן 2026-06-02 |
| 114 | kLipskeyCatalog אסור ב-screens/state/logic | פרוטוקוליסט 2026-06-03 |
| 115 | hot-file claims — advisory warn (P2 לקח #72) | פרוטוקוליסט 2026-06-03 |
| 116 | שינוי UI דורש visual_log staged (enforce, P2 לקח #72) | פרוטוקוליסט 2026-06-03 |

---

## שערים פנויים (ידועים)
פערים שניתן למלא אם יש שער מתאים לאזור:
- **6–9**: פנויים (שמור לבסיס)
- **11**: פנוי (אזור בסיס)
- **16–23**: פנויים (אזור hook integrity ראשוני)
- **26–30**: פנויים (אזור בטיחות מוקדם)
- **43–45**: פנויים (אזור בדיקות)
- **55–57**: פנויים
- **66, 71–73, 77, 79**: פנויים
- **82, 84–87**: פנויים
- **105**: פנוי

---

## פרוטוקול הוספת שער חדש

```
1. בדוק "הבא הפנוי" בראש המסמך
2. הוסף שורה לטבלה המתאימה
3. עדכן "הבא הפנוי" ל-N+1
4. הוסף לתוך .githooks/pre-commit עם comment: # שער N: <תיאור>
5. cp .githooks/pre-commit .git/hooks/pre-commit
6. commit כולל שינויי hook + GATE_REGISTRY.md ביחד
```

> **אחרי rebase:** תמיד `grep -oE "שער [0-9]+" .githooks/pre-commit | sort | uniq -d`
> לבדיקת קולידה. אם יש כפילות — renumber לפני push.
