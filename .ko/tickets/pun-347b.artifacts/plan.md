## Goal
Add an inline triage text entry to project ticket rows, triggered by tapping the status circle, that submits `ko triage <id> <text>` on confirmation.

## Context
- `KoAPI.swift` handles all ko CLI calls via a POST to `/ko`. New methods follow the pattern: call `run([...argv...])` and discard the output (like `bumpItem`).
- `PunchlistViewModel.swift` has `triageItem` — does not exist yet. Actions follow a fire-and-forget pattern: `Task { try? await api.method(...) }`. No offline queue needed since triage is an annotation, not a state mutation.
- `ItemRow.swift` receives an `isPersonal` flag already. The status circle is a computed property `circle` inside `headerRow`. The whole `headerRow + expandedText` block is covered by a `.overlay { tapOverlay }` which intercepts all taps with a two-zone split (left 80% = expand, right 20% = bump). To make the circle zone tappable separately, the `tapOverlay` must add a third leftmost zone (~44pt) that fires the triage action instead of expand.
- The triage input should appear inline below the header row (outside the `isExpanded` gate, like a sibling to the existing `if isExpanded` block), so it's visible without requiring card expansion.
- `ContentView.swift` wires callbacks into each `ItemRow`. The `isPersonal` check already guards project-only features; triage passes `nil` for personal view and a closure for project view.

## Approach
Add `triageItem` to `KoAPI` and `PunchlistViewModel`. Add an `onTriage: ((String) -> Void)?` callback to `ItemRow` along with local state for showing/hiding the inline input. Restructure `tapOverlay` to split the left region into a 44pt circle zone (fires triage open) and a remaining expand zone. Wire up in `ContentView`.

## Tasks

1. **[Punchlist/Services/KoAPI.swift]** — Add `func triageItem(id: String, text: String) async throws` under the `// MARK: - Items` section. Implementation: `_ = try await run(["triage", id, text])`.
   Verify: File compiles without errors.

2. **[Punchlist/ViewModels/PunchlistViewModel.swift]** — Add `func triageItem(_ item: Item, text: String)` in the `// MARK: - Actions` section. Pattern mirrors `bumpItem`: just `Task { try? await api.triageItem(id: item.id, text: trimmed) }` where `trimmed` is text trimmed of whitespace. No offline queue entry needed.
   Verify: File compiles; existing tests still pass.

3. **[Punchlist/Views/ItemRow.swift]** — Three changes:
   a. Add `let onTriage: ((String) -> Void)?` to the struct's parameter list (after `onCollapse`). A `nil` value means triage is unavailable (personal view).
   b. Add two `@State` vars: `private var showTriageInput = false` and `private var triageText = ""`.
   c. In `tapOverlay`, within the non-done `HStack` branch, split the left region into two: a leading `Color.clear.frame(width: 44)` tap zone that calls `showTriageInput.toggle()` when `onTriage != nil`, otherwise calls the existing `isPersonal ? onToggle() : onExpand()` fallback; then the remaining width expand zone.
   d. In `body`, add an `if showTriageInput` block between the overlay section and the `if isExpanded && !item.done` block. This block renders a `TextField` bound to `triageText` with a submit button. On submit: call `onTriage?(triageText.trimmingCharacters(in: .whitespacesAndNewlines))`, then set `triageText = ""` and `showTriageInput = false`. Include a cancel affordance (X button or tapping away) that resets state without submitting.
   Verify: Circle zone tap in project view shows the triage input; submit dismisses it.

4. **[Punchlist/Views/ContentView.swift]** — In `itemList`, update the `ItemRow` initializer to pass `onTriage`: for project items pass `{ text in viewModel.triageItem(item, text: text) }`; for personal (or as the fallback) pass `nil`. The existing `viewModel.isPersonal` property already tracks this.
   Verify: App builds; tapping circle on personal item does not show triage input; tapping circle on project item shows inline text entry; submitting calls the API.

## Open Questions
None. The interaction is straightforward and the codebase patterns are clear.
