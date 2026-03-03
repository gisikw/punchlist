## Goal
In project mode, holding a collapsed card triggers a full-card left-to-right green fill and executes the same context-aware action as the expanded hold bar.

## Context

All relevant code is in `Punchlist/Views/ItemRow.swift`.

- **`tapOverlay`** (line 178): Covers the tappable region of the card (header + expanded text). Uses `onTapGesture` with three zones: left 44pt (triage input or expand), center (expand), right 20% (bump). For `item.done`, the whole area just calls `onToggle()`.
- **`holdToCloseBar`** (line 253): 28pt bar below the expanded card. Uses `DragGesture(minimumDistance: 0)` with a 200ms grace period then 1.3s linear fill. On full hold: `onOpen()` if blocked+no questions, `onClose()` if blocked+questions, `onToggle()` otherwise. On quick tap (< 200ms): collapses. On mid-hold release: cancels.
- Existing state: `holdProgress`, `isHolding`, `holdStartTime`, `holdDelayTask` — already at the `ItemRow` level and can be reused.
- **`body`** (line 70): Card VStack with `.background(.white)` then `.clipShape(RoundedRectangle(cornerRadius: 8))`. The hold bar only appears when `isExpanded && !item.done`.

The green fill for the collapsed card must be rendered *inside* the clipped area to respect the card's rounded corners. The `tapOverlay` for collapsed project-mode cards must be replaced with a combined hold+tap gesture since `onTapGesture` doesn't compose with hold detection.

## Approach

Add a `collapsedProjectHoldOverlay` computed property that mirrors `holdToCloseBar`'s gesture logic but covers the entire card. On quick release (< 200ms), route to the correct tap action using `value.startLocation.x` and the card width from `GeometryReader`. On full hold, execute the same conditional action as `holdToCloseBar`. Add the green fill to the card's `.background` modifier (inside `.clipShape`) so it grows left-to-right across the full card, clipped to the rounded rect. Wire this overlay in `body` for collapsed project-mode cards in place of `tapOverlay`.

## Tasks

1. **[ItemRow.swift:body ~line 128]** — Replace `.background(.white)` with `.background { ZStack(alignment: .leading) { Color.white; if !isExpanded && !isPersonal && holdProgress > 0 { GeometryReader { geo in Color.punchGreen.opacity(0.35).frame(width: geo.size.width * holdProgress) } } } }`. This renders the green fill inside `.clipShape` so it respects the rounded corners.
   Verify: Card renders identically when `holdProgress == 0`; green fill visually fills the card from left during hold.

2. **[ItemRow.swift]** — Add a `private var collapsedProjectHoldOverlay: some View` computed property. Use `GeometryReader` to capture card width. Place a `Color.clear.contentShape(Rectangle())` with a `DragGesture(minimumDistance: 0)` attachment. Replicate `holdToCloseBar`'s gesture logic exactly:
   - `onChanged`: guard `!isHolding`, set `isHolding = true`, record `holdStartTime`, launch `holdDelayTask` with 200ms grace → 1.3s fill → conditional action (`onOpen`/`onClose`/`onToggle` based on `isBlocked` + `questions.isEmpty`).
   - `onEnded`: cancel task, clear state. If elapsed < 200ms (quick tap), dispatch tap action based on `value.startLocation.x`: x < 44 → triage toggle (if `onTriage != nil && !hasTriage`) else `onExpand()`; x > `geo.size.width * 0.8` → `onBump()`; otherwise → `onExpand()`. If `item.done`, the whole area just calls `onToggle()` on quick tap. If mid-hold release, animate fill back to 0.
   Verify: Quick taps on the three tap zones behave identically to `tapOverlay`. Full hold on a blocked card with no questions calls `onOpen`. Full hold on a blocked card with questions calls `onClose`. Full hold on a normal card calls `onToggle`.

3. **[ItemRow.swift:body ~line 80]** — Change `.overlay { tapOverlay }` to `.overlay { (!isExpanded && !isPersonal) ? AnyView(collapsedProjectHoldOverlay) : AnyView(tapOverlay) }`. (Or use a conditional `Group` / `@ViewBuilder` helper to avoid `AnyView`.) The `tapOverlay` continues to handle expanded cards and personal-mode cards unchanged.
   Verify: Expanded cards still respond to taps as before. Personal-mode cards still respond to taps as before. Collapsed project-mode cards show the hold gesture and green fill.

## Open Questions
None. The hold logic maps directly from `holdToCloseBar`; quick-tap routing uses `startLocation.x` from `DragGesture` which is readily available. The tick for done items (clear resolved) is handled by the existing `onToggle` path in both quick-tap and full-hold.
