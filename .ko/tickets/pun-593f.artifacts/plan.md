## Goal
Hide the agent toggle when the only remaining tickets are resolved, blocked, or done — none of which are agent-actionable.

## Context
The agent toggle appears in the project view header (ContentView.swift:116-124) when:
1. Not in personal view
2. Agent is provisioned
3. `viewModel.hasUnblockedTickets` is true

Currently, `hasUnblockedTickets` (PunchlistViewModel.swift:37-39) returns true if there are any items that are NOT done AND NOT blocked:

```swift
var hasUnblockedTickets: Bool {
    items.contains { !$0.done && $0.status != "blocked" }
}
```

The problem: this logic doesn't exclude "resolved" status tickets. From the codebase (pun-d071 artifacts), "resolved" means "the work is done, and a human should see it" — it's not agent-actionable. The agent should hide when only resolved, blocked, or done tickets remain.

Item status values observed in the codebase:
- "closed" → done = true (Item.swift:32)
- "blocked" → agent can't work on it
- "resolved" → work is done, human review needed (not agent-actionable)
- "in_progress" → agent can work on it
- "open" → agent can work on it

Key files:
- PunchlistViewModel.swift: Contains `hasUnblockedTickets` computed property
- ContentView.swift: Uses `hasUnblockedTickets` to control agent toggle visibility
- FilteringTests.swift: Existing test patterns for view model filtering

## Approach
Update the `hasUnblockedTickets` property to also exclude tickets with "resolved" status, since they're not agent-actionable.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift:hasUnblockedTickets] — Update the computed property to check `$0.status != "blocked" && $0.status != "resolved"` instead of just `$0.status != "blocked"`.
   Verify: `just check` passes.

2. [PunchlistTests/FilteringTests.swift] — Add unit test `testHasUnblockedTicketsExcludesResolved` that verifies resolved tickets don't count as unblocked.
   Verify: New test passes with `just build`.

3. [PunchlistTests/FilteringTests.swift] — Add unit test `testHasUnblockedTicketsIncludesInProgress` that verifies in_progress tickets DO count as unblocked.
   Verify: New test passes with `just build`.

## Open Questions
None — the fix is straightforward. "Resolved" tickets are documented as non-actionable by the agent (they need human review), so they should be excluded alongside "blocked" and "done" tickets.
