I've created the implementation plan at `/home/dev/Projects/punchlist/.ko/tickets/pun-43d8.artifacts/plan.md`.

The issue is straightforward: the completion circle (green checkmark) that appears when an agent finishes should clear the session when tapped, but currently it only toggles a visibility flag. The fix involves changing one button action to call the existing `clearAgentSession()` method instead of toggling `showCompletedFromSession`. This will make the indicator disappear entirely as expected.
