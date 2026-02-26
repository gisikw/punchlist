---
id: pun-d645
status: open
deps: []
created: 2026-02-26T13:00:55Z
type: task
priority: 2
---
# Personal view hides completed tasks on cold start, shows them if I toggle away and back. Completed should always show in personal view

## Notes

**2026-02-26 13:48:13 UTC:** Question: Should we prioritize a backend fix or implement a client-side workaround if SSE isn't returning completed items?
Answer: This shouldn't be a server side issue

**2026-02-26 13:48:13 UTC:** Question: Does the backend SSE endpoint return completed items in the initial state snapshot for the personal view?
Answer: Yes, completed items are included
The backend SSE returns completed items, so the issue is likely a client-side race condition
