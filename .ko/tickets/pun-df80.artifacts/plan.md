## Goal
Persist the "show completed from session" checkbox state per-project across app restarts and project switches.

## Context
The "agent is done" review UI has two key pieces of state:
- **agentSessionStartTime**: A per-project timestamp stored in UserDefaults with key `"agentSessionStartTime_{slug}"`. This persists across app restarts and project switches (lines 134-136, 245, 263 in PunchlistViewModel.swift).
- **showCompletedFromSession**: A transient Bool that controls whether completed items from the current agent session are displayed. This defaults to `false` and is cleared when switching projects (line 27, 244 in PunchlistViewModel.swift).

The checkbox is shown when `hasReviewableSession` returns true (an agent session exists but isn't running). Tapping the checkmark toggles `showCompletedFromSession` (line 150 in ContentView.swift), but this state is lost when:
1. Switching away from the project
2. Switching back to the project
3. Restarting the app

The project already has a pattern for per-project UserDefaults persistence via `agentSessionKey` (line 42-44 in PunchlistViewModel.swift).

## Approach
Mirror the existing `agentSessionStartTime` persistence pattern. Add a `showCompletedSessionKey` computed property that generates a per-project UserDefaults key like `"showCompletedFromSession_{slug}"`. Load this state when switching projects (in `switchToProject`), save it when toggling the checkbox (via a new property observer or explicit save), and clear it when calling `clearAgentSession`.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift:showCompletedFromSession] — Change from a simple Bool to a property that persists to UserDefaults per-project.
   - Add a `showCompletedSessionKey` computed property that returns `"showCompletedFromSession_\(currentProjectSlug)"`.
   - Load `showCompletedFromSession` from UserDefaults in `switchToProject` (after loading `agentSessionStartTime`).
   - Save `showCompletedFromSession` to UserDefaults whenever it changes (add a `didSet` observer or refactor into a setter).
   - Clear the UserDefaults value in `clearAgentSession`.
   Verify: Build succeeds, no compiler errors.

2. [Punchlist/Views/ContentView.swift:completionCircle] — Update the toggle action to ensure the new value is saved.
   - If the ViewModel now handles persistence automatically via `didSet`, no changes needed.
   - If not, ensure `viewModel.showCompletedFromSession.toggle()` triggers the save.
   Verify: Build succeeds, UI still responds to taps.

3. Manual testing: Run the app, toggle the checkbox in a project view, switch away, switch back — verify the checkbox state persists. Restart the app — verify the checkbox state persists.

## Open Questions
None. The implementation follows the established pattern for `agentSessionStartTime` and the requirements are clear.
