## Goal
Hide the agent toggle when the project drawer is open.

## Context
The header in `ContentView.swift` uses a `ZStack` to overlay the agent toggle in the center of the header (lines 91-124). The toggle currently renders whenever:
1. An agent state exists (not nil)
2. The agent is provisioned (not `.notProvisioned`)
3. The current project is not personal

The `showProjectPicker` state variable controls drawer visibility. When true, the drawer slides down from the header and a dimmed overlay appears over the main content area. However, the agent toggle condition doesn't check this state, so it remains visible and creates visual clutter when the drawer is open.

The existing code already uses `showProjectPicker` for conditional rendering elsewhere (line 18 for the drawer itself), so this pattern is established.

## Approach
Add `!showProjectPicker` to the existing conditional that renders the agent toggle. This matches the established pattern in the codebase for drawer-aware UI and is the cleanest solution.

## Tasks
1. [Punchlist/Views/ContentView.swift:115-120] — Add `!showProjectPicker` as an additional condition in the agent toggle's `if` statement. The existing condition checks `agentState`, `.notProvisioned`, and `!viewModel.isPersonal`. Add `!showProjectPicker` as the fourth condition to hide the toggle when the drawer is open.
   Verify: Build the app, open a project view (not personal), verify toggle is visible, tap project tag to open drawer, verify toggle disappears.

## Open Questions
None — the fix is straightforward and matches existing patterns. The `showProjectPicker` state is already managed consistently throughout the view with proper animations.
