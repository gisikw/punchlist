# Summary: Agent toggle visibility fix

## What was done
Added `!showProjectPicker` as a fourth condition to the agent toggle's rendering logic in `ContentView.swift` (line 119). The agent toggle now hides when the project drawer is open, eliminating visual clutter.

## Implementation details
- **Location**: `Punchlist/Views/ContentView.swift:116-120`
- **Change**: Extended the existing `if let` conditional chain with `!showProjectPicker`
- **Pattern**: Matches the established pattern where `showProjectPicker` is used for drawer-aware UI rendering (e.g., line 18 for the drawer itself, lines 27-41 for overlay)

## Verification
- Build succeeded via `xcodebuild` on the remote build host
- No test suite exists (builds are the validation mechanism per `task.verify.md`)

## Plan compliance
✅ All planned tasks completed (single task: add condition)
✅ No deviations from plan
✅ No open questions or risks materialized
✅ Implementation matches ticket requirements exactly

## Invariants check
- No violations detected
- UI convention maintained: no modals/confirmations (UI invariant)
- SwiftUI-only pattern preserved (Code invariant)
- No architectural changes (still API client only, no persistence)

## Notable decisions
None — straightforward implementation following existing codebase patterns.

## Future notes
The `showProjectPicker` state is a reliable signal for drawer visibility throughout `ContentView.swift`. If other UI elements need drawer-aware visibility logic, this pattern can be reused.
