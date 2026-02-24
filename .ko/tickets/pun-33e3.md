---
id: pun-33e3
status: closed
deps: []
created: 2026-02-18T19:07:29Z
type: task
priority: 1
---
# WebSocket shows offline despite working data sync

App shows offline indicator but items occasionally sync (clears additions periodically). May be a WebSocket connection issue — could be connecting over wrong hostname, or the 3s delay logic is misfiring. Needs investigation of WebSocket URL and connection lifecycle.

## Notes

**2026-02-24 16:12:10 UTC:** Clearer repro from Kevin: On hard-close or idle-close app launch, tapping to complete/reorder flows through to backend but UI doesn't update. No 'websocket disconnected' error shown. Persists even after WS disconnect+reconnect cycle. Opening project drawer, navigating away, and coming back fixes it. Suspicion: on initial connect we're either not specifying the project channel to listen to, or not updating on the client side which project we should be listening for updates on. The switchProject call in receiveLoop's first-message handler may not be effective — possibly the server's default project subscription (exo) persists despite the switch message.
