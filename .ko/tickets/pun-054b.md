---
id: pun-054b
status: closed
deps: []
created: 2026-03-05T12:44:32Z
type: task
priority: 2
---
# The long press on circle project view isn't working. Let's try this: for a collapsed card in project view, tapping the circle hides the labels on the card and replaces them with nice tap target actions. SVG iconography. Have a comment icon which triggers the triage step, a block or unblock button, and a complete button

## Notes

**2026-03-05 14:21:04 UTC:** Question: Should the triage/comment button be hidden when the item already has a triage note, or always show it?
Answer: Always show triage button
Comment button always visible; allows adding multiple triage notes

**2026-03-05 14:21:04 UTC:** Question: When an item is NOT blocked, should the block/unblock button always show the block action, or should the button only appear when the item is already blocked?
Answer: If the item is not blocked, we wanna let the user block it. "Don't do this yet", effectively. If the ticket _is_ blocked, we want to let them reopen it

**2026-03-05 14:26:02 UTC:** # pun-054b: Circle tap action menu for collapsed project cards

## What was done

Replaced the broken long-press gesture on collapsed project view cards with a tap-to-reveal action menu. Tapping the circle (left 44pt zone) now fades the card's text labels and shows three icon buttons inline:

- `bubble.left` (gray) — opens triage input
- `lock.fill` / `lock.open.fill` (pink/orange) — blocks or unblocks the item depending on current state
- `checkmark.circle.fill` (green) — completes the item

The middle zone still expands the card; the right 20% zone still bumps. Tapping any non-button area of the overlay dismisses it. Expanding/collapsing a card also resets the action menu state.

## Notable decisions

- **Done items bypass the action menu** — when `item.done`, the overlay uses a simple `onTapGesture { onToggle() }` rather than opening the circle action menu. This avoids showing a "complete" button on an already-complete item.
- **Block logic**: `if isBlocked { onOpen() } else { onClose() }` — matches ticket note: unblock an already-blocked item, block an unblocked one. Icon and color change accordingly.
- **The full DragGesture hold behavior was removed** — the ticket explicitly asked to replace the broken long-press, and the new approach is simpler and more reliable.
- **Text fades rather than disappears** — `.opacity(0)` keeps layout stable while icons are shown, preventing card height changes.

## What a future reader should know

- `onOpen` and `onClose` callbacks were added to `ItemRow` in the previous ticket (pun-ea5a); they are already wired in ContentView.
- The action menu is project-mode only (`!isPersonal && !isExpanded`), consistent with the rest of the collapsed project overlay logic.

**2026-03-05 14:26:02 UTC:** ko: SUCCEED
