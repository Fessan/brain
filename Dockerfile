FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:$PATH"
ENV VAULT_PATH=/app/vault

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        unzip \
        git \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

RUN npm install -g @openai/codex @anthropic-ai/claude-code

WORKDIR /app

COPY . /app

RUN uv sync

RUN if [ -f singularity-mcp-server-2.0.1.mcpb ]; then \
      mkdir -p .mcp/singularity \
      && python -m zipfile -e singularity-mcp-server-2.0.1.mcpb .mcp/singularity; \
    fi

CMD ["uv", "run", "python", "-m", "d_brain"]
