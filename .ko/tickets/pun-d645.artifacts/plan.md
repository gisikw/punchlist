## Goal
Ensure completed tasks always show in personal view from cold start, not just after toggling projects.

## Context
The app has two data sources for items:
1. **SSE (Server-Sent Events)**: Real-time updates via `/subscribe/#user`
2. **REST API**: Initial fetch via `ko ls --project=user --json`

In `PunchlistViewModel.swift`, the `filtered()` method (line 377-398) explicitly returns ALL items for personal view (`if isPersonal { return items }`), bypassing any `showCompletedFromSession` logic. This means completed tasks should ALWAYS be visible in personal view, regardless of any filtering state.

The issue is likely in how the SSE subscription URL is constructed. In `SSEManager.swift:67`, the URL is built as:
```swift
let url = URL(string: "\(baseURL.absoluteString)/subscribe/%23\(currentProjectSlug)")!
```

For the personal view with `currentProjectSlug = "user"`, this creates `/subscribe/%23user` (URL-encoded: `/subscribe/#user`).

However, when the user toggles to another project and back to personal, the `switchToProject("user")` method is called, which triggers `sse.switchProject("user")`. This disconnect-and-reconnect may be subscribing to a different URL or the reconnection may be using different parameters.

The most likely issue: The SSE URL construction for the "user" project may be incorrect. Other projects use slugs like "myproject", so the URL would be `/subscribe/#myproject`. But for the special "user" project (personal view), the backend might expect `/subscribe/#user` or possibly a different endpoint like `/subscribe/personal` or `/subscribe/` (no project).

Another possibility: The REST API fetch on cold start may be completing before the SSE connection establishes. When SSE connects, it delivers the initial state snapshot, which overwrites the REST fetch results (line 62 in ViewModel). If the SSE initial state doesn't include completed items for some reason, they would disappear. When toggling projects, the REST fetch happens AFTER the SSE reconnection completes, preserving the data.

## Approach
Investigate the SSE subscription URL for the personal/"user" project. Check if it should use a different URL pattern than project views. Compare the SSE event stream data on cold start vs. after toggle to see if completed items are missing from the initial SSE payload.

If the SSE URL is correct, the issue is likely a race condition between REST fetch and SSE connection on cold start. The fix would be to ensure the initial REST fetch results aren't overwritten by SSE until after the first SSE event delivers the full state.

## Tasks
1. [Punchlist/Services/SSEManager.swift:67] — Add debug logging to verify the exact URL being used for SSE subscription on cold start vs after toggle. Log the URL and the count of items received in the first SSE event.
   Verify: Build and run the app, check Xcode console logs for SSE URLs and item counts.

2. [Punchlist/ViewModels/PunchlistViewModel.swift:60-66] — Add debug logging in the SSE callback to log item counts and whether completed items are present. Log `items.count`, `items.filter { $0.done }.count` to see if completed tasks are in the SSE payload.
   Verify: Build and run, check logs for completed item counts on cold start vs toggle.

3. [Testing] — Test the app on cold start to see if completed tasks appear. Toggle to a project view and back to personal to see if they appear then. Compare the logs from both scenarios.
   Verify: Completed items visible in both scenarios, logs show consistent data from SSE.

4. [Fix] — Based on the logs, either:
   - Fix the SSE URL construction if it's wrong for "user" project
   - Fix the race condition by not allowing SSE to overwrite items on first connect if REST fetch has already populated data
   - Fix the backend SSE endpoint if it's not returning completed items for "user" project
   Verify: Completed items appear immediately on cold start.

## Open Questions
- Does the backend SSE endpoint `/subscribe/#user` return completed items in the initial state snapshot? Or does it filter them out?
- Is there a special URL pattern for the personal view SSE subscription, different from project views?
- If this is a backend issue (SSE not returning completed items for "user" project), should we fix it in the backend or work around it in the client by relying solely on REST fetch for initial load?

