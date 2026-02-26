## Summary

I've identified the root cause of the ticket disappearing bug:

**The Issue**: When creating a ticket in a project view (not personal), the app relies entirely on SSE updates since it doesn't do optimistic UI updates when connected. The SSE stream sends the new ticket initially (it appears), but then sends a subsequent update that gets filtered out by the `filtered()` function. This function hides closed items in project views unless they're from the current agent session, and the newly created ticket is being caught by this filter.

**Root Cause**: A race condition between:
1. SSE broadcasting the new ticket
2. A subsequent SSE update (possibly a status change or full refresh)
3. The filtering logic that hides closed items in project views

**The Fix**: Add optimistic UI updates even when connected (currently only done when offline), so tickets appear immediately and consistently. The SSE update will then replace the temporary item with the authoritative version.

The diagnosis document has been written to `.ko/tickets/pun-eb19.artifacts/diagnosis.md` with full details including symptoms, root cause analysis, affected code paths, three potential fix options with risk assessments, and recommendations.
