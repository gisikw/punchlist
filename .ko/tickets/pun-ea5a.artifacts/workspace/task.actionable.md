Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Looking at this plan for implementing hold-to-action on collapsed project-mode cards:

**Open Questions:** The plan states "None" and explains why the approach is straightforward (hold logic maps from existing `holdToCloseBar`, quick-tap routing uses `startLocation.x`, done-item handling via existing `onToggle`).

**Completeness:** ✓
- Goal is clear: collapsed cards trigger green fill + context-aware actions matching expanded hold bar
- Context is detailed with specific line references and explains key components (`tapOverlay`, `holdToCloseBar`, existing state, rendering constraints)
- Approach explains the strategy clearly
- Three ordered tasks with specific file/line targets and clear verification steps
- Each task specifies what to verify (visual correctness, gesture behavior, interaction zones)

**Feasibility:** ✓
- File `Punchlist/Views/ItemRow.swift` is plausible (referenced in your memory from previous hold-bar work)
- Specific line references (178, 253, 70, 80, 128) are reasonable for an active SwiftUI file
- Referenced state variables (`holdProgress`, `isHolding`, `holdStartTime`, `holdDelayTask`) are noted as existing
- Gesture patterns (`DragGesture`, `GeometryReader`), SwiftUI modifiers (`.background`, `.clipShape`), and callbacks (`onOpen`, `onClose`, `onToggle`) are all sensible for iOS code
- The approach directly mirrors existing `holdToCloseBar` logic, reducing implementation risk

```json
{"disposition": "continue"}
```
