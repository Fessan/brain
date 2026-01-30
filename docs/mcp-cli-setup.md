Стабильное подключение к MCP серверам через mcp-cli вместо прямого протокола.

## Зачем это нужно

MCP протокол напрямую иногда отваливается. mcp-cli решает эту проблему:

- **Connection pooling** - daemon держит соединения
- **Auto-retry** - автоматические повторы при сетевых ошибках
- **Стабильность** - работа через bash надёжнее чем MCP протокол напрямую

## Как это работает

```
До:
Claude/Codex -> MCP Protocol -> Singularity MCP Server -> Singularity API
        (отваливается)

После:
Claude/Codex -> Bash -> mcp-cli -> Singularity MCP Server -> Singularity API
                 (daemon, retry, pooling)
```

---

## Установка

### 1. Установите mcp-cli

```bash
curl -fsSL https://raw.githubusercontent.com/philschmid/mcp-cli/main/install.sh | bash
```

Проверка:
```bash
~/.local/bin/mcp-cli --version
# mcp-cli v0.3.0
```

### 2. Создайте конфиг

```bash
mkdir -p ~/.config/mcp
cat > ~/.config/mcp/mcp_servers.json << 'EOF'
{
  "mcpServers": {
    "singularity": {
      "command": "bash",
      "args": [
        "-lc",
        "node /path/to/agent-second-brain/.mcp/singularity/mcp.js --baseUrl https://api.singularity-app.com --accessToken \"$SINGULARITY_ACCESS_TOKEN\" -n"
      ]
    }
  }
}
EOF
```

Замените `/path/to/agent-second-brain` на путь к репозиторию.

### 3. Добавьте токен в shell

```bash
# Добавить в ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export SINGULARITY_ACCESS_TOKEN="ваш_токен"' >> ~/.bashrc
source ~/.bashrc
```

---

## Проверка

```bash
# Список инструментов
mcp-cli info singularity

# Задачи на неделю (пример диапазона дат)
mcp-cli call singularity listTasks '{"startDateFrom": "2026-01-01", "startDateTo": "2026-01-07"}'

# Создать задачу
mcp-cli call singularity createTask '{"task": {"title": "Тест задача", "start": "2026-01-02", "priority": 1}}'
```

---

## Требования

- Node.js 18+ (для MCP bundle)
- Singularity API Token (Pro/Elite)
