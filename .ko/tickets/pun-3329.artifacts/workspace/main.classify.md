Looking at this ticket, I need to classify the type of work it describes.

The ticket states:
- "Pulse animation should apply to in_progress tickets AND tickets with open plan questions"
- "Fix transient pulsing on tickets that appear in_progress briefly but shouldn't be"
- "Followup to pun-3ea3"

This ticket describes:
1. **What should happen**: Pulse animation should apply to two conditions (in_progress tickets and tickets with open plan questions)
2. **What's broken**: Transient pulsing is occurring on tickets that shouldn't be pulsing
3. **Clear intent**: Fix the animation logic to match the intended behavior

This is asserting that there's a problem with the animation behavior (it's pulsing when it shouldn't) and specifying what the correct behavior should be. The fix is clear: adjust the pulsing logic to apply to the correct ticket states.

This is a **task** - it's requesting a specific code change to fix animation behavior, with a clear definition of what should be built/fixed.

```json
{"disposition": "route", "workflow": "task"}
```
