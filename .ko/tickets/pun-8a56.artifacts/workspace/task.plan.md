Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written. The fix is a one-liner in `InputBar.swift:24` — change `.foregroundStyle(.secondary)` to `.foregroundStyle(.tertiary)`. SwiftUI's `.tertiary` is the next step lighter in the semantic color hierarchy, which should give the right lighter-grey appearance without hardcoding any color values.
