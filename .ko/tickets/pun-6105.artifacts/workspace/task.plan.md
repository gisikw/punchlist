Perfect! I've written a plan for testing the resolved appearance. The plan:

**Goal**: Add unit tests to verify items with `status == "resolved"` display with the correct green circle appearance.

**Key findings from investigation**:
- The resolved visual treatment was implemented in commit 9eb8069 (ticket pun-d071)
- When `status == "resolved"`, ItemRow shows a green filled circle with checkmark (same as done items)
- The project has an XCTest suite but no UI testing framework
- Best approach: test the internal computed properties that drive appearance (`isResolved`, `circleColor`)

**Approach**: Add a new test class `ItemRowAppearanceTests` with 4 tests covering:
1. `isResolved` returns true for "resolved" status
2. `isResolved` returns false for other statuses
3. `circleColor` returns green for resolved items
4. Color precedence when multiple conditions are true

The plan is written to `/home/dev/Projects/punchlist/.ko/tickets/pun-6105.artifacts/plan.md` and ready for implementation.
