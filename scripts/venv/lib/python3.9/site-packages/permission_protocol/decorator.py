from __future__ import annotations

from functools import wraps
from typing import Any, Callable, Dict, Optional, TypeVar

F = TypeVar("F", bound=Callable[..., Any])


def require_approval(
    *,
    resource: str,
    action: Optional[str] = None,
    actor: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None,
    timeout: int = 300,
) -> Callable[[F], F]:
    def decorator(func: F) -> F:
        chosen_action = action or func.__name__

        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            from . import authorize

            authorize(
                action=chosen_action,
                resource=resource,
                actor=actor,
                metadata=metadata,
                wait=True,
                timeout=timeout,
            )
            return func(*args, **kwargs)

        return wrapper  # type: ignore[return-value]

    return decorator
