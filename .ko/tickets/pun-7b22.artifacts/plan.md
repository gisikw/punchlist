## Goal
Make the agent toggle appear when there are blocked tickets that have triage text, in addition to unblocked tickets.

## Context
The agent toggle in `ContentView.swift` (line 122) gates on `viewModel.hasUnblockedTickets`. That computed property in `PunchlistViewModel.swift` (line 37–39) returns `true` if any item is not done, not blocked, and not resolved:

```
items.contains { !$0.done && $0.status != "blocked" && $0.status != "resolved" }
```

A triage ticket is an item with a non-nil `triage` field (`Item.swift` line 14). Triage text represents human guidance given to the agent so it can proceed on a blocked ticket. These should count as actionable because the agent can act on them.

The `Item` manual init (used in tests) does not include `triage`, but since `triage` is a `var`, tests can mutate it after construction (same pattern used for `modified` in `FilteringTests.swift`).

Existing tests `testHasUnblockedTicketsExcludesResolved` and `testHasUnblockedTicketsIncludesInProgress` in `FilteringTests.swift` must continue to pass unchanged — no triage is set on those items.

## Approach
Extend the `hasUnblockedTickets` predicate to also return `true` for items that are not done, not resolved, and have a non-nil `triage` value (regardless of blocked status). Then add tests covering the new cases.

## Tasks
1. [`Punchlist/ViewModels/PunchlistViewModel.swift:hasUnblockedTickets`] — Update the predicate to:
   `!$0.done && $0.status != "resolved" && ($0.status != "blocked" || $0.triage != nil)`
   This lets a blocked ticket with triage count as actionable while keeping resolved and done items excluded.
   Verify: existing tests still pass.

2. [`PunchlistTests/FilteringTests.swift`] — Add a new test function `testHasUnblockedTicketsIncludesTriage` with cases:
   - Blocked ticket with triage → `hasUnblockedTickets` is `true`
   - Blocked ticket without triage → `false` (existing behavior, confirming no regression)
   - Resolved ticket with triage → `false` (triage doesn't override resolved)
   - Mix of blocked-with-triage and a blocked-without-triage → `true`
   Verify: new test passes, all existing tests pass.

## Open Questions
None.
