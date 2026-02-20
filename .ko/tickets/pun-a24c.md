---
id: pun-a24c
status: closed
deps: []
links: []
created: 2026-02-20T14:01:57Z
type: task
priority: 2
---
# Project list endpoint — GET /api/projects returns slugs and names for swipe navigation

## Notes

**2026-02-20 14:02:23 UTC:** Server already has /api/projects listing all registered projects. May just need to verify the shape is right for the client — slug, name, and maybe an order field. The personal project should always be first (index 0, swipe-left-most).
