Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Compiles cleanly. All plan tasks were already implemented in `ItemRow.swift`:

1. **State** — `@State private var showCircleActions = false` (line 26)
2. **`headerRow`** — text fades to opacity 0 with 0.18s animation when `showCircleActions` is active (lines 184–185)
3. **`collapsedProjectHoldOverlay`** — simplified to three-zone tap: left 44pt → `showCircleActions = true`, middle → `onExpand()`, right 20% → `onBump()` (lines 341–365)
4. **`circleActionsOverlay`** — three icon buttons: `bubble.left` (gray/triage), `lock.fill`/`lock.open.fill` (pink/orange for block/unblock), `checkmark.circle.fill` (green/complete) (lines 367–411)
5. **Body wiring** — overlay priority order `circleActionsOverlay` → `collapsedProjectHoldOverlay` → `tapOverlay`; `.onChange(of: isExpanded)` resets `showCircleActions` (lines 82–89, 174–176)

No deviations from the plan.
