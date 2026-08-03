# WorkerTodayStrip

- **screen:** `worker_today_strip`
- **role:** composer

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "📅 היום שלי" · `worker.today.title` ✅
- **cfgText** "אין שלבי-יום מתוכננים עבורך בפרויקט" · `worker.today.empty` ✅
- **cfgText** "✅ כל שלבי-היום שלך בפרויקט הושלמו" · `worker.today.alldone` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `smartProjectProvider`
- **writes** · `toggle` → `smartProjectProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `buildDayStages`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `worker`
- **untangle:**
  - onSmartProject(…) callback instead of direct smartProjectProvider write
- **gaps:** none (all registry-backed)
