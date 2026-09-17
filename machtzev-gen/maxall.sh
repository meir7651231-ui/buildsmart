#!/bin/bash
# 🏔️ maxall — עובר שיטתית על כל 867 המנועים, פותר-fixpoint לכל אחד, כותב תוצאה. ניתן-להמשך (מדלג על שנעשו).
# עצירה: touch /tmp/quarry-iso/STOP
cd /tmp/quarry-iso/machtzev/generator || exit 1
LEDGER=maxall-ledger.txt; touch "$LEDGER"
echo "[$(date +%H:%M:%S)] 🏔️ maxall עלה (PID $$)" >> "$LEDGER"
done_names=$(sed -E 's/^[^|]*\| *//; s/ .*//' "$LEDGER" 2>/dev/null)
while read -r nm; do
  [ -f /tmp/quarry-iso/STOP ] && { echo "[$(date +%H:%M:%S)] 🛑 עצור" >> "$LEDGER"; break; }
  [ -z "$nm" ] && continue
  grep -q "| $nm " "$LEDGER" 2>/dev/null && continue   # כבר-נעשה ⇒ דלג (המשכיות)
  v=$(timeout 25 node gen-max.mjs "$nm" --emit --verifymax 2>&1 | grep "^LEDGER" | head -1 | sed 's/^LEDGER|[^|]*|//')
  echo "$(date +%H:%M:%S) | $nm ${v:-timeout}" >> "$LEDGER"
done < all-engines.txt
echo "[$(date +%H:%M:%S)] ✅ maxall סיים מעבר על כל המנועים" >> "$LEDGER"
