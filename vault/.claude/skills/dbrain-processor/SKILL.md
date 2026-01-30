---
name: second-brain-processor
description: Personal assistant for processing daily voice/text entries from Telegram. Classifies content, creates Singularity tasks aligned with goals, saves thoughts to Obsidian with wiki-links, generates HTML reports. Triggers on /process command or daily 21:00 cron.
---

# Second Brain Processor

Process daily entries → tasks (Singularity) + thoughts (Obsidian) + HTML report (Telegram).

## CRITICAL: Output Format

**ALWAYS return RAW HTML. No exceptions. No markdown. Ever.**

Your final output goes directly to Telegram with `parse_mode=HTML`.

Rules:
1. ALWAYS return HTML report — even if entries already processed
2. ALWAYS use the template below — no free-form text
3. NEVER use markdown syntax (**, ##, ```, -)
4. NEVER explain what you did in plain text — put it in HTML report

WRONG:
```html
<b>Title</b>
```

CORRECT:
<b>Title</b>

## MCP Tools Required

mcp__singularity__createTask — Create tasks
mcp__singularity__listTasks — Check duplicates/workload

## CRITICAL: MCP Tool Usage

**НИКАКИХ WORKAROUNDS. НИКАКИХ "добавь вручную". ТОЛЬКО ПРЯМЫЕ ВЫЗОВЫ.**

У тебя ЕСТЬ доступ к MCP tools:
- `mcp__singularity__createTask`
- `mcp__singularity__listTasks`
- `mcp__singularity__updateTask`
- `mcp__singularity__deleteTask`
- `mcp__singularity__getTask`
- `mcp__singularity__listProjects`

ЗАПРЕЩЕНО:
- Писать "MCP недоступен"
- Предлагать "добавь вручную"
- Использовать subprocess для вызова CLI
- Делать HTTP запросы к API напрямую
- Выводить команды для копирования

ОБЯЗАТЕЛЬНО:
- Вызывать `mcp__singularity__createTask` tool напрямую
- Если tool вернул ошибку — включить её в отчёт
- Если task создан — включить task ID в отчёт

При ошибке MCP tool — показать ТОЧНУЮ ошибку от tool, не придумывать отговорки.

## Processing Flow

1. Load context — Read goals/3-weekly.md (ONE Big Thing), goals/2-monthly.md
2. Check workload — listTasks with 7-day date range
3. Read daily — daily/YYYY-MM-DD.md
4. Process entries — Classify → task or thought
5. Build links — Connect notes with [[wiki-links]]
6. Generate HTML report — RAW HTML for Telegram

## Entry Format

## HH:MM [type]
Content

Types: [voice], [text], [forward from: Name], [photo]

## Classification

task → Singularity (see references/singularity.md)
idea/reflection/learning → thoughts/ (see references/classification.md)

## Priority Rules

Singularity uses numeric priorities:

0 — Client deadline, urgent
1 — Aligns with ONE Big Thing or monthly/yearly priority
2 — Operational, no goal alignment

## Thought Categories

💡 idea → thoughts/ideas/
🪞 reflection → thoughts/reflections/
🎯 project → thoughts/projects/
📚 learning → thoughts/learnings/

## HTML Report Template

Output RAW HTML (no markdown, no code blocks):

📊 <b>Обработка за {DATE}</b>

<b>🎯 Текущий фокус:</b>
{ONE_BIG_THING}

<b>📓 Сохранено мыслей:</b> {N}
• {emoji} {title} → {category}/

<b>✅ Создано задач:</b> {M}
• {task} <i>({priority}, {due})</i>

<b>📅 Загрузка на неделю:</b>
Пн: {n} | Вт: {n} | Ср: {n} | Чт: {n} | Пт: {n} | Сб: {n} | Вс: {n}

<b>⚠️ Требует внимания:</b>
• {overdue or stale goals}

<b>🔗 Новые связи:</b>
• [[Note A]] ↔ [[Note B]]

<b>⚡ Топ-3 приоритета:</b>
1. {task}
2. {task}
3. {task}

<b>📈 Прогресс:</b>
• {goal}: {%} {emoji}

---
<i>Обработано за {duration}</i>

## If Already Processed

If all entries have `<!-- ✓ processed -->` marker, return status report:

📊 <b>Статус за {DATE}</b>

<b>🎯 Текущий фокус:</b>
{ONE_BIG_THING}

<b>📅 Загрузка на неделю:</b>
Пн: {n} | Вт: {n} | Ср: {n} | Чт: {n} | Пт: {n} | Сб: {n} | Вс: {n}

<b>⚠️ Требует внимания:</b>
• {overdue count} просроченных
• {today count} на сегодня

<b>⚡ Топ-3 приоритета:</b>
1. {task}
2. {task}
3. {task}

---
<i>Записи уже обработаны ранее</i>

## Allowed HTML Tags

<b> — bold (headers)
<i> — italic (metadata)
<code> — commands, paths
<s> — strikethrough
<u> — underline
<a href="url">text</a> — links

## FORBIDDEN in Output

NO markdown: **, ##, -, *, backticks
NO code blocks (triple backticks)
NO tables
NO unsupported tags: div, span, br, p, table

Max length: 4096 characters.

## References

Read these files as needed:
- references/about.md — User profile, decision filters
- references/classification.md — Entry classification rules
- references/singularity.md — Task creation details
- references/goals.md — Goal alignment logic
- references/links.md — Wiki-links building
- references/rules.md — Mandatory processing rules
- references/report-template.md — Full HTML report spec
