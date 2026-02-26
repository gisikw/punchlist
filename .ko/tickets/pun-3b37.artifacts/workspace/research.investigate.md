## Summary

I've completed the research and documented my findings. Here's what I discovered:

**Answer: Not bad at all - it's actually quite easy.**

### Key Findings

The app targets iOS 17.0, which means SwiftUI's built-in markdown support (available since iOS 15) can be used without any external dependencies.

**Current State:**
- Body text renders in `ItemRow.swift:167-175` as plain text
- Uses simple `Text(desc)` with no formatting

**Best Implementation Approach:**
- Use `AttributedString(markdown:)` API - native to iOS 15+
- Supports **all requested features**: headers, lists, italics, bold, and more
- Requires changing ~5 lines of code
- Zero external dependencies
- Estimated 25 minutes total (implementation + testing)

**Risk Level: Very Low**
- Backward compatible with plain text
- Invalid markdown gracefully falls back
- No breaking changes
- No performance impact

The findings document has been written to `$KO_ARTIFACT_DIR/findings.md` with full implementation details, code examples, risk assessment, and recommendations.
