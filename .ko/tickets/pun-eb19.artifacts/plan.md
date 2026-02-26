## Goal
Prevent newly created tickets from briefly appearing then disappearing in project views.

## Context
The issue occurs when creating a ticket in a project view. The ticket appears immediately, then vanishes after a few seconds, reappearing only when the app is closed or the project is switched.

Key files:
- `PunchlistViewModel.swift:52-58` — SSE event handler that replaces entire items array with filtered results
- `PunchlistViewModel.swift:153-175` — addItem() action that fires REST API call when connected
- `PunchlistViewModel.swift:365-386` — filtered() method that hides closed items in project views
- `SSEManager.swift:146-184` — SSEDelegate that accumulates items from SSE stream
- `Item.swift:32` — done property derived from status == "closed"

The SSE architecture works as follows:
- Server sends complete project state on each mutation
- Items arrive as separate `data:` lines in SSE stream
- Empty line signals end of batch, triggering `onItems()` callback
- ViewModel replaces entire `items` array with `filtered(items)`

The filtering logic (lines 365-386):
- Personal view: shows all items
- Project view: hides items where `done == true` (status == "closed")
- Exception: shows completed items from current agent session when review mode is active

The issue is a **state synchronization race**:
1. REST API `addItem()` succeeds and returns ticket ID
2. Server broadcasts SSE update with full project state
3. SSE event arrives and ViewModel calls `self.items = self.filtered(items)`
4. If the newly created ticket has `status: "closed"` OR if there's a timing issue where an SSE update arrives **before** the server has fully committed the new ticket to the broadcast state, the ticket gets filtered out
5. A subsequent SSE update (seconds later) arrives with the correct state, and the ticket reappears
6. When switching projects or closing the app, a fresh REST fetch happens which gets the correct state

Most likely cause: The server sends an SSE update immediately after the mutation, but there could be two scenarios:
1. The new ticket is created with `status: "closed"` initially (unlikely but possible)
2. The SSE stream sends a stale batch before the mutation is fully committed to the broadcast state (race condition)

## Approach
Add optimistic UI handling for the addItem() case in project views. When a ticket is successfully created via REST API in a project (non-personal) view, temporarily add it to the local items array until the next SSE update confirms it. Track pending additions by ticket ID, and only apply filtering to items that aren't in the pending set. Clear pending IDs when SSE updates arrive with those IDs present.

This matches the existing offline optimistic update pattern (lines 166-172), but extends it to cover the connected case where SSE updates lag behind REST mutations.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add a `pendingAdditions: Set<String>` property to track ticket IDs that were just created and haven't been confirmed via SSE yet.
   Verify: Code compiles.

2. [Punchlist/ViewModels/PunchlistViewModel.swift:addItem] — When `isConnected` and not personal view, after calling `api.addItem()`, capture the returned ticket ID and add it to `pendingAdditions`. Also create a temporary Item with that ID and insert it into the items array for immediate display.
   Verify: Code compiles, no syntax errors.

3. [Punchlist/ViewModels/PunchlistViewModel.swift:filtered] — Modify filtering logic to exclude items whose ID is in `pendingAdditions` from the `done` check. These items should always be shown regardless of their status.
   Verify: Code compiles.

4. [Punchlist/ViewModels/PunchlistViewModel.swift] — In the SSE callback (line 52-58), after calling `filtered()`, iterate through the received items and remove any IDs from `pendingAdditions` that are present in the SSE update (confirming they've been broadcast).
   Verify: Code compiles and follows the existing callback pattern.

5. [Punchlist/ViewModels/PunchlistViewModel.swift:switchToProject] — Clear `pendingAdditions` when switching projects to avoid stale state.
   Verify: Code compiles.

6. Manual verification — In simulator or device, switch to a project view (not personal), create a new ticket, verify it appears immediately and doesn't disappear. Close and reopen the project or app to confirm the ticket persists correctly.
   Verify: Ticket remains visible continuously after creation.

## Open Questions
Should we add a timeout to automatically clear pending additions after a certain duration (e.g., 10 seconds) in case the SSE update never arrives? This would prevent tickets from being permanently "pinned" visible if the SSE stream breaks after the mutation.

Current assumption: SSE is reliable enough that if the REST call succeeds, an SSE update will eventually arrive. If this assumption is wrong, we may need the timeout safety valve.
