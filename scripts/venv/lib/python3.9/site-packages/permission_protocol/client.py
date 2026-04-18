from __future__ import annotations

import socket
import time
import urllib.error
import urllib.parse
import urllib.request
import json as jsonlib
from typing import Any, Dict, Optional

try:
    import httpx  # type: ignore
except ImportError:  # pragma: no cover - exercised in minimal environments
    httpx = None

from .exceptions import APIError, AuthenticationError, PermissionDenied, PermissionTimeout
from .models import Config, Receipt


class PermissionProtocolClient:
    def __init__(self, config: Config):
        self._config = config
        self._base_url = config.base_url.rstrip("/")
        self._client = httpx.Client(base_url=self._base_url, timeout=10.0) if httpx else None

    def close(self) -> None:
        if self._client is not None:
            self._client.close()

    def authorize(
        self,
        *,
        action: str,
        resource: str,
        actor: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None,
        wait: bool = True,
        timeout: int = 300,
    ) -> Receipt:
        actor_value = actor or socket.gethostname()
        scope: Dict[str, Any] = {
            "action": action,
            "resource": resource,
            "actor": actor_value,
        }
        if metadata is not None:
            scope["metadata"] = metadata

        payload = {"scope": scope, "failOnMissing": True}
        data = self._request("POST", "/api/v1/receipts/verify", json=payload)

        approval_url = data.get("approvalUrl", "")
        receipt_payload = data.get("receipt")
        request_id = data.get("requestId")

        if receipt_payload:
            receipt = Receipt.from_dict(receipt_payload, default_url=approval_url)
        else:
            receipt = Receipt(
                id=request_id or "",
                status="PENDING",
                action=action,
                resource=resource,
                actor=actor_value,
                url=approval_url,
                valid=bool(data.get("valid", False)),
            )

        if not wait:
            return receipt

        if approval_url:
            print(f"Approval required: {approval_url}")

        if receipt.status in {"APPROVED", "DENIED", "EXPIRED"}:
            return self._handle_terminal_receipt(receipt)

        if not receipt.id:
            raise APIError("API response missing request/receipt ID")

        return self._poll_for_decision(receipt.id, timeout=timeout)

    def verify(self, *, receipt_id: str) -> Receipt:
        receipt = self.get_receipt(receipt_id)
        verification_data: Dict[str, Any] = {}
        try:
            verification_data = self._request(
                "POST",
                "/api/v1/receipts/verify",
                json={"receiptId": receipt_id, "failOnMissing": True},
            )
        except APIError:
            verification_data = {}

        valid = bool(verification_data.get("valid", receipt.valid))
        receipt_payload = verification_data.get("receipt")
        if receipt_payload:
            parsed = Receipt.from_dict(receipt_payload, default_url=receipt.url)
            return Receipt(
                id=parsed.id,
                status=parsed.status,
                action=parsed.action,
                resource=parsed.resource,
                actor=parsed.actor,
                approved_by=parsed.approved_by,
                policy=parsed.policy,
                signature=parsed.signature,
                issuer=parsed.issuer,
                timestamp=parsed.timestamp,
                expires_at=parsed.expires_at,
                url=parsed.url,
                valid=valid,
            )

        return Receipt(
            id=receipt.id,
            status=receipt.status,
            action=receipt.action,
            resource=receipt.resource,
            actor=receipt.actor,
            approved_by=receipt.approved_by,
            policy=receipt.policy,
            signature=receipt.signature,
            issuer=receipt.issuer,
            timestamp=receipt.timestamp,
            expires_at=receipt.expires_at,
            url=receipt.url,
            valid=valid,
        )

    def get_receipt(self, receipt_id: str) -> Receipt:
        data = self._request("GET", f"/api/v1/receipts/{receipt_id}")
        return Receipt.from_dict(data)

    def _poll_for_decision(self, receipt_id: str, *, timeout: int) -> Receipt:
        deadline = time.monotonic() + timeout
        delay = 2.0

        while True:
            receipt = self.get_receipt(receipt_id)
            if receipt.status == "APPROVED":
                return receipt
            if receipt.status in {"DENIED", "EXPIRED"}:
                raise PermissionDenied(
                    f"Authorization {receipt.status.lower()} for receipt {receipt.id}"
                )

            if time.monotonic() >= deadline:
                raise PermissionTimeout(f"Timed out waiting for approval: {receipt_id}")

            sleep_for = min(delay, max(deadline - time.monotonic(), 0.0))
            if sleep_for > 0:
                time.sleep(sleep_for)
            delay = min(delay * 2.0, 10.0)

    def _handle_terminal_receipt(self, receipt: Receipt) -> Receipt:
        if receipt.status == "APPROVED":
            return receipt
        if receipt.status in {"DENIED", "EXPIRED"}:
            raise PermissionDenied(
                f"Authorization {receipt.status.lower()} for receipt {receipt.id}"
            )
        return receipt

    def _request(self, method: str, path: str, **kwargs: Any) -> Dict[str, Any]:
        headers = kwargs.pop("headers", {})
        headers["X-PP-API-Key"] = self._config.api_key

        attempts = 0
        max_attempts = 3
        backoff = 0.5

        while True:
            attempts += 1
            try:
                response = self._send_request(method, path, headers=headers, **kwargs)
            except Exception as exc:
                if attempts >= max_attempts:
                    raise APIError(f"Request failed: {exc}") from exc
                time.sleep(backoff)
                backoff = min(backoff * 2.0, 2.0)
                continue

            if response.status_code == 401:
                raise AuthenticationError("Invalid Permission Protocol API key")

            if response.status_code >= 500 and attempts < max_attempts:
                time.sleep(backoff)
                backoff = min(backoff * 2.0, 2.0)
                continue

            if response.status_code >= 400:
                raise APIError(f"API request failed ({response.status_code}): {response.text}")

            try:
                parsed = response.json()
            except ValueError as exc:
                raise APIError("API returned non-JSON response") from exc

            if not isinstance(parsed, dict):
                raise APIError("API returned unexpected response payload")

            return parsed

    def _send_request(self, method: str, path: str, **kwargs: Any) -> Any:
        if self._client is not None:
            return self._client.request(method, path, **kwargs)
        return self._urllib_request(method, path, **kwargs)

    def _urllib_request(self, method: str, path: str, **kwargs: Any) -> Any:
        headers = kwargs.get("headers", {})
        payload = kwargs.get("json")
        data = None
        if payload is not None:
            data = jsonlib.dumps(payload).encode("utf-8")
            headers = {**headers, "Content-Type": "application/json"}

        url = urllib.parse.urljoin(f"{self._base_url}/", path.lstrip("/"))
        request = urllib.request.Request(url=url, data=data, headers=headers, method=method.upper())
        try:
            with urllib.request.urlopen(request, timeout=10.0) as response:
                body = response.read().decode("utf-8")
                return _UrllibResponse(response.getcode(), body)
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="replace") if exc.fp else str(exc)
            return _UrllibResponse(exc.code, body)
        except urllib.error.URLError as exc:
            raise APIError(f"Network error: {exc}") from exc


class _UrllibResponse:
    def __init__(self, status_code: int, text: str):
        self.status_code = status_code
        self.text = text

    def json(self) -> Any:
        return jsonlib.loads(self.text)
