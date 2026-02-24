---
id: pun-390d
status: closed
deps: []
created: 2026-02-20T14:52:18Z
type: task
priority: 2
---
# Decouple from ko registry file — use ko projects CLI command instead

## Notes

**2026-02-20 14:52:28 UTC:** Server currently reads ~/.config/knockout/projects.yml directly via parseKoRegistry(). Should shell out to ko projects instead, same pattern as ko query for tickets.
