---
id: pun-d9b3
status: closed
deps: [pun-4e44]
links: []
created: 2026-02-20T14:02:11Z
type: task
priority: 2
---
# Per-project WebSocket — connect/disconnect WS as user swipes between projects

## Notes

**2026-02-20 14:02:37 UTC:** Only maintain one WS connection at a time (the visible project). On swipe, disconnect old WS, connect new one. Initial data comes via REST on first visit, WS keeps it live. Cache last-seen state per project so swiping back feels instant even before WS reconnects.

**2026-02-20 14:03:54 UTC:** Not needed — simpler to send project selection over existing WS connection rather than connect/disconnect per project.
