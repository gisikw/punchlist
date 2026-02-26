I've written the implementation plan to `/home/dev/Projects/punchlist/.ko/tickets/pun-0742.artifacts/plan.md`.

## Key Finding

The **polling fallback is already implemented** in the codebase! Based on my investigation:

**What's already working:**
- Polling starts automatically on app launch (before SSE connects)
- Connection observer monitors SSE status every 2 seconds
- When SSE disconnects, polling starts automatically
- When SSE reconnects, polling stops
- Burst-polling (1s intervals) triggers after mutations when offline
- Steady-state polling uses 5s intervals

**What the plan addresses:**
1. **Add comprehensive tests** for the polling behavior (currently no polling-specific tests)
2. **Verify edge cases** like race conditions in the connection observer
3. **Improve observability** by adding debug logging for connection failures
4. **Manual testing** of offline scenarios to confirm real-world behavior

The dependency ticket (pun-96d3) that added the XCTest target is resolved, so the testing infrastructure is ready. The main work is verification and test coverage rather than new implementation.
