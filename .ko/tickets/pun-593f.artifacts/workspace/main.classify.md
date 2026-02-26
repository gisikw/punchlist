Looking at this ticket, I need to classify it based on what type of work it requires.

**Ticket Analysis:**

The ticket states: "Right now we're hiding the agent if there are no tickets that aren't blocked or done. We should also hide if the only ones left are resolved - those are not agent-actionable"

This is clearly **describing what to build** (a feature/logic change):
- It identifies a current behavior (hiding agent under certain conditions)
- It specifies what additional condition should trigger that behavior (when only resolved tickets remain)
- The fix is straightforward: extend the agent visibility logic to also check for resolved tickets
- The expected output is code changes

This is not asking for investigation ("Can we?", "Why?", "What would it take?") and it's not reporting unexpected behavior that needs diagnosis. It's a clear directive for a code modification.

```json
{"disposition": "route", "workflow": "task"}
```
