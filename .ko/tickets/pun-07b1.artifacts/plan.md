## Goal
Make the hold bar on blocked tickets context-aware: open the ticket if there are no open questions (ready to work again), close it if there are open questions (can't proceed without answers).

## Context
- ItemRow.swift (lines 180-234) contains the hold-to-close bar gesture logic
- Currently the hold bar always calls `onToggle()` which maps to `viewModel.toggleItem(item)` (line 210)
- `toggleItem` in PunchlistViewModel (lines 203-227) checks `item.done` and either opens or closes
- ItemRow already receives `questions: [PlanQuestion]` prop (line 7, passed from `item.planQuestions ?? []`)
- ItemRow has `isBlocked` computed property (lines 25-27) checking `item.status == "blocked"`
- KoAPI has both `openItem(id:)` and `closeItem(id:)` methods (lines 32-38)

The hold bar should:
- For non-blocked items: toggle as normal (existing behavior)
- For blocked items with no questions: call open (make actionable again)
- For blocked items with open questions: call close (can't proceed)

## Approach
Add separate `onOpen` and `onClose` callbacks to ItemRow alongside the existing `onToggle`. Update the hold bar gesture to conditionally call the appropriate action based on `isBlocked` and `questions.isEmpty`. Wire up new methods in PunchlistViewModel to explicitly open/close items, and connect them in ContentView.

## Tasks
1. [Punchlist/Views/ItemRow.swift:10-13] — Add `onOpen: () -> Void` and `onClose: () -> Void` callback properties after `onToggle`.
   Verify: Code compiles after updating all ItemRow call sites.

2. [Punchlist/Views/ItemRow.swift:210] — Replace the single `onToggle()` call with conditional logic: if `isBlocked`, check `questions.isEmpty` to call either `onOpen()` or `onClose()`; otherwise call `onToggle()` for normal behavior.
   Verify: Logic follows ticket requirements.

3. [Punchlist/ViewModels/PunchlistViewModel.swift:203] — Add `openItem(_ item: Item)` method that explicitly calls `api.openItem(id:)` with proper offline queue handling, following the same pattern as `toggleItem`.
   Verify: Method structure matches existing action methods (toggleItem, bumpItem, etc.).

4. [Punchlist/ViewModels/PunchlistViewModel.swift:228] — Add `closeItem(_ item: Item)` method that explicitly calls `api.closeItem(id:)` with proper offline queue handling, following the same pattern as `toggleItem`.
   Verify: Method structure matches existing action methods.

5. [Punchlist/Views/ContentView.swift:191-217] — Update the ItemRow initialization to pass `onOpen: { viewModel.openItem(item) }` and `onClose: { viewModel.closeItem(item) }` callbacks.
   Verify: App compiles and runs without errors.

## Open Questions
None — the implementation is straightforward. The ticket clearly specifies the behavior, the KoAPI already has separate open/close methods, and the ItemRow has all the state needed (isBlocked, questions) to make the decision.
