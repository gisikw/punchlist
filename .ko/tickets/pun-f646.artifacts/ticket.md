---
id: pun-f646
status: open
deps: []
created: 2026-03-01T00:00:00Z
type: task
priority: 2
---
# Remove color from the (x) clear button in InputBar — it should render without tint/color

## Notes

**2026-03-01 05:41:21 UTC:** ko: FAIL at node 'review' — Implementation violated INVARIANTS.md: the 'Offline queue' invariant (mutations buffer locally and replay on reconnect) is explicitly documented, but the implementation removed the entire pendingQueue/drainQueue() system from PunchlistViewModel.swift. Additionally, the unrelated ticket pun-0597 was closed without explanation, and test documentation was updated to mask the regression. Only the InputBar.swift change (.buttonStyle(.plain)) was correct and in scope.
