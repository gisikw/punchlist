## Goal
Replace the 3-second startup-only threshold with a general 1.5-second debounce on offline indicator visibility across all disconnection scenarios.

## Context
Currently the app has a 3-second cold-start threshold to prevent showing the offline indicator during initial network setup:
- `PunchlistViewModel.swift:11-13` — `showOffline` computed property checks `Date().timeIntervalSince(startDate) > 3`
- `SSEManager.swift:119-125` — Uses a separate 3-second delay before marking `isConnected = false` after disconnect
- `INVARIANTS.md:64` — Documents the 3-second policy: "Offline indicator shown after 3s of disconnect (not immediately, to avoid flicker on brief interruptions)"

The ticket requests a 1.5-second threshold instead, applied universally (not just at startup). However, the code reveals two separate 3-second delays with different purposes:
1. ViewModel's startup delay — prevents showing offline during cold-start latency
2. SSEManager's disconnect delay — debounces minor network flakiness when SSE drops

The ticket author says "I see it frequently appear and disappear around minor network flakiness", which points to the SSEManager disconnect timer.

## Approach
Change the SSEManager's offline timer from 3 seconds to 1.5 seconds. This debounces the `isConnected` flag change after an SSE disconnect, preventing flicker from brief network blips. The ViewModel's startup threshold remains at 3 seconds to handle cold-start latency, but SSEManager's shorter debounce will dominate during normal operation since it controls the `isConnected` flag that feeds into `showOffline`.

## Tasks
1. [Punchlist/Services/SSEManager.swift:120] — Change `try? await Task.sleep(for: .seconds(3))` to `try? await Task.sleep(for: .seconds(1.5))` in the `offlineTimer` within `handleDisconnect()`.
   Verify: Build succeeds with `just check` or `just build`.

2. [Punchlist/Services/SSEManager.swift:123] — Update the log message from `"offline (3s elapsed)"` to `"offline (1.5s elapsed)"` to reflect the new threshold.
   Verify: Log message accurately documents the new timing.

3. [INVARIANTS.md:64] — Update the documentation from "Offline indicator — shown after 3s of disconnect" to "Offline indicator — shown after 1.5s of disconnect".
   Verify: Documentation matches implementation.

4. [PunchlistTests/PollingFallbackTests.swift:17,30] — Update test documentation comments that reference "3 seconds" to "1.5 seconds" in the manual testing scenarios (lines 17 and 30).
   Verify: Test documentation aligns with new behavior.

## Open Questions
Should the ViewModel's cold-start threshold (`Date().timeIntervalSince(startDate) > 3`) also be reduced to 1.5 seconds, or should it remain at 3 seconds to handle slower initial network setup? The ticket emphasizes "not just in startup" but the SSEManager change addresses the "frequently appear and disappear" flakiness issue. Keeping the startup threshold at 3s is more conservative for cold starts while still fixing the flakiness problem.
