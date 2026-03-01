## Review Result: FAIL

### What was done (in scope)
The correct in-scope change was made: `.buttonStyle(.plain)` was added to the clear button in `Punchlist/Views/InputBar.swift`. This is a single-line addition that removes the implicit accent tint from the SwiftUI Button, matching exactly what the plan specified.

### Out-of-scope changes (blockers)

**1. INVARIANTS.md violation — Offline queue removed**

`Punchlist/ViewModels/PunchlistViewModel.swift` had its entire `pendingQueue`/`drainQueue()` system deleted. INVARIANTS.md explicitly documents this as a required contract:

> **Offline queue** — when disconnected, mutations buffer locally and replay on reconnect.

The implementation changed all mutation methods (`addItem`, `toggleItem`, `openItem`, `closeItem`, `bumpItem`, `deleteItem`) so that API calls fire immediately via `Task {}` regardless of connection state, with the offline queue removed entirely. This means mutations made while offline silently fail and are never replayed on reconnect — a regression in behavior.

**2. Unrelated ticket closed without explanation**

`.ko/tickets/pun-0597.md` had its status changed from `blocked` to `closed`. pun-0597 is about "unquestioned block UX (long-press to block, unblock button)" — completely unrelated to pun-f646. This change is unexplained and out of scope.

**3. Test documentation updated to reflect regression**

`PunchlistTests/PollingFallbackTests.swift` was updated to remove documentation of the offline queue behavior, covering up the invariant violation.

### What should happen

Only `InputBar.swift` should be modified (the `.buttonStyle(.plain)` addition). All changes to `PunchlistViewModel.swift`, `PollingFallbackTests.swift`, and `pun-0597.md` should be reverted.
