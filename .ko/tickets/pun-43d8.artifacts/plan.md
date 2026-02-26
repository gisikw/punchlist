## Goal
Make the completion circle (checkmark) at the top of project views dismiss the agent session indicator when tapped.

## Context
When an agent finishes running on a project, a green checkmark circle appears at the top center of the header (ContentView.swift:148-158). This is shown when `viewModel.hasReviewableSession` is true, which means there's a completed agent session (`agentSessionStartTime != nil && agentState != .running`).

Currently, tapping this circle toggles `showCompletedFromSession`, which only changes the opacity (0.6 vs 1.0) but doesn't clear the session. The ticket asks for it to clear the indicator entirely.

The `clearAgentSession()` method already exists in PunchlistViewModel.swift:274-279 and does exactly what's needed:
- Sets `agentSessionStartTime` to nil
- Sets `showCompletedFromSession` to false
- Removes both keys from UserDefaults

This clearing behavior is already used in the `dismissPicker()` flow (ContentView.swift:170).

## Approach
Change the `completionCircle` button action from toggling `showCompletedFromSession` to calling `viewModel.clearAgentSession()`. This will clear the session state and make `hasReviewableSession` return false, which will cause the completion circle to disappear from the UI.

## Tasks
1. [Punchlist/Views/ContentView.swift:completionCircle] — Replace the button action on line 150 from `viewModel.showCompletedFromSession.toggle()` to `viewModel.clearAgentSession()`. Remove the opacity animation that depends on `showCompletedFromSession` (lines 155-156) since the indicator will disappear entirely instead of dimming.
   Verify: Build with `just check` to confirm no compile errors.

2. Manual test — Run the app on simulator, switch to a project with a completed agent session, tap the checkmark circle, verify it disappears.
   Verify: The completion circle disappears after tap and doesn't reappear until a new agent session completes.

## Open Questions
None — the implementation is straightforward. The `clearAgentSession()` method already exists and is used elsewhere in the codebase. The only change needed is wiring the button tap to call it instead of toggling the visibility flag.
