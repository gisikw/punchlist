## Goal
Add basic markdown parsing to ticket description bodies with simple formatting (headers as bold, lists, italics) while maintaining the current small, readable font size.

## Context
The ticket description is rendered in `ItemRow.swift` at lines 169-177 in the `expandedText` computed property. Currently it uses a plain `Text(desc)` view with `.font(.system(size: 13))`.

SwiftUI provides `AttributedString` with markdown initialization support (iOS 15+, well within the iOS 17+ target). The `Text` view can directly accept an `AttributedString` with markdown parsing via `try? AttributedString(markdown: desc)`.

The codebase has:
- No third-party dependencies policy (INVARIANTS.md line 42-43)
- iOS 17+ minimum target using `@Observable` macro
- Simple, focused code with no abstractions for one-off operations
- Tests follow XCTest patterns with decode/model verification

The current font is `.system(size: 13)` with `.punchGray` color. We need to preserve this base styling while allowing markdown formatting like **bold**, *italic*, headers, and lists.

## Approach
Replace the plain `Text(desc)` with markdown-parsed `AttributedString`. Use SwiftUI's built-in markdown initializer to handle basic formatting. Apply font and color styling to the attributed string to maintain current visual consistency. No new files or utilities needed—this is a direct inline replacement.

## Tasks
1. [Punchlist/Views/ItemRow.swift:169-177] — Replace `Text(desc)` with markdown-aware rendering.
   - Parse description with `try? AttributedString(markdown: desc, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))`
   - Apply `.font(.system(size: 13))` and `.foregroundStyle(Color.punchGray)` to preserve existing styling
   - Fall back to plain text if markdown parsing fails
   - Keep all existing view modifiers (lineLimit, multilineTextAlignment, fixedSize, padding)

   Verify: Build succeeds with `just build`, no runtime crashes when viewing items with descriptions.

2. [PunchlistTests/PunchlistTests.swift] — Add test for markdown rendering behavior.
   - Create `ItemRowMarkdownTests` test class
   - Test that markdown strings parse correctly (headers, bold, italic, lists)
   - Test that plain text still works as fallback
   - Test that malformed markdown doesn't crash

   Verify: `just test` or equivalent passes with new tests green.

## Open Questions
None — SwiftUI's built-in markdown support via `AttributedString` is straightforward and requires no architectural decisions. The `.inlineOnlyPreservingWhitespace` option preserves the simple, readable formatting while supporting basic markdown. If headers need different styling than just bold, that can be iterated on after seeing the initial implementation.
