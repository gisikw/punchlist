## Goal
Ensure completed tasks always show in personal view from cold start, not just after toggling projects.

## Context
The app has two data sources for items:
1. **SSE (Server-Sent Events)**: Real-time updates via `/subscribe/#user`
2. **REST API**: Initial fetch via `ko ls --project=user --json`

**Confirmed**: The backend SSE endpoint DOES return completed items. This is a client-side race condition, not a backend issue.

In `PunchlistViewModel.swift`, the `filtered()` method (line 383-407) explicitly returns ALL items for personal view (`if isPersonal { return items }`), so completed tasks should always be visible.

**The Race Condition:**

On cold start (lines 54-106):
- Line 66: SSE starts with a callback: `self.items = self.filtered(items)`
- Line 79-106: Async Task fetches projects/items via REST
- Line 103-104: REST fetch completes first, sets `self.items = self.filtered(fetched)` with ALL items including completed ones
- **Line 68: SSE callback fires and OVERWRITES items** when SSE connection completes

When toggling projects (lines 143-166):
- Line 156: SSE disconnects and reconnects to new project
- Line 159-163: REST fetch completes while SSE is reconnecting
- **Works correctly** because SSE reconnection takes time, so REST fetch result is preserved

The bug: The initial SSE callback unconditionally overwrites `self.items` even if the REST fetch has already populated data. On cold start, the REST fetch includes completed items, but if the SSE callback fires shortly after, it may be using an incomplete initial state snapshot and overwrites the correct data.

## Approach
Add a flag to track whether the initial REST fetch has completed on cold start. Modify the SSE callback to only overwrite items if:
1. This is NOT the first SSE connection on cold start, OR
2. The initial REST fetch hasn't completed yet

This preserves the REST fetch data on cold start while still allowing SSE updates to flow through after the initial load.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift] — Add a private `hasInitialLoad: Bool = false` property to track whether the initial REST fetch has completed on cold start.
   Verify: Property compiles and is initialized correctly.

2. [Punchlist/ViewModels/PunchlistViewModel.swift:103-105] — After the initial REST fetch succeeds (line 103), set `self.hasInitialLoad = true` to mark that the initial data is loaded.
   Verify: Flag is set when REST fetch completes.

3. [Punchlist/ViewModels/PunchlistViewModel.swift:66-72] — Modify the SSE callback to check if `hasInitialLoad` is true before overwriting items. If `hasInitialLoad` is true and `self.items` is not empty, skip the initial overwrite. For subsequent SSE events, always apply updates.
   Verify: SSE callback respects the flag and doesn't overwrite REST fetch data on cold start.

4. [Punchlist/ViewModels/PunchlistViewModel.swift:143-166] — In `switchToProject()`, set `hasInitialLoad = false` when switching projects so that SSE data is properly loaded for the new project.
   Verify: Project switching still works correctly.

5. [Testing] — Build and run the app. On cold start to personal view, verify that completed tasks are visible immediately. Toggle to a project and back to personal to verify the behavior still works correctly.
   Verify: Completed items visible in both scenarios.

## Open Questions
None — the backend returns completed items correctly, this is purely a client-side race condition fix.
