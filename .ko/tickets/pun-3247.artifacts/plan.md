## Goal
Show tickets completed during an agent run with a reviewable completion indicator that persists across app restarts.

## Context
**Current Architecture:**
- SwiftUI iOS app with MVVM pattern
- `PunchlistViewModel` manages state, SSE subscription, and API calls
- `ContentView` renders the UI with an agent toggle (slider) for non-personal projects
- `Item` model has `done: Bool`, `status: String?`, `created: String`, no completion timestamp
- Project views currently hide closed items via `filtered()` method
- Agent state is tracked via `agentState: KoAPI.AgentState?` (.running, .notRunning, .notProvisioned)
- `KoAPI` provides REST interface to ko CLI; items include `modified` timestamp from backend

**Key Files:**
- `/Punchlist/Models/Item.swift` - Item data model
- `/Punchlist/ViewModels/PunchlistViewModel.swift` - business logic
- `/Punchlist/Views/ContentView.swift` - main UI with agent toggle
- `/Punchlist/Services/KoAPI.swift` - backend API wrapper

**Existing Patterns:**
- State stored in `@Observable` view model classes
- Agent toggle renders as Capsule with sliding circle (lines 127-143 in ContentView)
- No tests in project — manual verification required
- Personal list shows all items; project lists filter out `done` items (line 342 in ViewModel)

**Decisions Made:**
1. Modified timestamp handling: Optional field, filter gracefully when nil
2. Circle visual: Filled green circle with checkmark icon
3. Persistence: Session timestamp persists across app restarts via UserDefaults
4. Multiple sessions: Show only tickets from most recent session (overwrite on new agent start)

## Approach
Track agent start timestamp locally in PunchlistViewModel, persisted to UserDefaults per project. When agent runs, include completed tickets with `modified` timestamp after agent start. When agent stops, replace slider with a green completion circle. Tapping the circle toggles between showing/hiding the session's completed tickets. Parse `modified` timestamp (ISO8601) from backend to filter tickets. Each new agent start overwrites the previous session timestamp.

## Tasks
1. [Punchlist/Models/Item.swift] — Add `modified: String?` field to Item struct with CodingKey mapping. Update custom decoder to handle optional modified field.
   Verify: Build succeeds; Item decoder handles existing data gracefully when modified is missing.

2. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add `agentSessionStartTime: Date?` property and UserDefaults persistence. Create computed `agentSessionKey` using current project slug. Load session timestamp from UserDefaults on project switch. Save timestamp when agent starts (in `toggleAgent()` when transitioning to .running). Clear from UserDefaults when user explicitly switches projects or resets to personal.
   Verify: Agent start captures timestamp and persists to UserDefaults; switching projects loads correct session; app restart preserves session state.

3. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add `showCompletedFromSession: Bool` property (defaults false). Modify `filtered()` to include closed items where `modified` field exists, parses successfully as ISO8601 date, and is >= agentSessionStartTime, when showCompletedFromSession is true.
   Verify: Toggle property shows/hides session-completed tickets in filtered results; items without modified field are excluded gracefully.

4. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add `hasReviewableSession: Bool` computed property that returns true when agentSessionStartTime exists and agent is not currently running.
   Verify: Property correctly reflects reviewable state after agent stop.

5. [Punchlist/Views/ContentView.swift] — Replace agent toggle UI logic. Show slider when agent is provisioned and running, or when no reviewable session exists. When `hasReviewableSession` is true, show a tappable filled green circle with checkmark icon (SF Symbol "checkmark.circle.fill") sized at 22pt to match slider height. Tapping circle toggles `showCompletedFromSession` boolean. When showing completed items, render circle with lower opacity (0.6) to indicate active state.
   Verify: UI transitions from slider → completion circle on agent stop; circle tap toggles ticket visibility and opacity; visual matches spec.

6. [Punchlist/Views/ContentView.swift] — In `dismissPicker()`, clear agentSessionStartTime and showCompletedFromSession when resetting to personal project. In `switchToProject(slug:)` callback within projectPicker, do NOT clear session state (allow switching between projects while preserving review state).
   Verify: Dismissing picker clears completion circle; switching between non-personal projects preserves review UI; switching to personal hides it.

7. [Punchlist/ViewModels/PunchlistViewModel.swift] — In `switchToProject(slug:)`, load agentSessionStartTime from UserDefaults for the new project. Add helper method `clearAgentSession()` to remove both in-memory and persisted state.
   Verify: Switching projects loads appropriate session state; clearing works correctly.

## Open Questions
None. All architectural decisions have been resolved:
- Modified timestamp: optional field, gracefully handle missing values
- Visual treatment: filled green circle with checkmark icon (SF Symbol "checkmark.circle.fill")
- Persistence: UserDefaults keyed by project slug
- Multiple sessions: most recent session only (new agent start overwrites previous)
