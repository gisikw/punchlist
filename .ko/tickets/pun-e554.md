---
id: pun-e554
status: closed
deps: [pun-bf49, pun-ad4b]
links: []
created: 2026-02-18T13:02:33Z
type: task
priority: 2
---
# PunchlistViewModel — state + coordination

## Notes

**2026-02-18 13:02:56 UTC:** @Observable class. Holds items array, coordinates API calls and WebSocket updates. Replaces full item array on each WS message (no diffing). Exposes add/toggle/bump/delete actions.
