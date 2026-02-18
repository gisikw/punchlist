---
id: pun-291d
status: open
deps: [pun-ad4b]
links: []
created: 2026-02-18T13:02:37Z
type: task
priority: 2
---
# Offline queue — buffer mutations, replay on reconnect

## Notes

**2026-02-18 13:03:04 UTC:** In-memory queue of closures. When WS disconnects, mutations buffer. Optimistic UI updates applied locally. On reconnect, queue drains in order. Queue lost on app termination (acceptable).
