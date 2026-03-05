Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "continue"}
```

The plan is complete and ready for implementation. Here's my assessment:

**No Open Questions** — The two clarifying questions in the ticket notes have been answered (always show triage button; show block action if not blocked, unblock if blocked).

**Completeness** — The plan clearly specifies:
- Goal: Hide labels on collapsed cards in project view and replace with SVG action buttons
- Target file: `ItemRow.swift`
- Five concrete, ordered changes: state addition, text fading animation, three-zone tap handler, circle actions overlay with three buttons, and body wiring with expand/collapse reset
- Implementation details: exact button icons (bubble.left, lock.fill, checkmark.circle.fill), behavior conditions (block vs unblock based on state), and gesture precedence

**Feasibility** — Changes reference `ItemRow.swift` (which exists and is already modified per git status) and use standard SwiftUI patterns (@State, computed properties, overlay priority, onChange modifiers).

No architectural decisions remain open, no verification steps are missing, and the plan is sufficiently detailed for implementation.
