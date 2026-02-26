The plan is complete. I've identified 5 open questions that need human input before implementation can proceed. These are genuine product and UX decisions that can't be inferred from the codebase:

1. **Long-press target scope** — whether to allow long-press on expanded cards (conflicts with text selection)
2. **Block reason input** — whether to collect a reason string from the user
3. **Personal vs project scope** — whether personal items should be blockable
4. **Visual feedback design** — what the progress indicator should look like
5. **Unblock button styling** — placement and visual treatment

These questions address the core interaction design that will shape the implementation. The codebase shows the technical patterns (hold gestures, API calls, state management), but the product decisions about when/how/why a user would manually block need clarification.
