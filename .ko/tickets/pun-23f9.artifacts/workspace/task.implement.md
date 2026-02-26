## Summary

I've successfully implemented all code changes from the plan to fix the empty projects drawer issue:

### Task 1: Immediate fallback ✅
**Location:** `PunchlistViewModel.swift:40`
- Added default "user" project to the `projects` array at the start of `start()` method
- This ensures the UI is never empty, even during network calls
- The default project is immediately available before any async operations

### Task 2: Retry logic with exponential backoff ✅
**Location:** `PunchlistViewModel.swift:56-68`
- Replaced silent `try?` with explicit error handling and retry logic
- Implements 3 retry attempts with exponential backoff: 0.5s, 1s, 2s
- First attempt has no delay; subsequent attempts use increasing delays
- If all attempts fail, the default "user" project from Task 1 remains available

### Task 3: Project re-fetch in refresh() ✅
**Location:** `PunchlistViewModel.swift:96-103`
- Added project re-fetch at the start of the `refresh()` method
- This recovers from initial load failures when the app returns from background
- Uses the same sorting logic to keep "user" project first

### Task 4: Manual verification ⏳
This task requires building and running the app on actual hardware/simulator with airplane mode testing, which cannot be performed from this Linux environment. The implementation is complete and ready for testing.

## Changes Made

All changes were made to `/home/dev/Projects/punchlist/Punchlist/ViewModels/PunchlistViewModel.swift`:

1. **Line 40**: Added immediate fallback with default "user" project
2. **Lines 56-76**: Replaced silent error handling with retry logic (exponential backoff)
3. **Lines 96-103**: Added project re-fetch in `refresh()` method

The implementation follows the existing codebase patterns:
- No third-party dependencies
- Uses `@Observable` pattern
- Matches existing retry/backoff patterns from INVARIANTS.md
- Fire-and-forget network calls with optional error recovery
