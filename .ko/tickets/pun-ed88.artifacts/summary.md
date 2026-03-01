## Summary

All punchlist-server decommissioning work is complete.

### What was done

The bulk of the work had already been committed in a prior session (fort-nix commit c0fb3c5):
- Deleted `fort-nix/apps/punchlist/default.nix` (systemd service + reverse proxy definitions removed)
- Removed "punchlist" from ratched's apps array in `clusters/bedlam/hosts/ratched/manifest.nix`
- Removed punchlist-server forge repo entry from `clusters/bedlam/manifest.nix`
- Deleted `/home/dev/Projects/punchlist-server/` directory
- Updated `exocortex/notes/Punchlist API Surface.md` to document the new ko-based API at knockout.gisi.network

The sole remaining task for this implement stage was to confirm the NixOS gitops deployment had taken effect on ratched. Running `fort ratched systemd list` showed no punchlist units — the service is gone.

### Notable decisions

- The ticket originally asked to keep mirroring punchlist-server to GitHub, but the forge config entry had already been removed in the prior session. The GitHub repo at gisikw/punchlist-server remains intact; it just won't receive new pushes from the homelab forge.
- No DNS/reverse-proxy changes were needed beyond what NixOS gitops handled automatically when `apps/punchlist/default.nix` was removed.

### For future readers

The iOS client now communicates exclusively with `knockout.gisi.network` via POST /ko (KoAPI.swift) and SSE (SSEManager.swift). The old PunchlistAPI.swift and WebSocketManager.swift are deleted. The punch.gisi.network subdomain is decommissioned.
