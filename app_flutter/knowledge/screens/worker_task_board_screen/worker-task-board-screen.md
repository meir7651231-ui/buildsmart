# WorkerTaskBoardScreen

- **screen:** `worker_task_board_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "🗂️ לוח משימות מלא" · `worker_task_board_screen.board_title` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `tasksProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `groupByStatus`
- `sort`
- `workerIndexForSession`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
