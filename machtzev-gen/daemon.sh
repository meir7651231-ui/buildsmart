#!/bin/bash
# 🏔️🔁 daemon — מריץ את המחולל בלי-הפסק: מנוע-אקראי → שדרוג → הוכחה → ledger, כל ~3ש'.
# עצירה: touch /tmp/quarry-iso/STOP. כל הריצה ב-/tmp, ריפו-חיים read-only.
cd /tmp/quarry-iso/machtzev/generator || exit 1
LEDGER=daemon-ledger.txt
echo "[$(date +%H:%M:%S)] 🔁 דמון-המחולל עלה (PID $$)" >> "$LEDGER"
i=0
while [ ! -f /tmp/quarry-iso/STOP ]; do
  i=$((i+1))
  L=$(timeout 30 node gen-max.mjs --random --emit --verifymax 2>&1 | grep "^LEDGER" | head -1)
  if [ -z "$L" ]; then
    echo "[$(date +%H:%M:%S)] #$i · ריק/timeout" >> "$LEDGER"
  else
    echo "[$(date +%H:%M:%S)] #$i · ${L#LEDGER|}" >> "$LEDGER"
  fi
  sleep 3
done
echo "[$(date +%H:%M:%S)] 🛑 דמון נעצר (STOP) אחרי $i מנועים" >> "$LEDGER"
