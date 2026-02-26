## Goal
Make the `filtered()` method in PunchlistViewModel internal to allow test access via `@testable import`, completing the test implementation.

## Context
The test infrastructure has been successfully implemented:
- XCTest target "PunchlistTests" has been added to the Xcode project
- Comprehensive decoding tests exist in `PunchlistTests/PunchlistTests.swift` covering Item, PlanQuestion, and Project models with their custom CodingKeys mappings
- Filtering logic tests exist in `PunchlistTests/FilteringTests.swift` covering all scenarios (personal project, project views, session-based completed items)
- The `just test` command exists in the justfile and executes tests on the remote build host

However, the tests currently fail to compile because the `filtered()` method in `PunchlistViewModel` (line 398) is implicitly private, and the test file uses `@testable import Punchlist` expecting to access internal members.

The ticket author chose the "Use @testable import" approach, which requires making `filtered()` internal.

## Approach
Change the access level of the `filtered()` method from its current implicit private to explicit internal, allowing the existing test suite to access it via `@testable import`. This is the simplest solution and follows standard Swift testing conventions.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift:398] — Change `func filtered(_ items: [Item]) -> [Item]` to `internal func filtered(_ items: [Item]) -> [Item]` to allow test access.
   Verify: `just test` passes all tests without compilation errors.

## Open Questions
None. The user has answered both previous questions:
- Remote test execution is implemented via `just test`
- The `@testable import` approach was chosen, requiring internal access level
