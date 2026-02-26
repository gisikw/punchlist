## Goal
Remove all punchlist-server infrastructure now that the iOS client communicates directly with ko serve.

## Context
The cutover to ko serve happened in commit 61c9f41. The iOS client now:
- Uses KoAPI.swift to talk to `knockout.gisi.network` via POST /ko
- Uses SSEManager.swift for server-sent events instead of WebSocket
- No longer references PunchlistAPI.swift or WebSocketManager.swift (deleted)

The old punchlist-server infrastructure still exists:
- **fort-nix**: `/home/dev/Projects/fort-nix/apps/punchlist/default.nix` defines systemd service and reverse proxy
- **fort-nix**: `/home/dev/Projects/fort-nix/clusters/bedlam/hosts/ratched/manifest.nix` includes "punchlist" in apps array (line 17)
- **fort-nix**: `/home/dev/Projects/fort-nix/clusters/bedlam/manifest.nix` defines "punchlist-server" forge repo with GitHub mirror (lines 142-149)
- **punchlist-server repo**: `/home/dev/Projects/punchlist-server/` contains the Go server code
- **exocortex notes**: `/home/dev/Projects/exocortex/notes/Punchlist API Surface.md` documents the old API (server is `punch.gisi.network`)

The fort.cluster.services configuration in apps/punchlist/default.nix creates:
- Subdomain: punch.gisi.network
- Reverse proxy to localhost:8765
- Public visibility with Gatekeeper SSO

## Approach
Use the fort skill to stop the systemd service on ratched, then remove the infrastructure config from fort-nix. Archive the punchlist-server repo rather than deleting it (preserves history). Update the exocortex API doc to reflect the new ko-based surface.

## Tasks
1. [Remote: ratched] — Stop and disable the punchlist systemd service.
   Verify: `fort status ratched punchlist` shows service is inactive and disabled.

2. [/home/dev/Projects/fort-nix/apps/punchlist/default.nix] — Delete the entire file (no longer needed).
   Verify: File removed from working tree.

3. [/home/dev/Projects/fort-nix/clusters/bedlam/hosts/ratched/manifest.nix:17] — Remove "punchlist" from the apps array.
   Verify: grep for "punchlist" in manifest returns no matches.

4. [/home/dev/Projects/fort-nix/clusters/bedlam/manifest.nix:142-149] — Remove the "punchlist-server" forge repo entry.
   Verify: grep for "punchlist-server" in manifest returns no matches.

5. [/home/dev/Projects/punchlist-server/] — Archive the repo: add README explaining deprecation, commit final state, tag as archived.
   Verify: README contains deprecation notice and points to knockout, repo has "archived" tag.

6. [/home/dev/Projects/exocortex/notes/Punchlist API Surface.md] — Replace with documentation of the ko-based API surface.
   Document: POST /ko with argv for all commands (add, close, open, bump, triage), SSE endpoint for live updates.
   Verify: Doc reflects the KoAPI implementation from Punchlist/Services/KoAPI.swift.

## Open Questions
**Should we also remove the punchlist-server GitHub mirror from the forge config?**
The cluster manifest defines the punchlist-server repo with a GitHub mirror. Removing it from the forge config would stop mirroring, but the GitHub repo would remain intact. If we want to mark it as archived on GitHub as well, we'd need to use the GitHub API or web interface separately.

**Do you want to keep the punchlist-server local repo or delete it after archiving?**
The plan archives it (README + tag) but leaves it in place at `/home/dev/Projects/punchlist-server/`. If you want it gone entirely, we can delete the directory after archiving or move it to an archive location.
