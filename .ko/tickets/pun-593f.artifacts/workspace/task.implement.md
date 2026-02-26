Excellent! All tasks are complete. Let me provide a summary of the changes:

## Summary

All tasks from the plan have been completed successfully. The implementation fixes the agent toggle visibility to hide when only non-actionable tickets remain.

### Task 1: Update hasUnblockedTickets property ✓
**File**: Punchlist/ViewModels/PunchlistViewModel.swift:37-39

Changed the `hasUnblockedTickets` computed property to also exclude tickets with "resolved" status:
```swift
// Before:
items.contains { !$0.done && $0.status != "blocked" }

// After:
items.contains { !$0.done && $0.status != "blocked" && $0.status != "resolved" }
```

Verification: `just check` passed successfully.

### Task 2: Add test for excluding resolved tickets ✓
**File**: PunchlistTests/FilteringTests.swift

Added `testHasUnblockedTicketsExcludesResolved` test that verifies:
- Resolved tickets alone don't count as unblocked
- Mix of resolved and blocked tickets don't count as unblocked
- Mix of resolved, blocked, and done tickets don't count as unblocked

Verification: `just build` passed successfully.

### Task 3: Add test for including in_progress tickets ✓
**File**: PunchlistTests/FilteringTests.swift

Added `testHasUnblockedTicketsIncludesInProgress` test that verifies:
- In-progress tickets count as unblocked
- Open tickets count as unblocked
- Mix with in_progress and non-actionable tickets still counts as having unblocked tickets
- Mix with open and non-actionable tickets still counts as having unblocked tickets

Verification: `just build` passed successfully.

### No Deviations
All changes followed the plan exactly as specified. The agent toggle will now correctly hide when only resolved, blocked, or done tickets remain, since none of these are agent-actionable.
