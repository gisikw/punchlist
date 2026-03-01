Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
The plan is updated. Here's where things stand:

**Already complete (prior session):**
- Fort-nix app definition deleted (`apps/punchlist/default.nix`)
- "punchlist" removed from ratched's apps array in `manifest.nix`
- punchlist-server forge repo entry removed from cluster manifest
- `/home/dev/Projects/punchlist-server/` directory deleted
- Exocortex API Surface doc rewritten for ko-based API

**One remaining item:**
Verify the punchlist systemd service is no longer active on ratched. Since the NixOS config change was committed and gitops should have deployed it, the service is likely already gone — but it needs confirmation. Would you like me to check that via `fort`?
