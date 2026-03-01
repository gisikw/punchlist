## Summary

Extended `hasUnblockedTickets` in `PunchlistViewModel.swift` to include blocked tickets that have triage text. The predicate changed from:

```swift
items.contains { !$0.done && $0.status != "blocked" && $0.status != "resolved" }
```

to:

```swift
items.contains { !$0.done && $0.status != "resolved" && ($0.status != "blocked" || $0.triage != nil) }
```

This makes the agent toggle visible when a blocked ticket has triage guidance, since the agent can act on that guidance.

Added `testHasUnblockedTicketsIncludesTriage` in `FilteringTests.swift` covering all four required cases: blocked+triage (true), blocked-no-triage (false), resolved+triage (false), and a mix (true).

No deviations from the plan. Existing tests are unaffected since they don't set `triage` on their items.
