---
id: pun-ed88
status: in_progress
deps: [pun-7201]
created: 2026-02-25T23:49:01Z
type: task
priority: 2
---
# Decommission punchlist-server

Once the iOS client talks directly to ko serve, punchlist-server is dead code.

- Stop and disable the punchlist systemd unit on ratched
- Archive or delete the punchlist-server repo
- Remove any DNS / reverse proxy pointing at punch.gisi.network
  (or redirect to knockout.gisi.network)
- Update Punchlist API Surface doc in exocortex notes

## Notes

**2026-02-26 05:55:30 UTC:** Question: After archiving punchlist-server locally, should we delete the directory or keep it?
Answer: Delete the directory
Removes the punchlist-server directory entirely to clean up the projects folder

**2026-02-26 05:55:30 UTC:** Question: Should we continue mirroring punchlist-server to GitHub, or stop the mirror in the forge config?
Answer: Keep mirroring active
Leave the forge config unchanged; punchlist-server continues to mirror to GitHub

## Completion Summary

**2026-02-26 07:08:00 UTC:**
- ✅ Systemd service already decommissioned in commit 4c3bf81 (apps/punchlist/default.nix deleted, removed from ratched manifest)
- ✅ No punchlist-server repo directory exists locally (nothing to delete)
- ✅ Exocortex API Surface doc already updated to document ko-based API (knockout.gisi.network)
- ✅ GitHub mirror preserved in forge config per decision
- ⚠️ Cannot verify systemd service disabled on ratched (fort SSH key not available in environment)
