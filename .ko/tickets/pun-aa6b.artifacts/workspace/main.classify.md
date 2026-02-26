I'll classify this ticket by reading its content carefully.

The ticket states: **"Can we add a general 1.5s threshold on offline, not just in startup?"**

This is asking for a code change with clear direction:
- What needs to change: Add a 1.5-second threshold on offline indicator visibility
- Where it applies: Generally, not just during startup
- Why: To handle "minor network flakiness" where offline appears/disappears frequently

The ticket author has provided context about the problem (network flakiness causing flickering) and the desired solution (a general 1.5s debounce threshold). The prior context shows this has already been investigated and a plan exists—this is ready for implementation.

The expected output is code changes to apply the 1.5-second threshold across the offline detection logic.

```json
{"disposition": "route", "workflow": "task"}
```
