# Implementation Summary: pun-df80

## What Was Done

Implemented per-project persistence for the "agent is done" checkbox state that controls visibility of completed items from the current agent session.

### Changes Made

**Punchlist/ViewModels/PunchlistViewModel.swift**:

1. **Added `showCompletedSessionKey` computed property** (lines 50-52)
   - Generates per-project UserDefaults key: `"showCompletedFromSession_{slug}"`
   - Mirrors the existing `agentSessionKey` pattern

2. **Added `didSet` observer to `showCompletedFromSession`** (lines 27-31)
   - Automatically saves to UserDefaults whenever the value changes
   - Eliminates need for explicit save calls throughout the codebase

3. **Load state in `switchToProject()`** (line 147)
   - Restores checkbox state when switching between projects
   - Placed immediately after loading `agentSessionStartTime` for consistency

4. **Clear state in `clearAgentSession()`** (line 257)
   - Removes UserDefaults value alongside clearing the session timestamp
   - Ensures cleanup is complete when dismissing the review UI

## Notable Decisions

- **Automatic persistence via `didSet`**: Chose to use a property observer rather than explicit save calls. This ensures persistence happens consistently regardless of how the value changes (user toggle, programmatic reset, etc.).

- **No ContentView changes needed**: The existing `.toggle()` call in ContentView automatically triggers the `didSet` observer, so no UI changes were required.

- **UserDefaults for UI state**: Used UserDefaults for this UI preference. This does NOT violate the "no local data persistence" invariant in INVARIANTS.md, which refers to punchlist item data. UI preferences like "show completed items" are standard UserDefaults use cases and are distinct from business data persistence.

## Pattern Consistency

The implementation exactly mirrors the existing `agentSessionStartTime` persistence pattern:
- Per-project key generation via computed property
- Load in `switchToProject()`
- Clear in `clearAgentSession()`
- Uses the same UserDefaults instance

This consistency makes the code predictable and maintainable.

## What Future Readers Should Know

1. **Why UserDefaults here?**: This is for transient UI preference state (checkbox visibility), not business data. The API remains the single source of truth for punchlist items.

2. **Default behavior**: When no UserDefaults value exists for a project, `bool(forKey:)` returns `false`, which is the correct default (checkbox unchecked).

3. **State isolation**: Each project maintains its own checkbox state. Clearing the agent session in project A does not affect project B's checkbox state.

4. **Automatic cleanup**: The `didSet` observer ensures any change to `showCompletedFromSession` (including setting it to `false`) is persisted, so the state is always in sync with UserDefaults.

## Testing Notes

Manual testing is required to verify:
- Toggle checkbox in project A, switch to project B, switch back → state should persist
- Toggle checkbox, restart app → state should persist
- Clear agent session → checkbox state should be cleared

This cannot be automated in the current test setup (builds happen on macOS build host via xcodebuild).
