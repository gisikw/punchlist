## Goal
Implement polling fallback when SSE connection fails, ensuring the UI stays current even during network issues.

## Context
The app already has a polling mechanism implemented in `PunchlistViewModel` (lines 363-392). The polling system:
- Starts automatically when SSE disconnects (via `observeConnection()` at line 347-361)
- Uses adaptive intervals: 1s during "burst mode" (after mutations), 5s otherwise
- Suspends when SSE reconnects
- Fetches via REST API (`api.fetchItems()`) and updates `items` with filtered results

The `SSEManager` (lines 1-190) handles SSE connections with:
- Exponential backoff (1s → 30s cap) on disconnect
- 3-second delay before showing offline indicator
- Automatic reconnection on disconnect

The polling infrastructure is already working (dependency ticket pun-96d3 resolved). The current implementation has these components:
- `pollTask`: Task handle for the polling loop
- `pollBurstUntil`: Date tracking burst mode duration (10s after mutations)
- `startPollingIfNeeded()`: Starts polling if not already running
- `stopPolling()`: Cancels polling when SSE reconnects
- `observeConnection()`: Monitors SSE status and restarts polling on disconnect
- `afterAction()`: Triggers burst-poll after mutations when offline

Testing patterns use XCTest with `@testable import` to access internal methods (see `FilteringTests.swift`).

## Approach
The polling fallback is already implemented and functional. This ticket appears to be complete based on the codebase inspection. The implementation includes:
1. Polling starts automatically on app start (line 85)
2. Connection observer monitors SSE and restarts polling on disconnect (lines 347-361)
3. Burst-polling after mutations when offline (lines 266-270)
4. Adaptive polling intervals (1s burst, 5s steady)
5. Automatic suspension when SSE reconnects (line 78)

However, there may be edge cases or testing gaps to address. The plan assumes verification and potential refinements are needed.

## Tasks
1. [PunchlistTests/] — Add `PollingFallbackTests.swift` to verify polling behavior.
   - Test polling starts when SSE disconnects
   - Test polling stops when SSE reconnects
   - Test burst-polling after mutations (1s interval)
   - Test steady-state polling (5s interval)
   - Test polling doesn't start when already running
   - Mock SSEManager connection state and KoAPI responses
   Verify: `just test` passes with new polling tests.

2. [Punchlist/ViewModels/PunchlistViewModel.swift:observeConnection] — Review connection observer for race conditions.
   - Ensure observer doesn't miss disconnect events
   - Verify polling starts correctly after observer detects disconnect
   - Check if 2-second poll interval is sufficient for detection
   Verify: Manual testing with network toggle shows responsive polling start.

3. [Punchlist/Services/SSEManager.swift] — Add debug log entry when SSE connection fails to establish.
   - Log initial connection failures (not just disconnects)
   - Helps distinguish "never connected" from "disconnected"
   Verify: Debug log shows connection failure events.

4. [PunchlistTests/] — Manual testing of offline scenarios.
   - Cold start with no network → should poll immediately
   - SSE established then network lost → should start polling after detection
   - Network restored → SSE should reconnect, polling should stop
   - Mutations while offline → should trigger burst polling
   Document findings in test comments or ticket notes.

## Open Questions
None — the implementation already exists and appears complete. The tasks above focus on verification and potential edge-case refinement. If the implementation is confirmed working in all scenarios, this ticket may only need test coverage and documentation updates.
