## Goal
Add a manual block/unblock affordance (long-press to block) for tickets that don't have plan-questions.

## Context
The app currently handles two blocking scenarios:
1. **Blocked with plan-questions**: Item's `status == "blocked"` and `planQuestions` array is populated. UI shows `PlanQuestionsView` with pills and answer submission. Answering questions calls `ko update --answers` which auto-unblocks.
2. **Blocked without plan-questions**: Item's `status == "blocked"` but `planQuestions` is empty or nil. Currently shows nothing special — no UI affordance to unblock.

The ticket asks for scenario #2 to have a manual block/unblock UI.

Current blocking flow in ItemRow.swift:
- `isBlocked` computed property checks `item.status == "blocked"`
- Pink accent color and border when blocked
- Questions UI only shows when `isBlocked && !questions.isEmpty` (line 71)

Backend:
- `ko block <id> [reason]` — sets status to blocked with optional reason text
- `ko update <id> --status open` — unblocks (sets status back to open)
- `ko update <id> --answers '{...}'` — auto-unblocks when answering questions

KoAPI.swift has no block/unblock methods yet. It only has:
- `fetchQuestions`, `submitAnswers` for the questions flow
- `addItem`, `closeItem`, `openItem`, `bumpItem` for item mutations

The hold-to-close bar in ItemRow (line 175-230) provides a pattern:
- 200ms grace period before starting a 1.3s fill animation
- Quick tap (<200ms) collapses the card
- Release mid-hold cancels the action
- Completion triggers the action

## Approach
Add a long-press gesture to manually block/unblock tickets in the card body. When a ticket is blocked without questions, show a simple "Unblock" button instead of the questions UI.

## Tasks
1. [Punchlist/Services/KoAPI.swift] — Add `blockItem(id:reason:)` and `unblockItem(id:)` methods that call `ko block <id>` and `ko update <id> --status open`.
   Verify: Build succeeds, methods are callable from ViewModel.

2. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add `blockItem(_:)` and `unblockItem(_:)` actions that call the new KoAPI methods. Follow the same fire-and-forget pattern as `toggleItem`, `bumpItem`, etc. No offline queue needed (project items don't go offline the same way personal items do).
   Verify: Build succeeds, actions are callable from ContentView.

3. [Punchlist/Views/ItemRow.swift] — Add a long-press gesture to the card body (on the tappable region overlay) that fills a visual indicator and blocks the ticket after ~1.5s hold. Pattern after the hold-to-close bar: 200ms grace period, then 1.3s fill animation. Only show this on project items (not personal). Add state vars for hold tracking. Consider showing a subtle progress ring around the status circle or a fill overlay on the card background.
   Verify: Long-press on an unblocked project ticket visually indicates progress and blocks after hold completes. Quick tap still expands/toggles as before.

4. [Punchlist/Views/ItemRow.swift] — When `isBlocked && questions.isEmpty`, show a simple "Unblock" button below the expanded text instead of `PlanQuestionsView`. Style it consistently with the questions UI (pink accent, similar padding). Tapping it should call the unblock action passed from ContentView.
   Verify: Blocked ticket without questions shows Unblock button when expanded. Clicking it unblocks the ticket.

5. [Punchlist/Views/ContentView.swift] — Pass `onBlock` and `onUnblock` callbacks to ItemRow that call `viewModel.blockItem(item)` and `viewModel.unblockItem(item)`.
   Verify: Full flow works end-to-end. Long-press blocks, unblock button unblocks, UI updates correctly.

## Open Questions
1. **Long-press target**: Should the long-press gesture work on the entire card body (including when expanded), or only when the card is collapsed? Long-press on an expanded card might conflict with text selection if users want to copy the description.

2. **Block reason**: Should the manual block UI allow the user to specify a reason? The `ko block` command accepts an optional reason argument. If yes, this would need a text input field (perhaps appearing after the hold completes, before actually blocking). If no, just call `ko block <id>` with no reason.

3. **Personal vs project**: Should manual blocking be allowed on personal items, or only project items? The ticket mentions this in the context of the agent/questions flow, which only applies to projects. Personal items don't have the same status lifecycle.

4. **Visual feedback**: What should the long-press progress indicator look like? Options:
   - Progress ring around the status circle (like the hold-to-close bar)
   - Overlay fill on the card background
   - A dedicated blocking indicator bar (similar to hold-to-close)

5. **Unblock button placement**: Should the unblock button appear at the bottom of the expanded card (like the hold-to-close bar), or inline after the description? Should it be styled as a button, or as a tappable bar like hold-to-close?
