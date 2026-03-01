Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
## Assessment

The diagnosis is **clear, conclusive, and ready for implementation**.

**Root Cause Identified:** ✓
- The issue is precisely located in `ItemRow.swift` within the `circle` and `circleColor` computed properties
- The problem is a simple ordering issue: `item.done || isResolved` is checked before `hasTriage`, causing the "done" indicator to take precedence over the triage indicator
- Specific line numbers provided (313–320, 332–344)

**Fix is Straightforward:** ✓
- Both required changes are simple: reorder the `if/else if` conditions to check `hasTriage` first
- No data model or API changes
- Localised to a single view file
- Low risk with clear impact boundary

**No Human Input Needed:** ✓
- The recommended approach is unambiguous
- The fix aligns with existing product intent (triage already prevents retriage interactions)
- Edge cases (blue glow on in-progress triage items, tap behavior) are documented and scoped for separate follow-up if needed

This is a well-diagnosed, scoped bug fix ready for implementation.

```json
{"disposition": "route", "workflow": "task"}
```
