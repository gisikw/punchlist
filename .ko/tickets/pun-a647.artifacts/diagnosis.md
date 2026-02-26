# Diagnosis: Agent Toggle Visible When Project Drawer is Open

## Symptoms

When the project drawer (project picker) is open, the agent toggle remains visible in the center of the header. This creates visual clutter and reduces clarity of the UI state—when the drawer is open, the user is focused on selecting a project, and the agent toggle becomes a distraction.

## Root Cause

The issue is in the **header layout structure** in `ContentView.swift` (lines 91-124).

The header uses a `ZStack` to overlay the agent toggle on top of the left/right header content:

```swift
private var header: some View {
    ZStack {
        HStack {
            Text("punchlist")
            Spacer()
            Text(projectTag ?? "")
                .onTapGesture {
                    // toggles showProjectPicker
                }
        }

        if let agentState = viewModel.agentState,
           agentState != .notProvisioned,
           !viewModel.isPersonal {
            agentToggle(isRunning: agentState == .running)
        }
    }
}
```

The agent toggle is conditionally rendered based on:
- `agentState` exists and is not `.notProvisioned`
- The current project is not personal (`!viewModel.isPersonal`)

**However, there is no check for `showProjectPicker` state.**

The toggle is always visible when viewing a project (non-personal) with a provisioned agent, regardless of whether the project drawer is open. The ZStack positions the toggle in the center of the header, where it overlaps with the dimmed content area when the drawer is displayed.

## Affected Code

**File:** `Punchlist/Views/ContentView.swift`

**Lines 115-120:** Agent toggle conditional rendering
```swift
if let agentState = viewModel.agentState,
   agentState != .notProvisioned,
   !viewModel.isPersonal {
    agentToggle(isRunning: agentState == .running)
}
```

This condition needs to include a check for `showProjectPicker`.

## Recommended Fix

Add a check to hide the agent toggle when the project picker is visible. Modify the conditional at lines 115-120 to:

```swift
if let agentState = viewModel.agentState,
   agentState != .notProvisioned,
   !viewModel.isPersonal,
   !showProjectPicker {
    agentToggle(isRunning: agentState == .running)
}
```

This ensures the agent toggle is only visible when:
1. An agent state exists (not nil)
2. The agent is provisioned (not `.notProvisioned`)
3. The current project is not personal
4. **The project picker is not currently displayed**

### Alternative Approach

If animation is desired, the toggle could be wrapped with opacity/offset animations that smoothly hide it when the drawer opens:

```swift
if let agentState = viewModel.agentState,
   agentState != .notProvisioned,
   !viewModel.isPersonal {
    agentToggle(isRunning: agentState == .running)
        .opacity(showProjectPicker ? 0 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showProjectPicker)
}
```

However, the simple boolean check is cleaner and matches the pattern used elsewhere in the codebase (see line 18 where the projectPicker itself is conditionally rendered).

## Risk Assessment

**Risk Level:** Very Low

**Potential Issues:**
- None identified. This is a purely visual change that adds an additional rendering condition.
- The logic is simple and matches existing patterns in the codebase (conditional rendering based on `showProjectPicker`).
- No state management changes, no business logic impact.

**What Could Go Wrong:**
- If the recommended fix is not tested, it's possible the toggle could fail to reappear after dismissing the picker, but this is unlikely given that `showProjectPicker` is properly managed via `withAnimation` blocks throughout the code (lines 72-74, 109-112, 152-154).

**Affected Areas:**
- Only the header visual presentation
- No impact on agent functionality, project switching, or data persistence

**Testing:**
1. Open the app with a non-personal project selected
2. Verify agent toggle is visible in the header
3. Tap the project tag to open the project drawer
4. Verify agent toggle disappears (after fix)
5. Select a different project or tap outside to dismiss drawer
6. Verify agent toggle reappears (after fix)
7. Verify toggle still functions correctly (starts/stops agent)
