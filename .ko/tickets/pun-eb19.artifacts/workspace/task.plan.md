The plan is written! Let me summarize the diagnosis:

## Summary

I've investigated the ticket disappearance issue and written a plan to fix it.

**The Problem:**
When creating a ticket in a project view, it appears immediately but then vanishes after a few seconds, only to reappear when switching projects or restarting the app.

**Root Cause:**
There's a race condition between the REST API mutation and the SSE broadcast:
1. `addItem()` succeeds via REST API
2. Server sends SSE update with the full project state
3. The ViewModel receives SSE items and calls `filtered()`, which hides items with `status == "closed"` in project views
4. If the SSE update arrives with stale state (before the mutation is fully committed) or if the new ticket is initially created with closed status, it gets filtered out
5. A subsequent SSE update arrives with the correct state, making the ticket reappear

**The Solution:**
Implement optimistic UI handling similar to the existing offline queue pattern:
- Track newly created ticket IDs in a `pendingAdditions` set
- Exempt items in this set from the `done` filter in project views
- Clear IDs from the set once they appear in an SSE update
- This ensures newly created tickets remain visible until confirmed by the server

The plan is at `.ko/tickets/pun-eb19.artifacts/plan.md` and includes 6 implementation tasks with verification steps.
