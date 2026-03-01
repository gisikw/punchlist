---
id: pun-c13f
status: closed
deps: []
created: 2026-03-01T05:36:19Z
type: task
priority: 2
---
# Triage indicator should take precedence over all others - right now the "done" indicator supersedes the triage grey circle

## Notes

**2026-03-01 05:50:50 UTC:** ## Summary

Swapped the order of the `hasTriage` and `item.done || isResolved` branches in the `circle` computed property of `ItemRow.swift` (lines 332–344).

**What was done:** The single-line change reorders the conditional so `hasTriage` is evaluated first. A ticket with a triage value now shows the grey filled circle regardless of its done/resolved state. Tickets without triage continue to show the green checkmark when done or resolved.

**Notable decisions:** None — the plan was precise and the fix was minimal. The grey circle branch already rendered identically to before; only its position in the if/else chain changed.

**For future readers:** The `hasTriage` check (`item.triage != nil`) now takes top priority in the status indicator hierarchy. The triage circle intentionally has no inner checkmark or icon, just the filled grey circle.

**2026-03-01 05:50:50 UTC:** ko: SUCCEED
