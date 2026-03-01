Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written. The fix is one line: add `.buttonStyle(.plain)` to the clear button in `Punchlist/Views/InputBar.swift`. SwiftUI buttons tint their labels with the app's accent color by default — `.buttonStyle(.plain)` disables that, so the existing `.foregroundStyle(.secondary)` renders as plain grey with no color influence.
