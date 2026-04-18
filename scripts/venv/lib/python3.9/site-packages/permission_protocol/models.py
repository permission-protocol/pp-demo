from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Dict, Optional


def _parse_datetime(value: Optional[str]) -> Optional[datetime]:
    if value is None:
        return None
    normalized = value.replace("Z", "+00:00")
    dt = datetime.fromisoformat(normalized)
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt


@dataclass(frozen=True)
class Config:
    api_key: str
    base_url: str = "https://app.permissionprotocol.com"


@dataclass(frozen=True)
class Receipt:
    id: str
    status: str
    action: str
    resource: str
    actor: str
    approved_by: Optional[str] = None
    policy: Optional[str] = None
    signature: Optional[str] = None
    issuer: str = "permission-protocol"
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    expires_at: Optional[datetime] = None
    url: str = ""
    valid: bool = False

    @classmethod
    def from_dict(cls, payload: Dict[str, Any], *, default_url: str = "") -> "Receipt":
        return cls(
            id=payload.get("id") or payload.get("receiptId") or payload.get("requestId") or "",
            status=payload.get("status", "PENDING"),
            action=payload.get("action", ""),
            resource=payload.get("resource", ""),
            actor=payload.get("actor", ""),
            approved_by=payload.get("approvedBy") or payload.get("approved_by"),
            policy=payload.get("policy"),
            signature=payload.get("signature"),
            issuer=payload.get("issuer", "permission-protocol"),
            timestamp=_parse_datetime(payload.get("timestamp") or payload.get("createdAt"))
            or datetime.now(timezone.utc),
            expires_at=_parse_datetime(payload.get("expiresAt") or payload.get("expires_at")),
            url=payload.get("url") or payload.get("approvalUrl") or default_url,
            valid=bool(payload.get("valid", False)),
        )

    def json(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "status": self.status,
            "action": self.action,
            "resource": self.resource,
            "actor": self.actor,
            "approved_by": self.approved_by,
            "policy": self.policy,
            "signature": self.signature,
            "issuer": self.issuer,
            "timestamp": self.timestamp.isoformat(),
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "url": self.url,
            "valid": self.valid,
        }

    def __str__(self) -> str:
        return f"Receipt<{self.id} {self.status}>"

    def __repr__(self) -> str:
        return (
            "Receipt("
            f"id={self.id!r}, status={self.status!r}, action={self.action!r}, "
            f"resource={self.resource!r}, actor={self.actor!r}, valid={self.valid!r}"
            ")"
        )
