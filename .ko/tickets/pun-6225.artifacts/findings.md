# Testing Story Investigation

## Summary

**Punchlist has no automated testing infrastructure.** There are zero test files, no test targets in the Xcode project, and the `just test` command explicitly states "no tests configured — builds are validated via xcodebuild on the build host."

## Current State

### Test Infrastructure: **None**

- **No test files**: No Swift test files exist (no `*Test*.swift` or `*Tests*.swift` files)
- **No test target**: The Xcode project (`Punchlist.xcodeproj/project.pbxproj`) contains only one target: the main app target `Punchlist`
  - Location: Lines 121-137 of project.pbxproj
  - No XCTest framework references
  - No `@testable import` statements anywhere in codebase
- **No test runner**: The justfile explicitly documents this at line 16-17:
  ```just
  test:
      echo "no tests configured — builds are validated via xcodebuild on the build host"
  ```
- **No CI/CD**: No GitHub Actions, GitLab CI, or other CI configuration files exist
- **`ENABLE_TESTABILITY = YES`**: This build setting is enabled in Debug configuration (line 216 of project.pbxproj), but no tests exist to leverage it

### Quality Assurance Approach

The project currently relies on:

1. **Manual testing** during development
2. **Build validation** via remote xcodebuild on macOS host
3. **Type checking** via `just check` command (line 164-167 of justfile):
   ```bash
   swiftc -typecheck -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
     -target arm64-apple-ios17.0-simulator Punchlist/**/*.swift
   ```

### Codebase Characteristics

The codebase is **small and focused** (1,535 lines of Swift across 11 files):

- **Models** (90 lines):
  - `Item.swift` (47 lines): Core data model with Codable conformance
  - `Project.swift` (27 lines): Project model
  - `PlanQuestion.swift` (16 lines): Question model for agent interaction

- **Services** (327 lines):
  - `SSEManager.swift` (189 lines): Server-Sent Events connection handling
  - `KoAPI.swift` (138 lines): HTTP API client for Ko backend

- **ViewModels** (330 lines):
  - `PunchlistViewModel.swift` (330 lines): Main state management

- **Views** (778 lines):
  - `ContentView.swift` (281 lines): Main UI
  - `ItemRow.swift` (280 lines): List item rendering
  - `PlanQuestionsView.swift` (194 lines): Agent questions UI
  - `InputBar.swift` (23 lines): Bottom input bar

- **App Entry** (10 lines):
  - `PunchlistApp.swift` (10 lines): SwiftUI app definition

### Architectural Constraints

From `INVARIANTS.md`:

- **No local persistence**: "API client only — no local data persistence"
- **No third-party dependencies**: "No Alamofire, no Starscream, no SwiftPM packages"
- **Zero dependencies**: Uses only URLSession and URLSessionWebSocketTask
- **No CI/CD yet**: "manual builds. If this changes, document it here."

### Testability Characteristics

**Positive factors for testing:**

1. **Clear separation of concerns**: Models, Services, ViewModels, Views are distinct
2. **Protocol-ready services**: `KoAPI` and `SSEManager` could easily be protocol-ized for mocking
3. **Dependency injection ready**: `KoAPI` and `SSEManager` both accept `baseURL` in their initializers
4. **Pure models**: `Item`, `Project`, and `PlanQuestion` are simple `Codable` structs
5. **Observable pattern**: Uses Swift's modern `@Observable` macro (iOS 17+)
6. **Small surface area**: Only 1,535 lines means comprehensive test coverage is achievable

**Challenges for testing:**

1. **Tight coupling**: `PunchlistViewModel` creates its own `KoAPI()` and `SSEManager()` instances (line 27-28 of PunchlistViewModel.swift)
2. **URLSession usage**: Direct use of `URLSession.shared` makes network testing harder (line 96 of KoAPI.swift)
3. **Complex async logic**: SSEManager has intricate reconnection, buffering, and timing logic (lines 61-141)
4. **Main actor dependencies**: UI state updates scattered throughout
5. **No existing test infrastructure**: Starting from zero requires setup work

## Test Coverage Opportunities

### High-Value Test Candidates

1. **`KoAPI` (138 lines)**
   - All endpoints are straightforward async functions
   - JSON encoding/decoding logic in `ShowResponse` and `AgentStatusResponse`
   - Error handling in `run()` method
   - **Testability**: High (needs URLSession mocking)

2. **`PunchlistViewModel` offline queue (lines 30, 112-133, 136-158, 162-176, 320-329)**
   - Critical user-facing feature: "mutations buffer locally and replay on reconnect"
   - Complex state machine with optimistic updates
   - Edge cases: queue ordering, duplicate operations, queue draining
   - **Testability**: Medium (needs dependency injection)

3. **`SSEManager` connection logic (189 lines)**
   - Exponential backoff (lines 123-124)
   - 3-second offline grace period (line 116)
   - Multi-line SSE parsing (lines 166-183)
   - Project switching (lines 51-57)
   - **Testability**: Low (needs significant URLSession mocking)

4. **`Item` model decoding**
   - Custom `CodingKeys` mapping (line 16: `title` → `text`)
   - Derived `done` property from `status == "closed"` (line 30)
   - Optional fields handling
   - **Testability**: High (pure function)

5. **Filtering logic** (`PunchlistViewModel.filtered`, lines 313-316)
   - Personal view shows all items
   - Project view hides closed items
   - **Testability**: High (pure function)

### Lower Priority

- **Views**: SwiftUI views are harder to unit test; UI testing or manual QA is often more effective
- **`PlanQuestionsView`**: Complex UI (194 lines) but likely tested better via UI tests
- **App lifecycle**: `PunchlistApp.swift` is minimal (10 lines)

## Recommended Actions

### Phase 1: Foundation (Low Effort, High Value)

1. **Add XCTest target to Xcode project**
   - Create `PunchlistTests` target
   - Link to main app target with `@testable import Punchlist`
   - Update justfile `test` command to run `xcodebuild test` on remote host

2. **Test pure models and utilities**
   - `Item` decoding (especially `status` → `done` mapping)
   - `PlanQuestion` decoding
   - `Project` decoding
   - `PunchlistViewModel.filtered()` logic
   - JSON fixtures for Ko API responses

3. **Add protocol abstraction for KoAPI**
   - Create `protocol KoAPIProtocol` with all methods
   - Inject into `PunchlistViewModel` instead of creating internally
   - Create `MockKoAPI` for testing

### Phase 2: Integration Testing (Medium Effort, High Value)

4. **Test offline queue behavior**
   - Create `PunchlistViewModel` tests with `MockKoAPI`
   - Verify queue accumulation when offline
   - Verify queue draining on reconnect
   - Test optimistic UI updates
   - Test queue persistence (in-memory) during app lifecycle

5. **Test agent state machine**
   - Agent start/stop transitions
   - Polling behavior (30s interval, lines 234-241)
   - Project-specific agent state

### Phase 3: Complex Integration (High Effort, Medium Value)

6. **Mock URLSession for KoAPI tests**
   - Use `URLProtocol` subclass for request interception
   - Test error handling (400/500 responses)
   - Test JSON decoding errors
   - Test network timeouts

7. **SSEManager testing**
   - Most complex component to test
   - Consider: Is the complexity justified, or should this be tested via integration/E2E?
   - Alternatives: Mock at higher level (inject into ViewModel)

### Phase 4: UI Testing (High Effort, Medium Value)

8. **XCUITest for critical flows**
   - Add item → verify appears in list
   - Toggle item → verify checkmark
   - Bump item → verify reorder
   - Offline indicator appears after 3s

### Infrastructure Improvements

9. **CI/CD setup**
   - GitHub Actions or similar
   - Run tests on every push
   - Could leverage existing remote macOS build host
   - Block merges on test failures

10. **Test data fixtures**
    - Create JSON files matching Ko API responses
    - Shared between tests
    - Version controlled

11. **Update INVARIANTS.md**
    - Document testing philosophy
    - Document test coverage expectations
    - Update "No CI/CD yet" if implemented

## Testing Philosophy Considerations

Given the project's stated values:

> "Punchlist doesn't want to be project management software when they grow up... intentionally small."

> "No third-party dependencies. URLSession for HTTP, URLSessionWebSocketTask for WebSocket."

A testing strategy should:

- **Stay lightweight**: Don't introduce heavy test frameworks (avoid Quick/Nimble, etc.)
- **Use XCTest only**: Native testing, matches "zero dependencies" philosophy
- **Focus on critical paths**: Offline queue, SSE reconnection, data sync
- **Avoid over-engineering**: Don't test every getter/setter
- **Manual QA is acceptable**: For a personal app, some manual testing is fine
- **Tests should run remotely**: Match the existing remote build workflow

## Gaps and Risks

### Current Risks Without Testing

1. **Offline queue corruption**: No automated verification that mutations replay correctly
2. **SSE parsing regressions**: Complex buffer management (lines 161-183) could break silently
3. **JSON decoding brittleness**: Backend changes could break parsing without notice
4. **Reconnection logic**: Exponential backoff and timing are hard to validate manually
5. **Project filtering**: Business logic (personal vs project) could regress

### Known Issues from Git History

Recent commits show testing could have caught:

- `61c9f41`: "Fix SSE connectivity, agent status, offline flash, and project filtering"
- `da22147`: "Fix PlanQuestion decoding: ko emits capitalized JSON field names"

These are exactly the kinds of issues unit tests would catch early.

## Conclusion

Punchlist has **zero automated testing** but is **highly testable**. The codebase is small (1,535 lines), well-structured, and uses modern Swift patterns. The main barriers are:

1. No test target exists (10-minute setup)
2. `PunchlistViewModel` creates dependencies directly (needs injection)
3. URLSession usage is not mockable (needs protocol abstraction)

**Recommended immediate action**: Add an XCTest target and test the pure functions (`Item` decoding, filtering logic) as a proof of concept. This is low-effort and validates the testing infrastructure before tackling harder integration tests.

**Biggest ROI**: Testing the offline queue behavior and SSE reconnection logic, as these are the most complex and error-prone parts of the system (evidenced by recent fixes in git history).
