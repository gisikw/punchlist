## Summary

I've completed the diagnosis of the bug. Here's what I found:

**The Issue:** The agent toggle remains visible in the header when the project drawer (project picker) is open, creating visual clutter.

**Root Cause:** In `ContentView.swift` (lines 115-120), the agent toggle's conditional rendering checks for agent state and whether it's a personal project, but it doesn't check whether the project picker is currently displayed (`showProjectPicker`).

**The Fix:** Add `!showProjectPicker` to the conditional that determines whether to show the agent toggle. This is a one-line change that will hide the toggle when the drawer is open.

**Risk:** Very low - this is a simple visual change with no impact on functionality or state management.

The full diagnosis has been written to `/home/dev/Projects/punchlist/.ko/tickets/pun-a647.artifacts/diagnosis.md` with detailed analysis, code references, and testing recommendations.
