---
id: pun-8a22
status: closed
deps: []
created: 2026-02-20T14:52:18Z
type: task
priority: 2
---
# Preload adjacent projects for smooth swipe — tag WS exchanges instead of single-state

## Notes

**2026-02-20 14:52:28 UTC:** Current WS protocol: client sends {project: slug}, server rebinds broadcast. New: tag each exchange so server can multiplex — send items for current + adjacent projects simultaneously. Client caches per-project item arrays so mid-swipe shows real data.
