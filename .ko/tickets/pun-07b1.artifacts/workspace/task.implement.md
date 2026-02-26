Excellent! All tasks are complete. Let me provide a summary of the changes:

---

## Implementation Summary

I've successfully implemented all tasks from the plan to make the hold bar action on blocked tickets context-aware. Here's what was changed:

### Task 1: ItemRow.swift callbacks (lines 10-12)
- Added `onOpen: () -> Void` and `onClose: () -> Void` callback properties after `onToggle`
- This provides explicit callbacks for opening and closing items

### Task 2: ItemRow.swift conditional logic (lines 212-220)
- Replaced the single `onToggle()` call with conditional logic:
  - **Blocked items with no questions** → calls `onOpen()` (ready to work again)
  - **Blocked items with questions** → calls `onClose()` (can't proceed without answers)
  - **Non-blocked items** → calls `onToggle()` (normal behavior)

### Task 3: PunchlistViewModel.swift openItem method (lines 229-245)
- Added `openItem(_ item: Item)` method following the same pattern as `toggleItem`
- Includes proper offline queue handling: sets `done = false`, moves item to top of list
- Calls `api.openItem(id:)` when connected

### Task 4: PunchlistViewModel.swift closeItem method (lines 247-263)
- Added `closeItem(_ item: Item)` method following the same pattern as `toggleItem`
- Includes proper offline queue handling: sets `done = true`, moves item to bottom of list
- Calls `api.closeItem(id:)` when connected

### Task 5: ContentView.swift callback wiring (lines 199-200)
- Updated ItemRow initialization to pass proper callbacks:
  - `onOpen: { viewModel.openItem(item) }`
  - `onClose: { viewModel.closeItem(item) }`

**No deviations from the plan.** All changes follow existing patterns in the codebase and maintain consistency with the INVARIANTS.md requirements (no third-party dependencies, fire-and-forget mutations with offline queue support).
