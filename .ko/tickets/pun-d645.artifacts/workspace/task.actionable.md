The plan has **three open questions** that require human input before implementation can proceed:

1. **Backend SSE behavior for "user" project** - Does the backend return completed items in the initial state snapshot, or does it filter them out?
2. **Special URL pattern** - Is there a different SSE subscription URL pattern for personal view vs. project views?
3. **Backend vs. client fix** - If this is a backend issue, should we fix it on the backend or work around it in the client?

These questions directly affect task 4 (the fix itself), so the plan cannot proceed without clarification. Let me convert these into structured questions:

```json
{
  "disposition": "needs_input",
  "plan_questions": [
    {
      "id": "q1",
      "question": "Does the backend SSE endpoint return completed items in the initial state snapshot for the personal view?",
      "context": "The plan hypothesizes that SSE may be filtering out completed items on cold start. This affects whether the fix should address the client-side race condition or a backend data issue.",
      "options": [
        {
          "label": "Yes, completed items are included",
          "value": "included",
          "description": "The backend SSE returns completed items, so the issue is likely a client-side race condition"
        },
        {
          "label": "No, completed items are filtered out",
          "value": "filtered",
          "description": "The backend SSE filters completed items from the personal view, requiring a backend or client workaround"
        },
        {
          "label": "Unknown - need to investigate server logs",
          "value": "unknown",
          "description": "We should inspect actual SSE event payloads from the server to determine this"
        }
      ]
    },
    {
      "id": "q2",
      "question": "Should we prioritize a backend fix or implement a client-side workaround if SSE isn't returning completed items?",
      "context": "If the backend is filtering completed items from the SSE endpoint for the personal view, we need to decide: fix the backend API, or work around it in the iOS client by relying on REST fetch data.",
      "options": [
        {
          "label": "Fix the backend (Recommended)",
          "value": "backend_fix",
          "description": "Update the SSE endpoint to return completed items like it does when toggling projects"
        },
        {
          "label": "Client-side workaround",
          "value": "client_workaround",
          "description": "Have the iOS app prioritize REST fetch data and ignore incomplete SSE state on cold start"
        }
      ]
    }
  ]
}
```
