#!/bin/bash
# 🏔️ autoloop — עבודת-מחולל רציפה כל 10 שניות: סורק --maxall, מרכיב דומיין-מתחלף, מוכיח, מתעד.
# עצירה: touch /tmp/quarry-iso/STOP · הכל ב-/tmp, ריפו-חיים read-only.
cd /tmp/quarry-iso/machtzev/generator || exit 1
LOG=autoloop-ledger.txt; touch "$LOG"
DOMS=(courses supporters shop home calendar families tzedaka platform reports telephony diary wall shop7 shop8 timer builder settings public)
echo "[$(date +%H:%M:%S)] 🏔️ autoloop עלה (PID $$) · חימוש כל 10ש'" >> "$LOG"
i=0
while [ ! -f /tmp/quarry-iso/STOP ]; do
  i=$((i+1))
  d=${DOMS[$((i % ${#DOMS[@]}))]}
  r=$(timeout 25 node gen-max.mjs --domain=$d 2>&1 | grep "^DOMAIN" | sed 's/^DOMAIN|//')
  echo "[$(date +%H:%M:%S)] #$i · ${r:-timeout}" >> "$LOG"
  sleep 10
done
echo "[$(date +%H:%M:%S)] 🛑 autoloop נעצר אחרי $i סבבים" >> "$LOG"
