# _StatusGroup

- **screen:** `worker_task_board_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "אין משימות במצב זה" · `worker_task_board_screen.empty_group` ✅

## חיבורים · connections (1)

- **action** · `showWorkerTaskDetailSheet` → `showWorkerTaskDetailSheet`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showWorkerTaskDetailSheet(context, taskId: task.id)` → open → showWorkerTaskDetailSheet

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `title` · `tasks`
- **gaps:** none (all registry-backed)
