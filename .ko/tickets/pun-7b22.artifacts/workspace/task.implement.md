Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Both tasks done. Here's a summary:

**Task 1 — `PunchlistViewModel.swift:37`**
Changed `hasUnblockedTickets` from:
```swift
items.contains { !$0.done && $0.status != "blocked" && $0.status != "resolved" }
```
to:
```swift
items.contains { !$0.done && $0.status != "resolved" && ($0.status != "blocked" || $0.triage != nil) }
```
A blocked ticket with triage text now counts as actionable; resolved tickets stay excluded regardless of triage.

**Task 2 — `FilteringTests.swift`**
Added `testHasUnblockedTicketsIncludesTriage` covering four cases:
- Blocked + triage → `true`
- Blocked without triage → `false`
- Resolved + triage → `false`
- Mix of blocked-with-triage and blocked-without-triage → `true`

No deviations from the plan.
