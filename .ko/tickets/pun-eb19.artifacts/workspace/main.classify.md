Looking at this ticket, the user is reporting unexpected behavior: a ticket appears immediately after creation, then disappears a few seconds later, but reappears when the app is closed/reopened or projects are switched.

This is clearly describing **what's broken** rather than what to build or asking if something is possible. The behavior is:
1. Unexpected (tickets shouldn't disappear)
2. Reproducible (happens consistently after ticket create)
3. Has a specific trigger (ticket creation)
4. Suggests a data sync or state management issue

This needs diagnosis to determine the root cause before deciding on a fix.

```json
{"disposition": "route", "workflow": "bug"}
```
