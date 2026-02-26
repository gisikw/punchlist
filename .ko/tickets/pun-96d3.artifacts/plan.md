## Goal
Add an XCTest target to the Xcode project and implement unit tests for model decoding (Item, PlanQuestion, Project) and the ViewModel filtering logic.

## Context
The project currently has no test target or test files. The codebase follows strict conventions from INVARIANTS.md:
- No third-party dependencies, including test frameworks
- SwiftUI-based iOS 17+ app using @Observable
- Three model types with custom Codable implementations:
  - `Item`: Maps `title` to `text`, `plan-questions` to `planQuestions`, derives `done` from `status == "closed"`
  - `PlanQuestion` and `PlanOption`: Nested structures for agent planning UI
  - `Project`: Maps `tag` to `slug`, `is_default` to `isDefault`
- Filtering logic in `PunchlistViewModel.filtered()`: personal project shows all items, project views hide closed items unless they were modified during an active agent session

The Xcode project uses a custom ID scheme (A10001-style references) and has a clear structure: Models/, Services/, ViewModels/, Views/.

## Approach
Add a unit test target to `Punchlist.xcodeproj` that links against the main app target to access model types. Write pure decoding tests using hand-crafted JSON samples that match the server's format (see `example.json` for reference). Test the filtering logic by creating Item instances with the manual init and verifying filter behavior across different scenarios.

## Tasks
1. [Punchlist.xcodeproj/project.pbxproj] — Add a new XCTest bundle target named "PunchlistTests" that depends on the main Punchlist app target. Include XCTest framework reference, configure for iOS 17+ deployment, set up build phases (Sources, Frameworks, Resources). Create new PBX identifiers following the existing A/B/C/D/E/F/G/H pattern.
   Verify: Project opens in Xcode without errors, new test target appears in scheme selector.

2. [PunchlistTests/PunchlistTests.swift] — Create test file with `ItemDecodingTests` class. Test Item decoding with JSON samples covering: minimal required fields (id, title, created), optional fields (priority, status, description, modified, hasUnresolvedDep), plan-questions array, and the `done` derivation from `status == "closed"`. Test edge cases: status "in_progress" (done=false), missing status (done=false), status "closed" (done=true).
   Verify: `xcodebuild test -scheme PunchlistTests -destination 'platform=iOS Simulator,name=iPhone 15'` passes all Item tests.

3. [PunchlistTests/PunchlistTests.swift] — Add `PlanQuestionDecodingTests` class. Test PlanQuestion and PlanOption decoding with nested JSON structures. Verify required fields (id, question, options array with label/value/description), optional context field, and that PlanOption.id returns value.
   Verify: All PlanQuestion tests pass.

4. [PunchlistTests/PunchlistTests.swift] — Add `ProjectDecodingTests` class. Test Project decoding with JSON samples covering: tag→slug mapping, optional name derivation (name defaults to slug in init), is_default→isDefault mapping with default false, and that id returns slug.
   Verify: All Project tests pass.

5. [PunchlistTests/FilteringTests.swift] — Create new test file with `FilteringTests` class. Test the filtering logic by extracting it to a testable form or testing through ViewModel. Cover scenarios: personal project (isPersonal=true) returns all items, project view filters out done items, project view includes done items modified after session start when showCompletedFromSession=true, project view excludes done items with no modified timestamp, project view excludes done items modified before session start.
   Verify: All filtering tests pass, test suite runs successfully via `just test` (if justfile supports it) or xcodebuild.

## Open Questions
**Test execution in CI**: The project uses remote macOS builds via SSH (per INVARIANTS.md and justfile). Should the plan include adding a `just test` command that executes tests on the remote build host, or is local test execution sufficient? The justfile has `build`, `build-device`, and `distribute` commands but no test command yet.

**Filtering test approach**: The `filtered()` method is private in PunchlistViewModel. Should we:
- Make it internal with `@testable import Punchlist` to test directly, OR
- Test filtering indirectly by setting up ViewModel state and verifying items array, OR
- Extract filtering to a separate pure function that's testable?

The first approach (internal + @testable) is simplest and matches typical Swift testing patterns, but conflicts with keeping implementation details private.
