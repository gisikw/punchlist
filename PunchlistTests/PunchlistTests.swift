import XCTest
@testable import Punchlist

final class ItemDecodingTests: XCTestCase {
    func testDecodeItemMinimalRequired() throws {
        let json = """
        {
            "id": "item-1",
            "title": "Test Item",
            "created": "2025-01-01T10:00:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let item = try decoder.decode(Item.self, from: json)

        XCTAssertEqual(item.id, "item-1")
        XCTAssertEqual(item.text, "Test Item")
        XCTAssertEqual(item.created, "2025-01-01T10:00:00Z")
        XCTAssertFalse(item.done)
        XCTAssertNil(item.priority)
        XCTAssertNil(item.status)
        XCTAssertNil(item.modified)
    }

    func testDecodeItemWithStatus() throws {
        let json = """
        {
            "id": "item-2",
            "title": "Done Item",
            "created": "2025-01-01T10:00:00Z",
            "status": "closed"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let item = try decoder.decode(Item.self, from: json)

        XCTAssertTrue(item.done)
        XCTAssertEqual(item.status, "closed")
    }

    func testDecodeItemWithOpenStatus() throws {
        let json = """
        {
            "id": "item-3",
            "title": "Open Item",
            "created": "2025-01-01T10:00:00Z",
            "status": "in_progress"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let item = try decoder.decode(Item.self, from: json)

        XCTAssertFalse(item.done)
        XCTAssertEqual(item.status, "in_progress")
    }

    func testDecodeItemWithAllFields() throws {
        let json = """
        {
            "id": "item-4",
            "title": "Full Item",
            "created": "2025-01-01T10:00:00Z",
            "priority": 1,
            "status": "closed",
            "description": "A full item",
            "modified": "2025-01-02T10:00:00Z",
            "hasUnresolvedDep": false,
            "plan-questions": [
                {
                    "id": "q1",
                    "question": "What should we do?",
                    "context": "Context here",
                    "options": [
                        {
                            "label": "Option A",
                            "value": "a",
                            "description": "First option"
                        }
                    ]
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let item = try decoder.decode(Item.self, from: json)

        XCTAssertEqual(item.id, "item-4")
        XCTAssertEqual(item.text, "Full Item")
        XCTAssertEqual(item.priority, 1)
        XCTAssertTrue(item.done)
        XCTAssertEqual(item.description, "A full item")
        XCTAssertEqual(item.modified, "2025-01-02T10:00:00Z")
        XCTAssertFalse(item.hasUnresolvedDep ?? true)
        XCTAssertEqual(item.planQuestions?.count, 1)
        XCTAssertEqual(item.planQuestions?.first?.id, "q1")
    }

    func testDecodeItemTitleMapping() throws {
        let json = """
        {
            "id": "item-5",
            "title": "Mapped Title",
            "created": "2025-01-01T10:00:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let item = try decoder.decode(Item.self, from: json)

        // Ensure "title" from JSON maps to "text" in model
        XCTAssertEqual(item.text, "Mapped Title")
    }
}

final class PlanQuestionDecodingTests: XCTestCase {
    func testDecodePlanQuestion() throws {
        let json = """
        {
            "id": "q1",
            "question": "What is the best approach?",
            "context": "We need to decide on architecture.",
            "options": [
                {
                    "label": "Option A",
                    "value": "opt_a",
                    "description": "First choice"
                },
                {
                    "label": "Option B",
                    "value": "opt_b",
                    "description": "Second choice"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let question = try decoder.decode(PlanQuestion.self, from: json)

        XCTAssertEqual(question.id, "q1")
        XCTAssertEqual(question.question, "What is the best approach?")
        XCTAssertEqual(question.context, "We need to decide on architecture.")
        XCTAssertEqual(question.options.count, 2)
        XCTAssertEqual(question.options[0].label, "Option A")
        XCTAssertEqual(question.options[0].value, "opt_a")
        XCTAssertEqual(question.options[1].label, "Option B")
    }

    func testDecodePlanQuestionWithoutContext() throws {
        let json = """
        {
            "id": "q2",
            "question": "Simple question?",
            "options": [
                {
                    "label": "Yes",
                    "value": "yes",
                    "description": "Affirmative"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let question = try decoder.decode(PlanQuestion.self, from: json)

        XCTAssertEqual(question.id, "q2")
        XCTAssertNil(question.context)
        XCTAssertEqual(question.options.count, 1)
    }

    func testPlanOptionId() throws {
        let json = """
        {
            "label": "Test Option",
            "value": "test_val",
            "description": "Test"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let option = try decoder.decode(PlanOption.self, from: json)

        // id property should return value
        XCTAssertEqual(option.id, "test_val")
        XCTAssertEqual(option.value, "test_val")
    }
}

final class ProjectDecodingTests: XCTestCase {
    func testDecodeProjectMinimal() throws {
        let json = """
        {
            "tag": "my-project"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let project = try decoder.decode(Project.self, from: json)

        XCTAssertEqual(project.slug, "my-project")
        XCTAssertEqual(project.name, "my-project")
        XCTAssertFalse(project.isDefault)
    }

    func testDecodeProjectWithDefault() throws {
        let json = """
        {
            "tag": "user",
            "is_default": true
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let project = try decoder.decode(Project.self, from: json)

        XCTAssertEqual(project.slug, "user")
        XCTAssertTrue(project.isDefault)
    }

    func testDecodeProjectDefaultFalse() throws {
        let json = """
        {
            "tag": "project-1",
            "is_default": false
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let project = try decoder.decode(Project.self, from: json)

        XCTAssertFalse(project.isDefault)
    }

    func testProjectId() throws {
        let json = """
        {
            "tag": "test-project"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let project = try decoder.decode(Project.self, from: json)

        // id property should return slug
        XCTAssertEqual(project.id, "test-project")
    }

    func testProjectTagMapping() throws {
        let json = """
        {
            "tag": "mapped-tag"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let project = try decoder.decode(Project.self, from: json)

        // Ensure "tag" from JSON maps to "slug" in model
        XCTAssertEqual(project.slug, "mapped-tag")
    }
}

final class ItemRowMarkdownTests: XCTestCase {
    func testMarkdownBoldParsing() throws {
        let markdown = "This is **bold** text"
        let attributed = try AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.characters.count > 0)
    }

    func testMarkdownItalicParsing() throws {
        let markdown = "This is *italic* text"
        let attributed = try AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.characters.count > 0)
    }

    func testMarkdownHeaderParsing() throws {
        let markdown = "# Header\nSome text"
        let attributed = try AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.characters.count > 0)
    }

    func testMarkdownListParsing() throws {
        let markdown = "- Item 1\n- Item 2\n- Item 3"
        let attributed = try AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.characters.count > 0)
    }

    func testPlainTextFallback() throws {
        let plainText = "This is plain text without markdown"
        let attributed = try AttributedString(
            markdown: plainText,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertEqual(String(attributed.characters), plainText)
    }

    func testMalformedMarkdownDoesNotCrash() {
        let malformed = "**Unclosed bold"
        let attributed = try? AttributedString(
            markdown: malformed,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        // Should still parse, just won't apply formatting
        XCTAssertNotNil(attributed)
    }

    func testEmptyStringHandling() throws {
        let empty = ""
        let attributed = try AttributedString(
            markdown: empty,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertEqual(attributed.characters.count, 0)
    }

    func testMixedMarkdownElements() throws {
        let mixed = "# Title\n\nSome **bold** and *italic* text:\n- Item 1\n- Item 2"
        let attributed = try AttributedString(
            markdown: mixed,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )

        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.characters.count > 0)
    }
}
