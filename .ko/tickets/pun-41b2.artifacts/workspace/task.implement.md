Excellent! Both changes have been applied correctly. Let me verify the logic:

**Task 1 verification:**
- ✅ Added `hasUnblockedTickets` computed property to `PunchlistViewModel` (line 37-39)
- ✅ It checks if any item has `!$0.done && $0.status != "blocked"`
- ✅ This correctly returns true when there are actionable items, false otherwise

**Task 2 verification:**
- ✅ Added `viewModel.hasUnblockedTickets` to the conditional at line 122
- ✅ The agent toggle now only appears when:
  - Not personal project
  - Project picker is closed
  - No reviewable session
  - Agent state exists and is not `.notProvisioned`
  - **AND there are unblocked tickets** (new condition)

The implementation matches the plan exactly. The agent toggle will now be hidden when all tickets are either done or blocked, and shown only when at least one ticket is actionable (not done and not blocked).

## Summary

Successfully implemented both tasks from the plan:

**Task 1** - `Punchlist/ViewModels/PunchlistViewModel.swift:37-39`
- Added computed property `hasUnblockedTickets` that returns true if any item is not done and not blocked

**Task 2** - `Punchlist/Views/ContentView.swift:122`
- Updated the agent toggle conditional to include `viewModel.hasUnblockedTickets` as an additional requirement

The agent toggle will now be hidden when there are no actionable tickets in the current project, as specified in the ticket requirements. No deviations from the plan were necessary.
