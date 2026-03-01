Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Looking at this ticket:

**Title:** "Let the in-progress indicator supersede the triage indicator"

This is clearly describing **what should be built** - a specific visual/behavioral change where the in-progress indicator takes priority over the triage indicator. The ticket includes a design suggestion (grey circle outline with blue fill/glow).

The expected output is committed code changes, not investigation or diagnosis.

```json
{"disposition": "route", "workflow": "task"}
```
