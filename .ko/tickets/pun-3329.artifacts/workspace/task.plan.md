Perfect! I've created the implementation plan at `/home/dev/Projects/punchlist/.ko/tickets/pun-3329.artifacts/plan.md`.

## Summary

The plan addresses both requirements from the ticket:

1. **Pulse on open plan questions**: Extend the `hasPulse` computed property to check for items with unanswered plan questions (detected by the presence of a non-empty `planQuestions` array)

2. **Fix transient pulsing**: Apply the fix identified in pun-3ea3 by explicitly checking `hasPulse && pulseActive` together in the opacity calculations, preventing old animation state from showing during status transitions

The implementation is straightforward - 3 targeted changes to `ItemRow.swift`:
- Update `hasPulse` logic to include items with plan questions
- Fix the border/shadow opacity checks to prevent transient animation
- Apply the same fix to the circle background for consistency
