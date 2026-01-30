# Singularity Integration

## Available MCP Tools

### Tasks
- `listTasks` — list tasks (filters: date range, project, parent)
- `createTask` — create new task
- `updateTask` — update existing task
- `deleteTask` — delete task
- `getTask` — get task by ID

### Projects
- `listProjects` — list projects
- `getProject` — get project by ID
- `createProject` — create project
- `updateProject` — update project
- `deleteProject` — delete project

---

## Pre-Creation Checklist

### 1. Check Workload (REQUIRED)

```
listTasks:
  startDateFrom: "YYYY-MM-DD"
  startDateTo: "YYYY-MM-DD"
  maxCount: 200
```

Build workload map:
```
Mon: 2 tasks
Tue: 4 tasks  <- overloaded
Wed: 1 task
Thu: 3 tasks  <- at limit
Fri: 2 tasks
Sat: 0 tasks
Sun: 0 tasks
```

### 2. Check Duplicates (REQUIRED)

There is no text search tool. Fetch recent tasks and compare titles:

```
listTasks:
  startDateFrom: "YYYY-MM-DD"  # last 30 days
  startDateTo: "YYYY-MM-DD"
  maxCount: 200
```

If similar exists -> mark as duplicate, do not create.

---

## Priority Rules

Singularity priorities are numeric:
- 0 = high
- 1 = normal
- 2 = low

### Priority Keywords

| Keywords in text | Priority |
|-----------------|----------|
| срочно, критично, дедлайн клиента | 0 |
| важно, приоритет, до конца недели | 1 |
| нужно, надо, не забыть | 1 |
| стратегическое, R&D, long-term | 2 |

### Apply Decision Filters for Priority Boost

If entry matches 2+ filters -> boost priority by 1 level (towards 0):
- Это масштабируется?
- Это можно автоматизировать?
- Это усиливает экспертизу/бренд?
- Это приближает к продукту/SaaS?

---

## Date Mapping

Use ISO dates in `start`. Optionally set `deadline`.

| Context | start |
|---------|-------|
| Client deadline | exact date |
| Urgent ops | today / tomorrow |
| This week | friday |
| Next week | next monday |
| Strategic/R&D | in 7 days |
| Not specified | in 3 days |

Compute the final ISO date and set `start` accordingly.

---

## Task Creation

```
createTask:
  task:
    title: "Task title"
    note: "Details or context"
    start: "YYYY-MM-DD"  # REQUIRED
    priority: 1
    projectId: "..."     # if known
```

Notes:
- Recurring tasks are NOT supported by the API.
- Keep titles short and concrete.

### Task Title Style

User prefers: прямота, ясность, конкретика.

Good:
- "Отправить презентацию клиенту"
- "Созвон с командой по проекту"
- "Написать пост про [тема]"

Bad:
- "Подумать о презентации"
- "Что-то с клиентом"
- "Разобраться с AI"

### Workload Balancing

If target day has 3+ tasks:
1. Find next day with < 3 tasks
2. Use that day instead
3. Mention in report: "сдвинуто на {day} (перегрузка)"

---

## Project Detection

Use `listProjects` and match by title. If unclear -> omit projectId.

---

## Anti-Patterns (НЕ СОЗДАВАТЬ)

- Абстрактные задачи без Next Action
- Дубликаты существующих задач
- Задачи без дат

---

## Error Handling

CRITICAL: Никогда не предлагай "добавить вручную".

If `createTask` fails:
1. Include EXACT error message in report
2. Continue with next entry
3. Do not mark as processed

Wrong output:
  "Не удалось добавить (MCP недоступен). Добавь вручную: Task title"

Correct output:
  "Ошибка создания задачи: [exact error from MCP tool]"
