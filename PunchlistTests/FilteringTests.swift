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

    func testHasUnblockedTicketsExcludesResolved() {
        let vm = makeViewModel()

        // Only resolved tickets — agent should hide
        vm.items = [
            Item(id: "1", text: "Resolved ticket", done: false, created: "2025-01-01T10:00:00Z", status: "resolved"),
            Item(id: "2", text: "Another resolved", done: false, created: "2025-01-01T10:00:00Z", status: "resolved"),
        ]

        XCTAssertFalse(vm.hasUnblockedTickets, "Resolved tickets should not count as unblocked")

        // Mix of resolved and blocked — agent should still hide
        vm.items = [
            Item(id: "1", text: "Resolved", done: false, created: "2025-01-01T10:00:00Z", status: "resolved"),
            Item(id: "2", text: "Blocked", done: false, created: "2025-01-01T10:00:00Z", status: "blocked"),
        ]

        XCTAssertFalse(vm.hasUnblockedTickets, "Mix of resolved and blocked should not count as having unblocked tickets")

        // Mix of resolved, blocked, and done — agent should still hide
        vm.items = [
            Item(id: "1", text: "Resolved", done: false, created: "2025-01-01T10:00:00Z", status: "resolved"),
            Item(id: "2", text: "Blocked", done: false, created: "2025-01-01T10:00:00Z", status: "blocked"),
            Item(id: "3", text: "Done", done: true, created: "2025-01-01T10:00:00Z", status: "closed"),
        ]

        XCTAssertFalse(vm.hasUnblockedTickets, "Only non-actionable tickets should result in no unblocked tickets")
    }

    func testHasUnblockedTicketsIncludesInProgress() {
        let vm = makeViewModel()

        // In-progress tickets — agent should show
        vm.items = [
            Item(id: "1", text: "In progress", done: false, created: "2025-01-01T10:00:00Z", status: "in_progress"),
        ]

        XCTAssertTrue(vm.hasUnblockedTickets, "In-progress tickets should count as unblocked")

        // Open tickets — agent should show
        vm.items = [
            Item(id: "1", text: "Open ticket", done: false, created: "2025-01-01T10:00:00Z", status: "open"),
        ]

        XCTAssertTrue(vm.hasUnblockedTickets, "Open tickets should count as unblocked")

        // Mix of in_progress and resolved — agent should show (has actionable work)
        vm.items = [
            Item(id: "1", text: "In progress", done: false, created: "2025-01-01T10:00:00Z", status: "in_progress"),
            Item(id: "2", text: "Resolved", done: false, created: "2025-01-01T10:00:00Z", status: "resolved"),
        ]

        XCTAssertTrue(vm.hasUnblockedTickets, "Mix with in_progress should count as having unblocked tickets")

        // Mix of open, blocked, and done — agent should show (has actionable work)
        vm.items = [
            Item(id: "1", text: "Open", done: false, created: "2025-01-01T10:00:00Z", status: "open"),
            Item(id: "2", text: "Blocked", done: false, created: "2025-01-01T10:00:00Z", status: "blocked"),
            Item(id: "3", text: "Done", done: true, created: "2025-01-01T10:00:00Z", status: "closed"),
        ]

        XCTAssertTrue(vm.hasUnblockedTickets, "Open tickets should count even with blocked and done tickets present")
    }
}
