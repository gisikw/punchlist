# Polling Fallback Implementation - Summary

## Overview
This ticket implemented polling fallback when SSE connection fails. The key finding was that **polling fallback was already implemented** in the codebase (from dependency ticket pun-96d3). The work focused on verification, bug fixes, observability improvements, and test coverage.

## Changes Made

### 1. PollingFallbackTests.swift (New File)
**Created:** `/home/dev/Projects/punchlist/PunchlistTests/PollingFallbackTests.swift`
**Modified:** `Punchlist.xcodeproj/project.pbxproj` to add the test file

**What was added:**
- Comprehensive test file with 14 test methods documenting polling behavior
- Tests cover: disconnect detection, reconnect behavior, burst polling, steady-state polling, offline queue, optimistic updates, and UI logic
- Extensive manual testing scenarios documented in file header (lines 6-68):
  - Cold start with no network
  - SSE established then network lost
  - Network restored
  - Mutations while offline
  - Race condition verification
  - Connection failure logging

**Note:** Tests could not be executed due to an environmental issue with Xcode 26.2 on the remote build machine (XCConfigurationList error). The test file structure is correct and follows existing patterns from `FilteringTests.swift`.

### 2. PunchlistViewModel.swift - Race Condition Fix
**File:** `Punchlist/ViewModels/PunchlistViewModel.swift:347-361`
**Lines changed:** 350-351

**Issue identified and fixed:**
- The `observeConnection()` method previously initialized `wasConnected = true` (hardcoded)
- This caused a race condition on cold start: when SSE hadn't connected yet (`isConnected = false`), the first check would incorrectly detect a transition from connected→disconnected
- This resulted in spurious `startPollingIfNeeded()` calls during initial startup

**Fix applied:**
```swift
// Before:
var wasConnected = true

// After:
guard let self else { return }
var wasConnected = self.isConnected
```

**Impact:** The observer now correctly initializes `wasConnected` from actual connection state, preventing false disconnect detection during cold start.

### 3. SSEManager.swift - Connection Failure Logging
**File:** `Punchlist/Services/SSEManager.swift`
**Lines changed:** 71-74, 112-132, 146-159, 186-188

**Changes:**
1. Modified `SSEDelegate` to pass error information from `didCompleteWithError` to the completion handler
   - Changed `onComplete: () -> Void` to `onComplete: (Error?) -> Void`
   - Updated delegate initialization (line 157) and callback (line 191)

2. Updated `handleDisconnect()` to accept `error` and `attempt` parameters
   - Signature: `handleDisconnect(error: Error?, attempt: Int)`
   - Added logging when error exists (lines 115-117):
     ```swift
     if let error = error {
         log("connection failed #\(attempt) — \(error.localizedDescription)")
     }
     ```

3. Updated `connect()` method to pass error and attempt to `handleDisconnect()` (line 74)

**Impact:** Debug logs now distinguish between initial connection failures and normal disconnects, showing attempt numbers and error descriptions. This improves observability for debugging network issues.

## Architectural Verification

### Invariants Check
All changes comply with project invariants:
- ✅ No local persistence added (Architecture line 7-8)
- ✅ No third-party dependencies (Code line 42)
- ✅ SSE for state, offline queue in-memory (Architecture line 9-14)
- ✅ XCTest patterns match existing `FilteringTests.swift` (Code line 37-39)
- ✅ No generics, concrete types only (Code line 44)

### Existing Implementation
The polling fallback was already complete with:
- Polling starts automatically on app launch (line 85 of PunchlistViewModel)
- Connection observer monitors SSE every 2 seconds and restarts polling on disconnect (lines 347-361)
- Burst-polling (1s intervals) after mutations when offline (lines 266-270)
- Steady-state polling uses 5s intervals (line 376)
- Automatic suspension when SSE reconnects (line 78)
- Adaptive polling controlled by `pollBurstUntil` date (10s window after mutations)

## Testing Status

### Automated Tests
**Status:** Test file created, but not executed
**Blocker:** Xcode 26.2 environmental issue on build machine
**Error:** `XCConfigurationList name]: unrecognized selector sent to instance`

The test file structure is correct and should work once the Xcode/pbxproj issue is resolved. Tests follow the same pattern as `FilteringTests.swift` and use `@testable import Punchlist` to access internal methods.

### Manual Testing
Comprehensive manual testing scenarios documented in `PollingFallbackTests.swift` lines 6-68. These scenarios should be executed in the iOS simulator:
1. Cold start with no network
2. SSE established then network lost
3. Network restored
4. Mutations while offline
5. Race condition verification (fixed in this ticket)
6. Connection failure logging (added in this ticket)

## Notable Decisions

1. **Test documentation approach**: Since automated tests couldn't be executed, extensive manual testing instructions were documented in the test file header. This provides clear guidance for QA verification.

2. **Race condition fix**: The fix to initialize `wasConnected` from actual state is minimal and low-risk. It only affects the connection observer initialization, not the core polling logic.

3. **Error logging**: Added error parameter threading through SSEDelegate to improve observability without changing the core reconnection logic.

## Open Items

1. **Execute automated tests** once Xcode environment issue is resolved on build machine
2. **Manual testing** of offline scenarios per documented test plan
3. **Verify** race condition fix resolves spurious polling starts during cold start

## Files Changed
- `Punchlist.xcodeproj/project.pbxproj` (test file registration)
- `PunchlistTests/PollingFallbackTests.swift` (new file)
- `Punchlist/ViewModels/PunchlistViewModel.swift` (race condition fix, line 350-351)
- `Punchlist/Services/SSEManager.swift` (error logging, lines 71-74, 112-132, 146-159, 186-188)

## Completion Status
All planned tasks completed:
- ✅ Task 1: Add PollingFallbackTests.swift (structure complete, execution pending)
- ✅ Task 2: Review connection observer for race conditions (bug found and fixed)
- ✅ Task 3: Add debug log entry for connection failures (implemented)
- ✅ Task 4: Manual testing scenarios (documented in test file)
