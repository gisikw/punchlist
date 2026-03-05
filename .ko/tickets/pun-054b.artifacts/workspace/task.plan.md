Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
All changes are in place and the file compiles cleanly. Here's what was implemented:

**Changes to `ItemRow.swift`:**

1. **State** — Added `@State private var showCircleActions = false`

2. **`headerRow`** — Text fades to opacity 0 (animated at 0.18s) when `showCircleActions` is active in collapsed project mode, preserving layout space for the icon buttons

3. **`collapsedProjectHoldOverlay`** — Replaced the complex `DragGesture` hold behavior with a simple three-zone tap handler: left 44pt taps the circle → `showCircleActions = true`, middle → `onExpand()`, right 20% → `onBump()`

4. **`circleActionsOverlay`** — New computed var with three icon buttons:
   - `bubble.left` (gray) → opens triage input
   - `lock.fill` / `lock.open.fill` (pink/orange) → blocks or unblocks depending on state
   - `checkmark.circle.fill` (green) → completes the item

5. **Body wiring** — Overlay now picks `circleActionsOverlay` → `collapsedProjectHoldOverlay` → `tapOverlay` in priority order; `.onChange(of: isExpanded)` resets `showCircleActions` on card expand/collapse
