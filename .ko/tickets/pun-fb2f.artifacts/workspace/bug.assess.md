Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Reading the diagnosis for ticket pun-fb2f...

## Assessment

**Root Cause:** ✓ Clearly identified. The diagnosis precisely explains how `DragGesture(minimumDistance: 0)` with exclusive gesture ownership (`.gesture(...)`) on the full card surface defeats the ScrollView's gesture recognizer.

**Fix Straightforward:** ✓ Yes. The diagnosis recommends Option A as the primary path: switch to `.simultaneousGesture(...)` and check the translation threshold to cancel the hold if the user is scrolling. This is a localized, 2-line change.

**Human Input:** The ticket itself anticipated this decision ("If not solveable, move the long press trigger to apply to the circles"), and the diagnosis recommends Option A first—which aligns with the ticket's stated preference. The suggested threshold (8–10pt) is a starting point for implementation; threshold tuning is not a product decision but a runtime refinement that can be tested during task execution.

The diagnosis is conclusive, the recommended fix is scoped and clear, and the fallback strategy (Option B) is documented. This is ready for implementation.

```json
{"disposition": "route", "workflow": "task"}
```
