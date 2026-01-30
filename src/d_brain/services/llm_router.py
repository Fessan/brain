"""In-memory LLM provider selection per user."""

from enum import StrEnum


class LLMProvider(StrEnum):
    """Supported LLM backends."""

    CODEX = "codex"
    CLAUDE = "claude"


_user_providers: dict[int, LLMProvider] = {}


def get_provider(user_id: int | None) -> LLMProvider:
    """Return provider for user, defaulting to Codex."""
    if user_id is None:
        return LLMProvider.CODEX
    return _user_providers.get(user_id, LLMProvider.CODEX)


def toggle_provider(user_id: int | None) -> LLMProvider:
    """Toggle provider for user and return the new selection."""
    if user_id is None:
        return LLMProvider.CODEX
    current = get_provider(user_id)
    new_provider = (
        LLMProvider.CLAUDE if current == LLMProvider.CODEX else LLMProvider.CODEX
    )
    _user_providers[user_id] = new_provider
    return new_provider
