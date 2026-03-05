# pun-054b: Circle tap action menu for collapsed project cards

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
