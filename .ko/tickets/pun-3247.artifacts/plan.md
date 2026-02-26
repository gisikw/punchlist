## Goal
Show tickets completed during an agent run with a reviewable completion indicator.

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
- `/Punchlist/Views/ItemRow.swift` - individual item rendering
- `/Punchlist/Services/KoAPI.swift` - backend API wrapper

**Existing Patterns:**
- State stored in `@Observable` view model classes
- Agent toggle renders as Capsule with sliding circle (lines 127-143 in ContentView)
- No tests in project — manual verification required
- Personal list shows all items; project lists filter out `done` items (line 313 in ViewModel)

## Approach
Track agent start timestamp locally in PunchlistViewModel. When agent runs, include completed tickets with `modified` timestamp after agent start. When agent stops, replace slider with a completion circle indicator. Tapping the circle toggles between showing/hiding the session's completed tickets. Parse `modified` timestamp (ISO8601) from backend to filter tickets.

## Tasks
1. [Punchlist/Models/Item.swift] — Add `modified: String?` field to Item struct with CodingKey mapping.
   Verify: Build succeeds; Item decoder handles existing data.

2. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add `agentSessionStartTime: Date?` property. Set it when agent starts (in `toggleAgent()` when transitioning to .running). Clear it on project switch.
   Verify: Agent start captures timestamp; switching projects resets it.

3. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add `showCompletedFromSession: Bool` property (defaults false). When true, modify `filtered()` to include closed items where `modified >= agentSessionStartTime`.
   Verify: Toggle property shows/hides session-completed tickets in filtered results.

4. [Punchlist/ViewModels/PunchlistViewModel.swift] — When agent stops (toggleAgent transitions to .notRunning), keep agentSessionStartTime but mark session as "reviewable" via new `hasReviewableSession: Bool` computed property.
   Verify: Agent stop preserves session timestamp for filtering.

5. [Punchlist/Views/ContentView.swift] — Replace agent toggle UI logic. Show slider when agent provisioned. When `hasReviewableSession && !agentState.running`, show green completion circle instead. Tapping circle toggles `showCompletedFromSession` and restores inactive slider visual.
   Verify: UI transitions from slider → completion circle on agent stop; circle tap toggles ticket visibility.

6. [Punchlist/Views/ContentView.swift] — Modify header logic to clear review session when user switches projects or dismisses picker.
   Verify: Switching projects clears completion circle and resets ticket filter.

## Open Questions
1. **Modified timestamp format** — Items from backend have `modified` field (ISO8601). Confirm Item decoding handles optional `modified` field gracefully for items without it (older data).

2. **Circle icon/style** — Use filled green circle to match completed item aesthetic, or different treatment? Recommend filled circle with checkmark icon to signal "review completed work".

3. **Persistence** — Should session timestamp persist across app restarts via UserDefaults, or reset on foreground? Recommend reset — completed tickets remain server-side, no need for durable local state.

4. **Multiple sessions** — If user starts agent twice in succession without reviewing, should we show items from both sessions or only most recent? Recommend most recent only — simpler mental model, agent runs typically address current scope.
