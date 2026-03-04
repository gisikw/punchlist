Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "route", "workflow": "bug"}
```

This ticket reports unexpected behavior (long-press gesture intercepting scroll) and proposes a conditional fix path that requires diagnosis. The ticket needs investigation to determine:
1. Whether the scroll interception can be solved without moving the gesture
2. If not solvable, whether moving to the circles is the right alternative

Once diagnosed, the appropriate code changes will become clear.
