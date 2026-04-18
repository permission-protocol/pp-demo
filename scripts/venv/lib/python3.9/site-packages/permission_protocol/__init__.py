from __future__ import annotations

import os
import threading
from typing import Any, Dict, Optional

from ._version import __version__
from .decorator import require_approval
from .exceptions import (
    APIError,
    AuthenticationError,
    PermissionDenied,
    PermissionProtocolError,
    PermissionTimeout,
)
from .models import Config, Receipt

__all__ = [
    "__version__",
    "configure",
    "authorize",
    "verify",
    "require_approval",
    "Receipt",
    "PermissionProtocolError",
    "PermissionDenied",
    "PermissionTimeout",
    "AuthenticationError",
    "APIError",
]

_lock = threading.Lock()
_config: Optional[Config] = None


def configure(*, api_key: str, base_url: str = "https://app.permissionprotocol.com") -> None:
    global _config
    with _lock:
        _config = Config(api_key=api_key, base_url=base_url)


def _resolve_config() -> Config:
    with _lock:
        if _config is not None:
            return _config

    api_key = os.getenv("PP_API_KEY")
    if not api_key:
        raise AuthenticationError(
            "Permission Protocol API key is required. "
            "Call configure(api_key=...) or set PP_API_KEY."
        )

    base_url = os.getenv("PP_BASE_URL", "https://app.permissionprotocol.com")
    return Config(api_key=api_key, base_url=base_url)


def authorize(
    *,
    action: str,
    resource: str,
    actor: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None,
    wait: bool = True,
    timeout: int = 300,
) -> Receipt:
    from .client import PermissionProtocolClient

    client = PermissionProtocolClient(_resolve_config())
    try:
        return client.authorize(
            action=action,
            resource=resource,
            actor=actor,
            metadata=metadata,
            wait=wait,
            timeout=timeout,
        )
    finally:
        client.close()


def verify(*, receipt_id: str) -> Receipt:
    from .client import PermissionProtocolClient

    client = PermissionProtocolClient(_resolve_config())
    try:
        return client.verify(receipt_id=receipt_id)
    finally:
        client.close()
