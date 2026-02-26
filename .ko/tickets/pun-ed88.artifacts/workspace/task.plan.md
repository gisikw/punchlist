Plan written to `/home/dev/Projects/punchlist/.ko/tickets/pun-ed88.artifacts/plan.md`.

## Summary

The plan covers decommissioning punchlist-server infrastructure across three locations:

1. **Runtime infrastructure** (ratched host): Stop and disable the systemd service
2. **Configuration** (fort-nix): Remove the app definition, host app reference, and forge repo entry
3. **Code** (punchlist-server repo): Archive with deprecation notice
4. **Documentation** (exocortex notes): Update API surface doc to reflect ko-based API

**Two open questions** for you to decide:
1. Should we stop mirroring punchlist-server to GitHub, or just leave the forge config as-is?
2. After archiving, do you want to keep the local punchlist-server directory or delete it?
