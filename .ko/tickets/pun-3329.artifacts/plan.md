## Goal
Make pulse animation apply to both in_progress tickets AND tickets with unanswered plan questions, while fixing transient pulsing on tickets during status transitions.

## Context
The pulse animation system is currently implemented in `ItemRow.swift`:
- `hasPulse` (line 37-39) controls whether a ticket should pulse - currently only returns true for `in_progress` status
- `pulseActive` (line 15) is a @State variable that drives the animation timing
- Animation appears in border opacity (line 91), shadow opacity (line 93), and circle scale (line 266)
- `onChange(of: hasPulse)` (lines 102-110) manages animation lifecycle but has timing issues during transitions

The ticket pun-3ea3 identified that recently blocked tickets show transient pulsing because `pulseActive` may still be true when status changes, before the view re-renders. The solution there recommended checking `hasPulse && pulseActive` explicitly instead of nested ternaries.

Plan questions are stored in `Item.planQuestions` (optional array) and displayed in `PlanQuestionsView` when a blocked item is expanded. There's no current mechanism to track which questions are unanswered - the app tracks user selections in `ContentView.questionSelections` and `questionOtherText` state dictionaries, but these are ephemeral UI state, not persisted data.

## Approach
Extend `hasPulse` to also return true when an item has unanswered plan questions. We need to add logic to determine if questions exist and are unanswered. Since question answers aren't tracked in the Item model (they're submitted to the server immediately), we'll treat any item with non-empty `planQuestions` array as having "open" questions. The pulse should activate for both in_progress items AND items with plan questions.

Additionally, fix the transient pulsing issue by making the opacity calculations explicitly check both `hasPulse && pulseActive` together, preventing old animation state from showing through during transitions.

## Tasks
1. [Punchlist/Views/ItemRow.swift:hasPulse] — Change `hasPulse` computed property to return `isInProgress || hasOpenPlanQuestions` where `hasOpenPlanQuestions` checks if `item.planQuestions` is non-nil and non-empty.
   Verify: Items with plan questions show pulse animation even if not in_progress.

2. [Punchlist/Views/ItemRow.swift:overlay+shadow] — Update border stroke opacity (line 91) and shadow opacity (line 93) to explicitly check `hasPulse && pulseActive` instead of the nested ternary pattern. This prevents transient pulsing when `pulseActive` lingers during status transitions.
   Verify: Manually test status transitions - blocked items should never pulse unless they have plan questions.

3. [Punchlist/Views/ItemRow.swift:circle] — Update circle fill opacity (line 245) to use the same explicit `hasPulse && pulseActive` check for consistency.
   Verify: Circle background animation matches border/shadow behavior.

## Open Questions
None - the implementation is straightforward. The requirement is clear: pulse should indicate either active work (in_progress) OR pending input (unanswered questions). The transient pulsing fix is a direct application of the pun-3ea3 findings.
