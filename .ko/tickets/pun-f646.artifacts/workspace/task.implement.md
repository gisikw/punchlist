Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Build succeeded. Done.

**Summary:**

**Task 1 — Unstage out-of-scope files:** Used `git restore --staged` on `Punchlist/ViewModels/PunchlistViewModel.swift` and `PunchlistTests/PollingFallbackTests.swift`. Both are now unstaged (working tree modifications, not staged).

**Task 2 — `Punchlist/Views/InputBar.swift`:** Added `.buttonStyle(.plain)` after the closing brace of the `label:` trailing closure on the clear button. This prevents SwiftUI from applying the app's accent color to the button label, so `.foregroundStyle(.secondary)` renders as neutral grey.

No deviations from the plan.
