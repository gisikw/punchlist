---
id: pun-8b2d
status: open
deps: [pun-6a33]
created: 2026-02-25T23:48:22Z
type: task
priority: 1
---
# Replace WebSocket with SSE from ko serve

Replace WebSocketManager with an SSE client that connects to
`GET /subscribe/#project` on knockout.gisi.network.

## What changes

- New SSEManager replaces WebSocketManager
- SSE endpoint: `https://knockout.gisi.network/subscribe/%23{slug}`
- On project switch: disconnect current SSE, connect to new project stream
- SSE events trigger a re-fetch of the item list via `ko ls --project --json`
  (SSE is a change notification, not a full state broadcast like the old WS)
- Reconnect logic: same pattern as current WS (retry on disconnect)
- Polling fallback stays as-is (just points at new KoAPI.fetchItems)

## Assumptions (to verify)

- SSE stream sends an event on any ticket mutation in the project
- Event format TBD — may just be a ping, or may include the mutation details
- Connection uses standard EventSource semantics (text/event-stream)
