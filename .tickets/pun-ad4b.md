---
id: pun-ad4b
status: closed
deps: [pun-427b]
links: []
created: 2026-02-18T13:02:32Z
type: task
priority: 2
---
# WebSocket manager with reconnect

## Notes

**2026-02-18 13:02:54 UTC:** URLSessionWebSocketTask. Reconnect with exponential backoff (1s initial, 30s cap, reset on connect). Parses incoming messages as [Item] and pushes to callback/stream. Offline indicator after 3s disconnect.
