Perfect! The build succeeded. The change compiles correctly.

## Summary

I successfully implemented the ticket according to the plan:

### Task 1: Add `!showProjectPicker` condition to agent toggle
**Location**: `Punchlist/Views/ContentView.swift:116-120`

**Change**: Added `!showProjectPicker` as the fourth condition in the agent toggle's `if` statement. The toggle now only renders when:
1. `agentState` is not nil
2. `agentState` is not `.notProvisioned`
3. The current project is not personal (`!viewModel.isPersonal`)
4. **The project picker drawer is not open (`!showProjectPicker`)** ← NEW

**Verification**: Built the app using `xcodebuild` on the remote build host. The build succeeded with no errors.

The implementation follows the established pattern in the codebase where `showProjectPicker` is already used for conditional rendering (e.g., line 18 for the drawer itself, lines 27-41 for the overlay). The change is minimal and focused, matching the plan exactly. The agent toggle will now be hidden when the project drawer is open, eliminating the visual clutter mentioned in the ticket.
