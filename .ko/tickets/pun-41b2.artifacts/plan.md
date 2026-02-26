## Goal
Hide the agent toggle when there are no actionable (unblocked and not done) tickets in the current project.

## Context
The agent toggle lives in `ContentView.swift` (lines 116-124) and is currently shown for non-personal projects when:
- The project picker is closed
- There's no reviewable session
- Agent state exists and is not `.notProvisioned`

Items in the system have a `status` field that can be "blocked", "in_progress", "resolved", or "closed". The `done` property is derived from `status == "closed"`.

An unblocked ticket is one where the item is:
- Not done (`!item.done`)
- Not blocked (`item.status != "blocked"`)

The view model already has access to the items list in `viewModel.items`. We need to add a computed property to determine if there are any unblocked tickets, then use that in the conditional rendering logic for the agent toggle.

## Approach
Add a computed property `hasUnblockedTickets` to `PunchlistViewModel` that returns true if any item in the current project is not done and not blocked. Then update the conditional logic in `ContentView.swift` to only show the agent toggle when this property is true.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add a computed property `hasUnblockedTickets` that checks if any item in `items` has `!done` and `status != "blocked"`.
   Verify: Property correctly returns true when there are actionable items, false otherwise.

2. [Punchlist/Views/ContentView.swift:120-122] — Add `viewModel.hasUnblockedTickets` to the condition that renders the agent toggle (the `else if` block).
   Verify: Agent toggle is hidden when all tickets are either done or blocked, shown when at least one ticket is actionable.

## Open Questions
None — the requirement is clear. An unblocked ticket means not done and not blocked. The agent toggle should be hidden when no such tickets exist.
