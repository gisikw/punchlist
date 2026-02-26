---
id: pun-07b1
status: closed
deps: []
created: 2026-02-26T17:18:51Z
type: task
priority: 2
---
# Let's make the hold bar action on blocked ticket behave differently: if there are no open questions, it should _open_ the ticket (assumption is it failed or we held on it, now we're ready to make it actionable again). If there _are_ open questions, then hold should still close the ticket (if we wanted to make it actionable, we could have answered the questions)

## Notes

**2026-02-26 21:15:34 UTC:** ko: FAIL at node 'classify' — node 'classify' failed after 3 attempts: no fenced JSON block found in output

**2026-02-26 21:23:33 UTC:** # Implementation Summary: Context-Aware Hold Bar for Blocked Tickets

## What Was Done

Successfully implemented ticket pun-07b1 to make the hold bar action on blocked tickets behave differently based on whether there are open questions:

- **No open questions** → hold opens the ticket (ready to work again)
- **Has open questions** → hold closes the ticket (can't proceed without answers)
- **Not blocked** → hold toggles as normal (existing behavior)

## Changes Made

### 1. ItemRow.swift (lines 10-12, 212-220)
- Added `onOpen` and `onClose` callback properties alongside existing `onToggle`
- Updated hold gesture completion handler with conditional logic:
  ```swift
  if isBlocked {
      if questions.isEmpty {
          onOpen()
      } else {
          onClose()
      }
  } else {
      onToggle()
  }
  ```

### 2. PunchlistViewModel.swift (lines 229-263)
- Added `openItem(_ item: Item)` method - explicitly calls `api.openItem(id:)`, sets `done = false`, moves to top
- Added `closeItem(_ item: Item)` method - explicitly calls `api.closeItem(id:)`, sets `done = true`, moves to bottom
- Both follow existing patterns with proper offline queue handling

### 3. ContentView.swift (lines 199-200)
- Wired up new callbacks in ItemRow initialization:
  - `onOpen: { viewModel.openItem(item) }`
  - `onClose: { viewModel.closeItem(item) }`

## Notable Decisions

- All methods follow the existing fire-and-forget mutation pattern (INVARIANTS.md compliant)
- Offline queue support maintained for both open and close actions
- No deviations from the plan - straightforward implementation
- All tests pass (35 existing tests)

## Future Considerations

The conditional logic is now centralized in ItemRow.swift:212-220. If additional hold bar behaviors are needed for other ticket states, this is the single location to modify.

**2026-02-26 21:23:33 UTC:** ko: SUCCEED
