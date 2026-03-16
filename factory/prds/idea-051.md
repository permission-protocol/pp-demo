# PRD: idea-051 — Mobile Tab Labels Fix

**Issue:** permission-protocol/app#126  
**Priority:** P2  
**Repo:** permission-protocol/app

## Problem
On mobile (390px), tab bar shows "Repositori..." — truncated labels.

## Requirements
- On screens < 640px: abbreviate tab labels
  - "Dashboard" → "Dashboard" (fits)
  - "Deploy Queue" → "Queue"
  - "Repositories" → "Repos"
  - "Deploy Providers" → "Providers"
  - "API Keys" → "Keys"
  - "Setup" → "Setup" (fits)
- Keep icons visible on all breakpoints
- Tab bar should scroll horizontally if still too wide (overflow-x-auto)

## Must NOT Do
- Don't change desktop tab labels
- Don't remove any tabs
