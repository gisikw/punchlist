The plan has been written to `/home/dev/Projects/punchlist/.ko/tickets/pun-df80.artifacts/plan.md`.

## Summary

I've investigated the codebase and written a plan for persisting the "agent is done" checkbox state. Here's what I found:

**The Problem**: The `showCompletedFromSession` Bool (which controls the checkbox) is transient and gets reset to `false` when switching projects or restarting the app, even though the underlying agent session timestamp persists.

**The Solution**: Follow the existing pattern used for `agentSessionStartTime` — use UserDefaults with a per-project key to save and restore the checkbox state. The implementation is straightforward since the persistence pattern is already established in the codebase.

The plan includes:
1. Adding per-project UserDefaults persistence for `showCompletedFromSession`
2. Loading/saving the state in `switchToProject` and when toggling
3. Clearing it in `clearAgentSession` alongside the session timestamp
