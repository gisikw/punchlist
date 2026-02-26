## Review Complete

I've thoroughly reviewed the implementation against the plan and all specified criteria. Here's my assessment:

### ✅ Plan Compliance
All three planned tasks were completed:
1. ✅ Modified `onCollapse` callback to call `scrollTo(item.id, anchor: .bottom)` after animation
2. ✅ Added delay matching animation duration (350ms) before calling scrollTo
3. ✅ Verified ItemRow's `onCollapse` signature (already `() -> Void`, no changes needed)

### ✅ No Unexplained Deviations
The implementation follows the plan exactly as written. No deviations detected.

### ✅ Risk Resolution
The single open question (scroll to collapsed item vs. bottom of list) was answered by the user, choosing "Scroll to collapsed item (Recommended)" — this is what was implemented.

### ✅ Correctness
The implementation directly addresses the ticket's complaint: "on collapse the tickets can seemingly disappear because the container doesn't shrink." The fix forces the ScrollView to recalculate by explicitly scrolling to the collapsed item.

### ✅ Completeness
The implementation is minimal and complete:
- Uses existing `ScrollViewReader` proxy (no new infrastructure needed)
- Properly timed to animation duration
- Appropriate use of Swift concurrency patterns

### ✅ Safety
No security concerns:
- No user input processing
- No network calls
- No data mutations
- Standard SwiftUI animation and scrolling APIs

### ✅ Scope
Changes are strictly scoped to the ticket — only added 6 lines to implement the scroll adjustment after collapse.

### ✅ Tests
All 26 existing tests passed on the macOS build host. No new tests were required (this is a UI animation fix, not business logic).

### ✅ Invariants Compliance
Checked against `INVARIANTS.md`:
- ✅ SwiftUI-only (no UIKit wrappers)
- ✅ iOS 17+ patterns (`Task`, `@MainActor`, async/await)
- ✅ Maintains bottom-anchored scroll behavior
- ✅ No third-party dependencies
- ✅ Follows existing animation patterns (spring animation with 0.35s duration)

The implementation is clean, correct, and ready to ship.

```json
{"disposition": "continue"}
```
