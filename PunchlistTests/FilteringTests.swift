import XCTest
@testable import Punchlist

final class FilteringTests: XCTestCase {
    private func makeViewModel() -> PunchlistViewModel {
        PunchlistViewModel()
    }

    func testPersonalProjectShowsAllItems() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "user"

        let items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z"),
            Item(id: "2", text: "Closed", done: true, created: "2025-01-01T10:00:00Z"),
            Item(id: "3", text: "Another open", done: false, created: "2025-01-01T10:00:00Z"),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 3)
        XCTAssertTrue(vm.isPersonal)
    }

    func testProjectViewHidesClosedItems() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "work"

        let items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z"),
            Item(id: "2", text: "Closed", done: true, created: "2025-01-01T10:00:00Z", status: "closed"),
            Item(id: "3", text: "Another open", done: false, created: "2025-01-01T10:00:00Z"),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { !$0.done })
    }

    func testProjectViewIncludesClosedFromSessionWhenEnabled() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "work"
        vm.showCompletedFromSession = true

        let now = Date()
        let sessionStart = now.addingTimeInterval(-3600) // 1 hour ago
        vm.agentSessionStartTime = sessionStart

        let formatter = ISO8601DateFormatter()

        let items = [
            Item(
                id: "1",
                text: "Open",
                done: false,
                created: "2025-01-01T10:00:00Z"
            ),
            // Closed during session
            Item(
                id: "2",
                text: "Closed during session",
                done: true,
                created: "2025-01-01T10:00:00Z",
                status: "closed"
            ),
            // Set modified time to after session start
            {
                var item = Item(
                    id: "3",
                    text: "Closed during session (modified)",
                    done: true,
                    created: "2025-01-01T10:00:00Z",
                    status: "closed"
                )
                item.modified = formatter.string(from: now.addingTimeInterval(-1800)) // 30 min ago, after session start
                return item
            }(),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 2, "Should include open item and closed item from session")
        XCTAssertTrue(filtered.contains { $0.id == "1" })
        XCTAssertTrue(filtered.contains { $0.id == "3" })
    }

    func testProjectViewExcludesClosedWithoutModifiedTimestamp() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "work"
        vm.showCompletedFromSession = true
        vm.agentSessionStartTime = Date().addingTimeInterval(-3600)

        let items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z"),
            // Closed but no modified timestamp
            Item(
                id: "2",
                text: "Closed no timestamp",
                done: true,
                created: "2025-01-01T10:00:00Z",
                status: "closed"
            ),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].id, "1")
    }

    func testProjectViewExcludesClosedModifiedBeforeSession() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "work"
        vm.showCompletedFromSession = true

        let sessionStart = Date().addingTimeInterval(-3600) // 1 hour ago
        vm.agentSessionStartTime = sessionStart

        let formatter = ISO8601DateFormatter()

        let items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z"),
            // Closed before session started
            {
                var item = Item(
                    id: "2",
                    text: "Closed before session",
                    done: true,
                    created: "2025-01-01T10:00:00Z",
                    status: "closed"
                )
                item.modified = formatter.string(from: sessionStart.addingTimeInterval(-1800)) // 30 min before session
                return item
            }(),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].id, "1")
    }

    func testProjectViewDisabledShowCompletedFromSession() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "work"
        vm.showCompletedFromSession = false

        let sessionStart = Date().addingTimeInterval(-3600)
        vm.agentSessionStartTime = sessionStart

        let formatter = ISO8601DateFormatter()

        let items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z"),
            {
                var item = Item(
                    id: "2",
                    text: "Closed during session",
                    done: true,
                    created: "2025-01-01T10:00:00Z",
                    status: "closed"
                )
                item.modified = formatter.string(from: Date())
                return item
            }(),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].id, "1")
    }

    func testProjectViewNilSessionStart() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "work"
        vm.showCompletedFromSession = true
        vm.agentSessionStartTime = nil

        let items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z"),
            Item(
                id: "2",
                text: "Closed",
                done: true,
                created: "2025-01-01T10:00:00Z",
                status: "closed"
            ),
        ]

        let filtered = vm.filtered(items)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].id, "1")
    }

    func testFilteringLogicEdgeCase() {
        let vm = makeViewModel()
        vm.currentProjectSlug = "project"
        vm.showCompletedFromSession = false

        // All closed items should be filtered out when showCompletedFromSession is false
        let items = [
            Item(id: "1", text: "Item 1", done: true, created: "2025-01-01T10:00:00Z", status: "closed"),
            Item(id: "2", text: "Item 2", done: true, created: "2025-01-01T10:00:00Z", status: "closed"),
            Item(id: "3", text: "Item 3", done: true, created: "2025-01-01T10:00:00Z", status: "closed"),
        ]

        let filtered = vm.filtered(items)

        XCTAssertTrue(filtered.isEmpty)
    }
}
