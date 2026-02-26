## Goal
Add unit tests verifying that items with `status == "resolved"` display with the correct green circle appearance.

## Context
The resolved status visual treatment was implemented in commit 9eb8069 (ticket pun-d071). When an item has `status == "resolved"`:
- ItemRow.swift:234 — `circleColor` returns `.punchGreen`
- ItemRow.swift:255 — The circle renders as a filled green circle with a white checkmark (same as done items)

The project has an XCTest suite in PunchlistTests/ with two test files:
- PunchlistTests.swift — tests for model decoding (Item, PlanQuestion, Project)
- FilteringTests.swift — tests for ViewModel filtering logic

Testing approach: Since ItemRow is a SwiftUI View and there's no UI testing infrastructure (no ViewInspector or XCUIApplication), the best approach is to test the **computed properties** that drive the visual appearance. These are internal computed properties that determine circle color and content.

The test file already uses `@testable import Punchlist` to access internal methods (see FilteringTests.swift:2), so we can test ItemRow's internal computed properties that determine appearance.

## Approach
Add a new test class `ItemRowAppearanceTests` to PunchlistTests.swift. Test the computed properties that control resolved appearance: `isResolved`, `circleColor`, and the conditional logic that shows the checkmark. Create test instances of ItemRow with different item statuses and verify the appearance properties return expected values.

## Tasks
1. [PunchlistTests/PunchlistTests.swift] — Add `ItemRowAppearanceTests` class with 4 tests:
   - `testIsResolvedTrueWhenStatusResolved` — verify `isResolved` computed property returns true for status "resolved"
   - `testIsResolvedFalseForOtherStatuses` — verify `isResolved` is false for nil, "open", "in_progress", "blocked", "closed"
   - `testCircleColorGreenForResolvedStatus` — verify `circleColor` returns `.punchGreen` for resolved items
   - `testCircleColorPrecedenceForResolvedVsOtherStatuses` — verify that if both `done` and `isResolved` are true, color is still green (precedence check)

   Verify: `just test` passes all new tests.

## Open Questions
None — the visual treatment is already implemented and the testing strategy is clear. We're testing the internal computed properties that determine appearance, which is the standard approach for SwiftUI views without ViewInspector.
