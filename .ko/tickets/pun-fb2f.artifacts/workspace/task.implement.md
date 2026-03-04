Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Build succeeded. 

**Summary**: One change in `ItemRow.swift:collapsedProjectHoldOverlay`:

1. Changed `.gesture(DragGesture(minimumDistance: 0)` → `.simultaneousGesture(DragGesture(minimumDistance: 0)` so the ScrollView can run its gesture recognizer in parallel.
2. Updated `onChanged { _ in` → `onChanged { value in` and added a translation threshold check at the top — if either axis exceeds 8pt, the hold task is cancelled, `isHolding` and `holdProgress` are reset, and we return early. This lets scroll win naturally when the user is clearly scrolling, while still-touch holds continue to work.
