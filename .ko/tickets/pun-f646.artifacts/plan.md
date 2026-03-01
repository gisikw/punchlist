## Goal
Remove the accent tint from the (x) clear button in InputBar so it renders in a neutral color without any app tint applied.

## Context
The clear button lives in `Punchlist/Views/InputBar.swift` at lines 20–25. It uses `Image(systemName: "xmark.circle.fill")` with `.foregroundStyle(.secondary)`. SwiftUI `Button` applies the app's accent color to its label by default, which overrides or tints the foreground style. Adding `.buttonStyle(.plain)` disables that default button tinting behavior, letting `.foregroundStyle(.secondary)` render as clean grey.

**Current repo state:** A prior failed attempt left two out-of-scope staged changes:
- `Punchlist/ViewModels/PunchlistViewModel.swift` — staged removal of `pendingQueue`/`drainQueue()` (this violated the committed INVARIANTS.md at review time)
- `PunchlistTests/PollingFallbackTests.swift` — staged test doc edits to match the above removal

These staged changes must be reverted before committing, so this ticket's commit contains only the InputBar fix. The correct InputBar.swift change (`.buttonStyle(.plain)`) was never applied — the file on disk still lacks it.

## Approach
Revert the two out-of-scope staged files back to HEAD, then apply the single correct change to InputBar.swift.

## Tasks
1. **[git reset HEAD Punchlist/ViewModels/PunchlistViewModel.swift PunchlistTests/PollingFallbackTests.swift]** — Unstage the out-of-scope changes to PunchlistViewModel.swift and PollingFallbackTests.swift. This restores both files to the committed HEAD state. (Do NOT use `git checkout` or `git restore` — just unstage with `git reset HEAD` so the working tree changes can be discarded separately if needed, or use `git restore --staged` to unstage without touching disk content.)
   Verify: `git status` shows no staged changes for those two files.

2. **[Punchlist/Views/InputBar.swift:25]** — Add `.buttonStyle(.plain)` to the `Button` that clears the text field (the one with `xmark.circle.fill`). Place it after the closing brace of the `label:` trailing closure, before the closing `}` of the `if !text.isEmpty` block.
   Verify: Build succeeds; the (x) button renders grey/secondary without any blue or accent tint.

## Open Questions
None.
