## Goal
Tapping the circle on a collapsed project-mode card reveals three icon-button actions (triage, block/unblock, complete) in place of the card's text label.

## Context
All changes are in `Punchlist/Views/ItemRow.swift`.

The collapsed project card interaction lives in two places:
- `collapsedProjectHoldOverlay` — the gesture/tap layer overlaid on `headerRow`
- `headerRow` — renders `circle` + `text` + chevron

The overlay is applied conditionally at the top of `body`:
```
if !isExpanded && !isPersonal { collapsedProjectHoldOverlay } else { tapOverlay }
```

The circle zone in `collapsedProjectHoldOverlay` currently has a `DragGesture` meant for hold, plus a quick-tap branch. The hold gesture on circle was the feature that "isn't working" (per git log it intercepts scroll).

Relevant callbacks already exist for all three actions:
- **Triage**: set `showTriageInput = true`
- **Block/Unblock**: `onClose()` to block, `onOpen()` to unblock (when blocked + no open questions)
- **Complete**: `onToggle()`

SF Symbols to use: `bubble.left` (comment/triage), `lock.fill` / `lock.open.fill` (block/unblock), `checkmark.circle.fill` (complete).

## Approach
Add a `@State var showCircleActions = false` flag. When it's true and the card is in collapsed project mode, swap the overlay for a `circleActionsOverlay` that shows three icon buttons where the text was, while simultaneously hiding the text in `headerRow`. The circle zone in the new overlay dismisses the actions on tap. The existing `collapsedProjectHoldOverlay` circle zone is simplified to a plain tap gesture that sets `showCircleActions = true`.

## Tasks

1. **[ItemRow.swift — state]** Add `@State private var showCircleActions = false` alongside the other `@State` properties.
   Verify: file compiles.

2. **[ItemRow.swift — headerRow]** In the `headerRow`'s HStack, conditionally hide `text` when `showCircleActions && !isExpanded && !isPersonal`. Replace `text` with `Color.clear` (or `Spacer()`) so the space is preserved for the action buttons in the overlay. Wrap in `.animation(.easeInOut(duration: 0.18), value: showCircleActions)`.
   Verify: in normal mode the label shows; after tapping circle it disappears.

3. **[ItemRow.swift — collapsedProjectHoldOverlay]** Replace the `DragGesture` on the circle zone with a plain `.onTapGesture { showCircleActions = true }`. Remove the hold fill logic from this zone entirely (the `holdProgress` background fill was for the whole-card hold behavior already removed in prior tickets, so this is cleanup).
   Verify: tapping the circle in project view sets `showCircleActions = true`.

4. **[ItemRow.swift — circleActionsOverlay]** Add a new private var `circleActionsOverlay: some View`. Layout:
   - `GeometryReader` wrapping an `HStack(spacing: 0)`
   - Left 44pt: `Color.clear.contentShape(Rectangle()).onTapGesture { showCircleActions = false }` (tapping circle again dismisses)
   - Middle (maxWidth: .infinity): `HStack(spacing: 20)` with three `Button` views:
     - Comment: `Image(systemName: "bubble.left")` → `showTriageInput = true; showCircleActions = false`
     - Block/Unblock: `Image(systemName: isBlocked ? "lock.open.fill" : "lock.fill")` → `isBlocked ? onOpen() : onClose(); showCircleActions = false`
     - Complete: `Image(systemName: "checkmark.circle.fill")` → `onToggle(); showCircleActions = false`
   - Right `geo.size.width * 0.2`: `Color.clear.contentShape(Rectangle()).onTapGesture { showCircleActions = false }`

   Style the buttons with appropriate colors: comment in `.punchGray`, block/unblock in `.punchPink`/`.punchOrange`, complete in `.punchGreen`. Use `.font(.system(size: 20))` for the icons.
   Verify: all three buttons are tappable and trigger the correct callbacks.

5. **[ItemRow.swift — overlay wiring]** In `body`, change the overlay condition to:
   ```
   if showCircleActions && !isExpanded && !isPersonal {
       circleActionsOverlay
   } else if !isExpanded && !isPersonal {
       collapsedProjectHoldOverlay
   } else {
       tapOverlay
   }
   ```
   Also add `.onChange(of: isExpanded) { _, _ in showCircleActions = false }` to reset the state on expand/collapse.
   Verify: switching to circleActionsOverlay when circle is tapped; dismiss on expand.

## Open Questions

1. **Block action on non-blocked items**: `onClose()` sets status to blocked/closed. Is triggering close from the actions panel the intended behavior for non-blocked items, or should the block button only appear when the item is already blocked (making it an unblock-only button)?
   *Assumption*: show block/unblock for all states — block for open items, unblock for blocked items.

2. **Triage button visibility**: Should the comment/triage button be hidden when `hasTriage` is already true (matching existing behavior where the circle tap zone doesn't show triage input if `hasTriage`)? Current plan hides nothing and always shows all three buttons.
   *Assumption*: always show all three; triage can add a second note.
