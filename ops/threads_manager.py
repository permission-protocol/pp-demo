#!/usr/bin/env python3

from __future__ import annotations

import argparse
import copy
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml

VALID_STATUSES = {"ACTIVE", "BLOCKED", "PARKED", "EXPIRED", "ARCHIVED"}
THREAD_FIELDS = {
    "id",
    "title",
    "channel",
    "status",
    "owner",
    "priority",
    "created_at",
    "updated_at",
    "expires_at",
    "blocked_reason",
    "blocked_until",
    "next_action",
    "resolution_artifact",
    "archived_at",
    "summary",
    "open_tasks",
    "decisions",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def normalize_scalar(value: Any) -> Any:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.astimezone(timezone.utc).strftime("%Y-%m-%d")
    if isinstance(value, dict):
        return "; ".join(f"{key}: {item}" for key, item in value.items())
    return str(value)


def normalize_list(values: Any) -> list[str]:
    if values in (None, ""):
        return []
    return [normalize_scalar(item) for item in values]


def migrate_thread(thread: dict[str, Any]) -> dict[str, Any]:
    legacy = copy.deepcopy(thread)
    status = normalize_scalar(legacy.get("status") or "ACTIVE").upper()
    status = {"WAITING": "BLOCKED", "READY_TO_ARCHIVE": "PARKED"}.get(status, status)
    if status not in VALID_STATUSES:
        status = "ACTIVE"

    open_tasks = normalize_list(legacy.get("open_tasks"))
    next_action = normalize_scalar(legacy.get("next_action")) or (open_tasks[0] if open_tasks else None)
    if status == "ARCHIVED":
        next_action = None

    blocked_reason = normalize_scalar(legacy.get("blocked_reason"))
    if status == "BLOCKED" and not blocked_reason:
        blocked_reason = "Needs explicit unblock decision"

    return {
        "id": normalize_scalar(legacy.get("id")),
        "title": normalize_scalar(legacy.get("title")),
        "channel": normalize_scalar(legacy.get("channel")),
        "status": status,
        "owner": normalize_scalar(legacy.get("owner")),
        "priority": normalize_scalar(legacy.get("priority") or "medium"),
        "created_at": normalize_scalar(legacy.get("created_at") or legacy.get("created")),
        "updated_at": normalize_scalar(legacy.get("updated_at") or legacy.get("last_updated") or utc_now()),
        "expires_at": normalize_scalar(legacy.get("expires_at")),
        "blocked_reason": blocked_reason,
        "blocked_until": normalize_scalar(legacy.get("blocked_until")),
        "next_action": next_action,
        "resolution_artifact": normalize_scalar(legacy.get("resolution_artifact")),
        "archived_at": normalize_scalar(legacy.get("archived_at")),
        "summary": normalize_scalar(legacy.get("summary") or ""),
        "open_tasks": open_tasks,
        "decisions": normalize_list(legacy.get("decisions")),
    }


def load_threads(path: Path) -> dict[str, Any]:
    data = yaml.safe_load(path.read_text()) or {}
    if not isinstance(data, dict) or not isinstance(data.get("threads"), list):
        raise ValueError("Top-level YAML must be a mapping with a 'threads' list")
    return data


def dump_threads(path: Path, data: dict[str, Any]) -> None:
    path.write_text(yaml.safe_dump(data, sort_keys=False, allow_unicode=False))


def validate_thread(thread: dict[str, Any], index: int) -> None:
    extra = set(thread) - THREAD_FIELDS
    missing = THREAD_FIELDS - set(thread)
    if extra:
        raise ValueError(f"threads[{index}] has unsupported fields: {sorted(extra)}")
    if missing:
        raise ValueError(f"threads[{index}] is missing required fields: {sorted(missing)}")

    for key in ("id", "title", "channel", "owner", "priority", "created_at", "updated_at", "summary"):
        if not isinstance(thread[key], str) or not thread[key].strip():
            raise ValueError(f"threads[{index}].{key} must be a non-empty string")

    if thread["status"] not in VALID_STATUSES:
        raise ValueError(f"threads[{index}].status must be one of {sorted(VALID_STATUSES)}")

    for key in ("expires_at", "blocked_reason", "blocked_until", "next_action", "resolution_artifact", "archived_at"):
        if thread[key] is not None and not isinstance(thread[key], str):
            raise ValueError(f"threads[{index}].{key} must be a string or null")

    if not isinstance(thread["open_tasks"], list) or any(not isinstance(item, str) for item in thread["open_tasks"]):
        raise ValueError(f"threads[{index}].open_tasks must be a list of strings")
    if not isinstance(thread["decisions"], list) or any(not isinstance(item, str) for item in thread["decisions"]):
        raise ValueError(f"threads[{index}].decisions must be a list of strings")

    if thread["status"] == "BLOCKED" and not thread["blocked_reason"]:
        raise ValueError(f"threads[{index}].blocked_reason is required when status=BLOCKED")
    if thread["status"] != "BLOCKED" and (thread["blocked_reason"] or thread["blocked_until"]):
        raise ValueError(f"threads[{index}] cannot keep blocked fields unless status=BLOCKED")
    if thread["status"] == "ARCHIVED" and thread["next_action"] is not None:
        raise ValueError(f"threads[{index}].next_action must be null when status=ARCHIVED")


def command_validate(path: Path) -> int:
    data = load_threads(path)
    for idx, thread in enumerate(data["threads"]):
        validate_thread(thread, idx)
    print(f"VALID {len(data['threads'])} threads")
    return 0


def command_migrate(path: Path, write: bool) -> int:
    data = load_threads(path)
    migrated = {"threads": [migrate_thread(thread) for thread in data["threads"]]}
    for idx, thread in enumerate(migrated["threads"]):
        validate_thread(thread, idx)
    if write:
        dump_threads(path, migrated)
    else:
        sys.stdout.write(yaml.safe_dump(migrated, sort_keys=False, allow_unicode=False))
    return 0


def command_archive(path: Path, thread_id: str, artifact: str) -> int:
    data = load_threads(path)
    for thread in data["threads"]:
        if str(thread["id"]) != thread_id:
            continue
        thread["status"] = "ARCHIVED"
        thread["updated_at"] = utc_now()
        thread["blocked_reason"] = None
        thread["blocked_until"] = None
        thread["next_action"] = None
        thread["resolution_artifact"] = artifact
        break
    else:
        raise ValueError(f"Thread {thread_id} not found")

    for idx, thread in enumerate(data["threads"]):
        validate_thread(thread, idx)
    dump_threads(path, data)
    print(f"ARCHIVED {thread_id}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Strict manager for ops/threads.yaml")
    subparsers = parser.add_subparsers(dest="command", required=True)

    validate_parser = subparsers.add_parser("validate")
    validate_parser.add_argument("path", nargs="?", default="ops/threads.yaml")

    migrate_parser = subparsers.add_parser("migrate")
    migrate_parser.add_argument("path", nargs="?", default="ops/threads.yaml")
    migrate_parser.add_argument("--write", action="store_true")

    archive_parser = subparsers.add_parser("archive")
    archive_parser.add_argument("--path", default="ops/threads.yaml")
    archive_parser.add_argument("--thread-id", required=True)
    archive_parser.add_argument("--resolution-artifact", required=True)

    args = parser.parse_args()

    try:
        if args.command == "validate":
            return command_validate(Path(args.path))
        if args.command == "migrate":
            return command_migrate(Path(args.path), args.write)
        return command_archive(Path(args.path), args.thread_id, args.resolution_artifact)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
