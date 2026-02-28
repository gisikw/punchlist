# pun-347b: Triage Text Input — After-Action Summary

## What Was Done

Implemented inline triage text entry on project ticket rows, triggered by tapping the status circle:

1. **KoAPI.swift** — Added `triageItem(id:text:)` following the fire-and-forget `run([...argv...])` pattern.
2. **PunchlistViewModel.swift** — Added `triageItem(_:text:)` with whitespace trimming; intentionally skips the offline queue since triage is an annotation (not a state mutation).
3. **ItemRow.swift** — Added `onTriage: ((String) -> Void)?` callback, two `@State` vars (`showTriageInput`, `triageText`), restructured `tapOverlay` to carve a fixed 44pt circle zone from the leading expand area, and added an inline `TextField` + X cancel button block between the overlay and the `isExpanded` section.
4. **ContentView.swift** — Wires `onTriage` as `nil` for personal view, and `{ text in viewModel.triageItem(item, text: text) }` for project view.

## Notable Decisions

- **No offline queue for triage**: Documented in the plan. Triage adds an annotation rather than mutating ticket state, so a dropped triage note while offline is acceptable. This is consistent with the spirit of fire-and-forget mutations.
- **44pt zone in tapOverlay**: Carved from the leading portion of the old 80% expand zone, matching the 44pt leading inset used throughout the card layout. In personal view (`onTriage == nil`), the circle zone falls back to `onToggle()`, preserving prior behavior.
- **Inline input, not a modal**: Consistent with the "no modals, no toasts, no confirmations" invariant.

## Things to Know

- The diff also includes markdown parsing changes to `expandedText` in ItemRow.swift (the `processed` variable with header → bold conversion). These are pre-existing uncommitted changes from ticket pun-8b48 and are not part of this ticket's scope.
- A `flake.lock` file was inadvertently staged during the implementation run; it was unstaged during review and is not included in these changes.
- No tests exist in this codebase, so none were added.
