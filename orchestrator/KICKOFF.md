# KICKOFF — paste-once launch block (so you never re-explain the swarm)

Two ways to launch. Both run the **same** flattened fleet — pick whichever fits the session.

---

## A) One command (this repo, Claude Code)
```
/swarm <SSOT path or one-line task>
```
e.g. `/swarm knowledge/LAUNCH-TASKS-MICRO.md`
(The `/swarm` skill lives at `.claude/skills/swarm/SKILL.md` and carries the full pipeline.)

---

## B) Paste-once prompt (any agent, any session — no skill needed)
Copy this verbatim, fill the two `<…>`, send. Nothing else to explain.

```
הפעל את הנחיל (flattened orchestration). אל תסביר — בצע.

מוח/charter:  orchestrator/PLAYBOOK.md   (טען כהוראות-מערכת)
תפקידים:      .claude/agents/  → auditor · validator · fixer · supervisor
משימה (SSOT): <נתיב-למסמך-המשימה>
ענף:          <branch>
שער:          orchestrator/scripts/central-verify.sh app_flutter \
                --assert         orchestrator/manifests/buildsmart.conformance.txt \
                --required-tests orchestrator/manifests/buildsmart.required-tests.txt

זרימה (בצע בסדר, בלי לנמק אופציות):
1. קרא SSOT → פרק ליחידות.
2. פזר auditors במקביל — עדשה נפרדת לכל אחד (orchestrator/lenses/registry.txt).
3. validators → אמת כל ממצא מול הקוד החי, זרוק false-positives.
4. חלק לפי קובץ (disjoint) → fixers במקביל, עריכה בלבד.
5. grep-verify על כל תיקון — אמת בייטים, לא "בוצע".
6. הרץ את השער (למעלה). חייב: analyze=0 + כל הבדיקות + build + conformance.
7. mutation-verify לבדיקות קריטיות (הזרק באג → אדום → שחזר → ירוק).
8. supervisor יחיד מאמת אובייקטיבית ומדווח דוח-אמת אחד למעלה.
9. רק על ירוק: commit (pre-commit hook = השערים) → orchestrator/scripts/ff-push.sh <branch>.
10. אחרי כל גל: push + ckpt + registry assert-none-open (אפס סוכנים יתומים).

כללי-ברזל: אמת בייטים לא פרוזה · שלח רק על ירוק · דחוף רק על "תדחוף" · דילוג = רועש.
```

---

## What it is (honesty)
Same flattened fleet as always — one orchestrator spawns every sub-agent directly. Not a new capability,
not external software. It only removes the re-explaining. Nested-tree swarm needs the Claude Agent SDK
(`FACTORY.md`, `NESTING_SUPPORTED=no` in this harness).
