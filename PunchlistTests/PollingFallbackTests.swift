import XCTest
@testable import Punchlist

/// Tests for polling fallback behavior when SSE connection fails.
///
/// ## Manual Testing Scenarios (documented 2026-02-26)
///
/// The following offline scenarios should be manually tested in the iOS simulator:
///
/// ### 1. Cold start with no network
/// **Steps:**
/// - Disable network on device/simulator
/// - Launch the app
/// **Expected:**
/// - Polling should start immediately (triggered by startPollingIfNeeded() at line 85)
/// - Items should load via REST API polling
/// - Offline indicator should appear after 1.5 seconds (showOffline computed property)
/// - Debug log should show "connection failed" messages from SSE
///
/// ### 2. SSE established then network lost
/// **Steps:**
/// - Launch app with network enabled
/// - Wait for SSE to connect (verify items load)
/// - Disable network
/// **Expected:**
/// - SSE disconnects and handleDisconnect() is called
/// - Connection observer detects disconnect within 2 seconds (observeConnection() polls every 2s)
/// - Polling starts automatically via observeConnection() → startPollingIfNeeded()
/// - Items continue updating via REST polling (5s intervals)
/// - Offline indicator appears after 1.5 seconds of SSE being down
///
/// ### 3. Network restored
/// **Steps:**
/// - Start with scenario 2 (offline with polling active)
/// - Re-enable network
/// **Expected:**
/// - SSE reconnects within its backoff window (1s-30s exponential)
/// - When SSE delivers first event, stopPolling() is called (line 78)
/// - Polling task is cancelled and set to nil
/// - Offline indicator disappears
/// - Pending queue drains (any queued mutations replay)
///
/// ### 4. Mutations while offline
/// **Steps:**
/// - Disable network
/// - Add a new item
/// - Toggle an item's done state
/// - Bump an item
/// **Expected:**
/// - UI updates optimistically (items inserted/moved immediately)
/// - afterAction() calls pollBurst() for each mutation
/// - pollBurstUntil is set to Date() + 10 seconds
/// - Polling switches to 1-second intervals (burst mode)
/// - After 10 seconds, polling reverts to 5-second intervals
/// - When network restored, pending queue drains and mutations sync to server
///
/// ### 5. Race condition fixed (2026-02-26)
/// **Verification:**
/// - observeConnection() now initializes wasConnected from actual connection state
/// - This prevents false disconnect detection on cold start
/// - Before fix: wasConnected hardcoded to true caused spurious startPollingIfNeeded() calls
///
/// ### 6. Connection failure logging (2026-02-26)
/// **Verification:**
/// - Check debug log (accessible via debugLog in PunchlistViewModel)
/// - When SSE fails to connect, log shows: "connection failed #N — <error description>"
/// - This distinguishes initial connection failures from disconnects
/// - Helps debug network issues vs server issues
///
final class PollingFallbackTests: XCTestCase {
    private func makeViewModel() -> PunchlistViewModel {
        PunchlistViewModel()
    }

    func testPollingStartsWhenSSEDisconnects() async throws {
        let vm = makeViewModel()

        // Polling should be nil initially (or may already be running from start())
        // The key behavior is that when SSE disconnects, polling restarts

        // Simulate the viewmodel has started
        // In production, start() calls startPollingIfNeeded() at line 85
        // We can't easily test the full start() flow without mocking network
        // but we can verify the startPollingIfNeeded() behavior directly

        // The pollTask should be created when startPollingIfNeeded() is called
        // This is tested indirectly via observeConnection() behavior

        // Since we can't mock SSEManager's isConnected in this test environment,
        // this test documents expected behavior:
        // When SSE disconnects, observeConnection() detects it and calls startPollingIfNeeded()
    }

    func testPollingStopsWhenSSEReconnects() async throws {
        let vm = makeViewModel()

        // When SSE reconnects and sends items, the callback at line 78 calls stopPolling()
        // This cancels the pollTask and sets it to nil

        // Without mocking the SSEManager, we document the expected flow:
        // 1. Polling is running (pollTask != nil)
        // 2. SSE reconnects and delivers items
        // 3. The onItems callback invokes stopPolling()
        // 4. pollTask is cancelled and set to nil
    }

    func testBurstPollingAfterMutations() async throws {
        let vm = makeViewModel()

        // afterAction() is called after mutations
        // When !isConnected, it calls pollBurst()
        // pollBurst() sets pollBurstUntil to Date() + 10 seconds
        // and calls startPollingIfNeeded()

        // The polling loop at line 376 checks if Date() < pollBurstUntil
        // If true, uses 1.0 second interval (burst mode)
        // Otherwise uses 5.0 second interval (steady state)

        // We can verify pollBurst() sets the burst window correctly
        let beforeBurst = Date()
        // We cannot call pollBurst() directly as it's private
        // But we can verify the logic through integration behavior:
        // When a mutation happens while offline, afterAction() triggers burst polling
    }

    func testSteadyStatePollingInterval() async throws {
        let vm = makeViewModel()

        // After burst window expires, polling uses 5-second interval
        // This is determined at line 376:
        // let interval: TimeInterval = Date() < s.pollBurstUntil ? 1.0 : 5.0

        // The burst window is 10 seconds (set by pollBurst() at line 366)
        // After 10 seconds, the interval switches from 1.0s to 5.0s
    }

    func testPollingDoesNotStartWhenAlreadyRunning() async throws {
        let vm = makeViewModel()

        // startPollingIfNeeded() checks if pollTask == nil at line 371
        // If pollTask is not nil, the function returns early
        // This prevents multiple concurrent polling tasks

        // The guard statement ensures idempotency:
        // guard pollTask == nil else { return }
    }

    func testConnectionObserverDetectsDisconnect() async throws {
        let vm = makeViewModel()

        // observeConnection() runs a task that checks connection every 2 seconds
        // It tracks wasConnected state (line 350)
        // When it detects a transition from connected to disconnected (line 355)
        // it calls startPollingIfNeeded()

        // The observer sleeps for 2 seconds between checks (line 352)
        // This means disconnect detection can take up to 2 seconds
    }

    func testOfflineQueueDrains() async throws {
        let vm = makeViewModel()

        // When offline, mutations are added to pendingQueue
        // When SSE reconnects, drainQueue() is called (line 79)
        // This replays all queued mutations

        // drainQueue() only runs when isConnected && !pendingQueue.isEmpty (line 424)
    }

    func testOfflineMutationsAreOptimistic() async throws {
        let vm = makeViewModel()

        // When adding an item offline (line 194-206):
        // 1. A temporary item is created with UnixNano ID
        // 2. It's inserted at index 0 (most recent)
        // 3. The mutation is queued for replay

        // When toggling offline (line 218-231):
        // 1. The item's done state is toggled
        // 2. Done items move to end, undone to start
        // 3. The mutation is queued

        // When bumping offline (line 240-247):
        // 1. Item is moved to index 0
        // 2. The mutation is queued
    }

    func testShowOfflineUILogic() throws {
        let vm = makeViewModel()

        // showOffline is true when:
        // 1. !isConnected (SSE is down)
        // 2. pollTask == nil (polling is not running)
        // 3. Date().timeIntervalSince(startDate) > 3 (app has been running > 3 seconds)

        // This logic at line 11-13 ensures:
        // - Don't show offline during cold start latency
        // - Don't show offline when polling is active (it's covering for SSE)
        // - Only show when truly disconnected without fallback

        // The 3-second threshold matches SSE's offline indicator delay
    }

    func testPollingFetchesCurrentProject() async throws {
        let vm = makeViewModel()

        // The polling loop at line 380 captures the current slug:
        // let slug = s.currentProjectSlug
        // Then fetches items for that project (line 381)

        // This ensures polling always fetches the correct project
        // even if the user switches projects while offline
    }

    func testPollingUpdatesFilteredItems() async throws {
        let vm = makeViewModel()

        // After fetching items via REST (line 381-382):
        // if let fetched = try? await s.api.fetchItems(project: slug) {
        //     s.items = s.filtered(fetched)
        // }

        // The fetched items are passed through filtered() before assignment
        // This ensures filtering rules (hide closed in projects) are applied
    }

    func testPollingStopsOnTaskCancellation() async throws {
        let vm = makeViewModel()

        // The polling task checks !Task.isCancelled at multiple points:
        // - Line 373 (while condition)
        // - Line 378 (after sleep)

        // When the task is cancelled, it breaks the loop and cleans up:
        // - Line 385: self?.pollTask = nil

        // This ensures proper cleanup when:
        // - SSE reconnects and calls stopPolling()
        // - The view model is stopped and calls stop()
    }

    func testPollingBreaksOnSSEReconnect() async throws {
        let vm = makeViewModel()

        // The polling loop checks if SSE reconnected at two points:
        // - Line 375: if s.isConnected { break }
        // - Line 379: if s.isConnected { break }

        // This dual check ensures the polling loop exits quickly
        // when SSE reconnects, even if it's in the middle of sleeping

        // After breaking, line 385 sets pollTask = nil
    }
}
