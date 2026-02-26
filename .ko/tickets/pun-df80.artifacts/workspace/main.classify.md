Looking at this ticket, I need to classify what kind of work it requires.

The ticket states:
- **What**: "The 'agent is done' checkbox that overlays the toggle should persist even if we switch away from the project and come back"
- **How**: "Can we store those settings per-project and make sure they survive project view switches?"

This is clearly describing **what to build** - a feature to persist per-project settings (specifically the "agent is done" checkbox state) across project view switches. The ticket is not reporting broken behavior or asking for investigation; it's specifying a concrete implementation goal.

This is a **task** - code changes are needed to implement per-project storage and retrieval of this UI state.

```json
{"disposition": "route", "workflow": "task"}
```
