Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
The plan is updated. Here's the summary:

**What happened previously:** The prior implementation correctly identified the fix (`.buttonStyle(.plain)` on the clear button) but also made out-of-scope changes — it removed `pendingQueue`/`drainQueue()` from `PunchlistViewModel.swift` and updated test docs in `PollingFallbackTests.swift`. Those staged changes violated the committed `INVARIANTS.md` (which at HEAD documents an offline queue invariant), causing the review to fail.

**The fix itself was never actually applied** — `InputBar.swift` on disk still lacks `.buttonStyle(.plain)`.

**Updated plan has two tasks:**
1. Unstage the out-of-scope changes to `PunchlistViewModel.swift` and `PollingFallbackTests.swift` (restore them to HEAD state)
2. Apply the single correct change: add `.buttonStyle(.plain)` to the clear button in `InputBar.swift`
