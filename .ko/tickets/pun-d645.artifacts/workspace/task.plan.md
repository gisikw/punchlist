Perfect! I've updated the plan based on the confirmed information that the backend returns completed items correctly. 

## Summary

The open questions have been answered - this is **not a backend issue**. The backend SSE correctly returns completed items.

**Root cause identified**: A race condition on cold start where:
1. REST API fetches items (with completed tasks) 
2. SSE callback fires shortly after and **overwrites** the items with its initial state
3. When toggling projects, the timing is different (SSE reconnects slowly) so the REST data is preserved

**Fix**: Add a `hasInitialLoad` flag to prevent the SSE callback from overwriting items if the REST fetch has already loaded data on cold start. This preserves the correct data while still allowing real-time SSE updates to flow through.

The updated plan is ready for implementation.
