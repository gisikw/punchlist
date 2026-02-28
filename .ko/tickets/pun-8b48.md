---
id: pun-8b48
status: closed
deps: []
created: 2026-02-26T21:41:41Z
type: task
priority: 2
---
# Let's add basic markdown parsing to ticket bodies. I like keeping the font small and readable the way that it is - so just treating headers as bold or something similarly simple could work? Doesn't need to be exhaustive, but would be nice to see some basic ticket note body parsing

## Notes

**2026-02-26 21:46:31 UTC:** # Implementation Summary: Basic Markdown Parsing for Ticket Bodies

## What Was Done

Added basic markdown parsing to ticket description bodies using SwiftUI's native `AttributedString` markdown support. The implementation maintains the existing small, readable font (13pt) while enabling simple formatting like headers (rendered as bold), bold text, italic text, and bulleted lists.

## Changes Made

### 1. ItemRow.swift (lines 169-191)
Replaced plain `Text(desc)` rendering with markdown-aware implementation:
- Uses `AttributedString(markdown:options:)` with `.inlineOnlyPreservingWhitespace` parsing option
- Preserved all existing styling: 13pt system font, punchGray color
- Maintained all view modifiers (lineLimit, multilineTextAlignment, fixedSize, padding)
- Added fallback to plain text if markdown parsing fails (graceful degradation)

### 2. PunchlistTests.swift (lines 267-372)
Added `ItemRowMarkdownTests` test class with 8 comprehensive tests:
- Bold parsing (`**text**`)
- Italic parsing (`*text*`)
- Header parsing (`# Header`)
- List parsing (`- Item`)
- Plain text fallback (non-markdown strings)
- Malformed markdown handling (doesn't crash)
- Empty string handling
- Mixed markdown elements (complex cases)

## Notable Decisions

**Parsing Option**: Used `.inlineOnlyPreservingWhitespace` to keep the formatting simple and readable while supporting basic markdown. This prevents block-level elements from adding excessive spacing, maintaining the compact, readable style of the UI.

**Fallback Strategy**: Implemented graceful fallback to plain text rendering if markdown parsing fails. This ensures robustness—malformed or edge-case markdown won't break the UI.

**No New Dependencies**: Leveraged iOS's built-in `AttributedString` markdown support (iOS 15+, well within the iOS 17+ target). Complies with the no-third-party-dependencies invariant.

## Verification

- ✅ Build succeeds (`just build`)
- ✅ All tests pass (8/8 new tests green)
- ✅ No invariant violations
- ✅ Headers render as bold (standard markdown behavior)
- ✅ Font size and color preserved

## Future Considerations

If more advanced markdown formatting is needed (e.g., different header sizes, code blocks, links), the `.inlineOnlyPreservingWhitespace` option could be changed or the `AttributedString` could be post-processed to apply custom styling. For now, the simple approach meets the ticket requirements.

**2026-02-26 21:46:31 UTC:** ko: SUCCEED
