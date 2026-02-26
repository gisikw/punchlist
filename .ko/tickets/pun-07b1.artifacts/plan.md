## Goal
Make the hold bar action on blocked tickets open the ticket when there are no open questions, or close the ticket when there are open questions.

## Context
The hold bar UI in `ItemRow.swift` (lines 175-230) currently always calls `onToggle()` after a successful hold gesture, which toggles the ticket between open/closed state via `PunchlistViewModel.toggleItem()`. For blocked items, this behavior should be conditional:

- Blocked tickets with no open questions → hold should **open** the ticket (assumption: it failed/was held, now ready to be actionable)
- Blocked tickets with open questions → hold should **close** the ticket (if we wanted it actionable, we'd have answered the questions)

Currently, `questions: [PlanQuestion]` is passed to `ItemRow` from `ContentView` (line 194) via `item.planQuestions ?? []`. The hold bar is only shown when `isExpanded && !item.done` (line 70).

The view model has `toggleItem()` which calls either `api.openItem()` or `api.closeItem()` based on `item.done` state. We need conditional logic to call the right API endpoint based on whether questions exist.

## Approach
Modify `ItemRow.swift` to pass a different action to the hold bar based on blocked state and question presence. When a blocked item has no questions, the hold gesture should explicitly call open (not toggle). When a blocked item has questions, it should explicitly call close (not toggle). For non-blocked items, keep the existing toggle behavior.

## Tasks
1. [Punchlist/Views/ItemRow.swift:holdToCloseBar] — Update the hold gesture completion handler (line 205) to conditionally call different actions. Replace the hardcoded `onToggle()` with logic that checks `isBlocked` and `questions.isEmpty`. When `isBlocked && questions.isEmpty`, call a new `onOpen` callback. When `isBlocked && !questions.isEmpty`, call a new `onClose` callback. When not blocked, keep calling `onToggle()`.
   Verify: Build succeeds, type errors are resolved.

2. [Punchlist/Views/ItemRow.swift:ItemRow] — Add two new closure parameters to `ItemRow`: `onOpen: () -> Void` and `onClose: () -> Void` alongside the existing `onToggle` callback (around line 10-13).
   Verify: Build succeeds.

3. [Punchlist/Views/ContentView.swift:ItemRow] — Pass the new callbacks when constructing `ItemRow` (line 190). For `onOpen`, pass `{ viewModel.toggleItem(item) }` with an inline guard that only opens if closed. For `onClose`, pass `{ viewModel.toggleItem(item) }` with an inline guard that only closes if open. Or create dedicated wrapper closures that check state before calling the API.
   Verify: Build succeeds, no runtime crashes.

4. [Punchlist/ViewModels/PunchlistViewModel.swift:openItem] — Add dedicated `openItem(_ item: Item)` method that unconditionally calls `api.openItem(id: item.id)`. Model this after `toggleItem()` (lines 209-233) but remove the conditional logic — always open, never close.
   Verify: Code compiles.

5. [Punchlist/ViewModels/PunchlistViewModel.swift:closeItem] — Add dedicated `closeItem(_ item: Item)` method that unconditionally calls `api.closeItem(id: item.id)`. Model this after `toggleItem()` but always close, never open.
   Verify: Code compiles.

6. [Punchlist/Views/ContentView.swift:ItemRow] — Update the `onOpen` and `onClose` callbacks to use the new dedicated methods: `onOpen: { viewModel.openItem(item) }` and `onClose: { viewModel.closeItem(item) }`.
   Verify: Build succeeds, manual test with a blocked ticket shows correct behavior.

7. [PunchlistTests/] — Add a new test file `HoldBarBehaviorTests.swift` that verifies the conditional hold behavior. Test cases: blocked item with no questions should open, blocked item with questions should close, non-blocked item should toggle.
   Verify: `xcodebuild test` passes for the new test file.

## Open Questions
None — the ticket specifies the exact behavior for both branches (no questions → open, has questions → close). The implementation path is straightforward: add conditional logic based on `isBlocked` and `questions.isEmpty`, create dedicated open/close methods in the view model, and wire up the callbacks.
