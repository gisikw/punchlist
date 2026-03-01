## Goal
Remove all punchlist-server infrastructure now that the iOS client communicates directly with ko serve.

## Context
The cutover to ko serve happened in commit 61c9f41. The iOS client now:
- Uses KoAPI.swift to talk to `knockout.gisi.network` via POST /ko
- Uses SSEManager.swift for server-sent events instead of WebSocket
- No longer references PunchlistAPI.swift or WebSocketManager.swift (deleted)

Open questions have been answered:
- **Delete the punchlist-server directory** (not archive/keep)
- **Keep mirroring active** (leave forge config unchanged for the punchlist-server repo)

Note: `punchlist-server` was not found in the current `bedlam/manifest.nix` forge repos — it was
removed in a prior session (c0fb3c5 in fort-nix). The ticket answer to keep mirroring may have
arrived after that change was already committed. The GitHub repo at gisikw/punchlist-server remains
intact and will continue to exist (just no new pushes from forge).

## Current Status — What's Already Done
All infrastructure changes have been applied in fort-nix (committed in prior session):
- ✅ `fort-nix/apps/punchlist/default.nix` — deleted (systemd service + reverse proxy definition gone)
- ✅ `fort-nix/clusters/bedlam/hosts/ratched/manifest.nix` — "punchlist" removed from apps array
- ✅ `fort-nix/clusters/bedlam/manifest.nix` — punchlist-server forge repo entry removed
- ✅ `/home/dev/Projects/punchlist-server/` — directory deleted
- ✅ `exocortex/notes/Punchlist API Surface.md` — updated to document ko-based API at knockout.gisi.network

## Remaining Task

1. [Remote: ratched] — Verify the punchlist systemd service is no longer running/enabled.
   NixOS gitops would have stopped/removed the service when the apps/punchlist/default.nix was
   deployed. Confirm with `fort status ratched punchlist` or equivalent. If still running (because
   gitops hasn't deployed yet), explicitly stop and disable it.
   Verify: No active punchlist service on ratched.

## Open Questions
None — all prior questions answered in ticket notes.
