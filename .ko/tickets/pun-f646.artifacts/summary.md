## Summary

Added `.buttonStyle(.plain)` to the clear button (`xmark.circle.fill`) in `Punchlist/Views/InputBar.swift`. SwiftUI `Button` applies the app's accent color to its label by default; `.buttonStyle(.plain)` disables that tinting so `.foregroundStyle(.secondary)` renders as neutral grey.

## Context

This was a retry of a prior failed attempt. The first attempt had correctly identified the fix but also staged two out-of-scope changes (removing `pendingQueue`/`drainQueue()` from `PunchlistViewModel.swift` and updating `PollingFallbackTests.swift` to match), which violated the committed `INVARIANTS.md` offline-queue invariant.

This attempt:
1. Unstaged both out-of-scope files via `git restore --staged` — they remain as working-tree modifications only and will not be in this commit.
2. Applied the single correct change to `InputBar.swift`.

`INVARIANTS.md` also has working-tree changes (updating the WebSocket/offline-queue language to SSE/fire-immediately), but these are unstaged and will remain for a future ticket. HEAD `INVARIANTS.md` and HEAD `PunchlistViewModel.swift` remain mutually consistent.

## For Future Readers

The working tree has a coherent but uncommitted refactor: `PunchlistViewModel.swift` removes the pending-queue system, `PollingFallbackTests.swift` updates the docs, and `INVARIANTS.md` updates the architecture section to reflect SSE + fire-immediately semantics. These three changes should be committed together in a dedicated ticket.
