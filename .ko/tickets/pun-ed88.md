---
id: pun-ed88
status: open
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
