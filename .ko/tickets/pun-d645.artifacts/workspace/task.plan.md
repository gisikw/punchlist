The plan has been written to `/home/dev/Projects/punchlist/.ko/tickets/pun-d645.artifacts/plan.md`.

## Summary

I've investigated the codebase and created a plan for this bug. The issue is that completed tasks are hidden on cold start but appear after toggling projects.

**Key finding**: The `filtered()` method explicitly returns ALL items for personal view (`if isPersonal { return items }`), so completed tasks should always be visible. This means the problem is likely with the data source, not the filtering logic.

**Most likely cause**: A race condition between the SSE (real-time) connection and the initial REST API fetch. On cold start, the SSE connection may deliver an initial state snapshot that doesn't include completed items, overwriting the REST fetch results. When toggling, the REST fetch happens after SSE reconnection, preserving the data.

**Alternative cause**: The SSE subscription URL for the "user" project (`/subscribe/#user`) might be constructed incorrectly, causing the backend to return incomplete data.

The plan outlines a debugging-first approach: add logging to verify what data is being received from SSE on cold start vs. after toggle, then fix the root cause once identified.
