I'll analyze this ticket to determine the appropriate workflow classification.

## Analysis

**Ticket Summary:**
- "Personal view hides completed tasks on cold start, shows them if I toggle away and back"
- "Completed should always show in personal view"

**Nature of the Problem:**
This is clearly reporting **unexpected behavior**:
- ✗ **Current behavior**: Completed tasks are hidden on cold start
- ✓ **Expected behavior**: Completed tasks should always show in personal view
- The issue is intermittent based on app state (cold start vs. after toggling)

**Key Indicators:**
1. **Not a feature request** - Not asking to add new functionality, but fix existing behavior
2. **Not a research question** - Not asking "can we do this?" or "why might this happen?"
3. **Asserting a problem** - Clearly states something is broken ("hides completed tasks")
4. **Has diagnosis context** - Previous notes indicate investigation has already identified:
   - SSE returns completed items (backend works)
   - The issue is client-side
   - Likely a race condition or data flow issue

**Conclusion:**
This is a **bug** - a state management/rendering issue where the UI doesn't correctly display data that should be visible. The ticket asserts the application has a problem that needs diagnosis and fixing, not that a feature should be added.

```json
{"disposition": "route", "workflow": "bug"}
```
