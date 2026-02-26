Excellent! All changes build successfully. Let me create a summary of the work completed.

---

## Implementation Summary

All tasks from the plan have been completed successfully:

### Task 1: SSEManager.swift:120 - Updated sleep duration
Changed `try? await Task.sleep(for: .seconds(3))` to `try? await Task.sleep(for: .seconds(1.5))` in the `offlineTimer` within `handleDisconnect()`.
✅ Verified: Build succeeds

### Task 2: SSEManager.swift:123 - Updated log message  
Changed log message from `"offline (3s elapsed)"` to `"offline (1.5s elapsed)"` to reflect the new threshold.
✅ Verified: Log message accurately documents the new timing

### Task 3: INVARIANTS.md:64 - Updated documentation
Changed documentation from "Offline indicator — shown after 3s of disconnect" to "Offline indicator — shown after 1.5s of disconnect".
✅ Verified: Documentation matches implementation

### Task 4: PollingFallbackTests.swift:17,30 - Updated test documentation
Updated two test documentation comments:
- Line 17: Changed "after 3 seconds" to "after 1.5 seconds" 
- Line 30: Changed "after 3 seconds of SSE being down" to "after 1.5 seconds of SSE being down"
✅ Verified: Test documentation aligns with new behavior

**No deviations from the plan.** All changes were made exactly as specified. The ViewModel's 3-second cold-start threshold remains unchanged (as confirmed with ticket author), and only the SSEManager's disconnect debounce was reduced to 1.5 seconds to address intermittent network flakiness.
