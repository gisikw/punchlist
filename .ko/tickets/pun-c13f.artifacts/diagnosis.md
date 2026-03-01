# Diagnosis: Triage indicator superseded by "done" indicator

## Symptoms

When a ticket has a triage value (`item.triage != nil`) and is also marked as done (`item.done == true`) or resolved (`item.status == "resolved"`), the green checkmark circle renders instead of the grey filled triage circle.

## Root Cause

In `ItemRow.swift`, the `circle` computed property (lines 322–352) uses an `if / else if` chain to decide which fill to render inside the circle:

```swift
if item.done || isResolved {
    Circle()
        .fill(Color.punchGreen)
        .frame(width: 22, height: 22)

    Image(systemName: "checkmark")
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(.white)
} else if hasTriage {
    Circle()
        .fill(Color.punchGray.opacity(0.45))
        .frame(width: 22, height: 22)
}
```

Because `item.done || isResolved` is evaluated first, a ticket that is both done and has a triage value will always display the green fill + checkmark. The `hasTriage` branch is never reached.

A secondary issue exists in `circleColor` (lines 313–320): `item.done` is also the first check, so the stroke border for a triage+done ticket will be green rather than grey.

```swift
private var circleColor: Color {
    if item.done { return .punchGreen }   // ← wins before triage check
    if isResolved { return .punchGreen }
    ...
    return .punchGray                      // ← this is what triage items should get
}
```

## Affected Code

| Location | Lines | What's wrong |
|---|---|---|
| `Punchlist/Views/ItemRow.swift` | 332–344 | `if item.done` branch checked before `hasTriage` in `circle` view |
| `Punchlist/Views/ItemRow.swift` | 313–320 | `circleColor` returns green for done items before triage is checked |

## Recommended Fix

Invert the priority in both the `circle` ZStack fill chain and in `circleColor` so that `hasTriage` is checked first:

**`circle` view** — move the `hasTriage` branch above the `done/resolved` branch:

```swift
if hasTriage {
    Circle()
        .fill(Color.punchGray.opacity(0.45))
        .frame(width: 22, height: 22)
} else if item.done || isResolved {
    Circle()
        .fill(Color.punchGreen)
        .frame(width: 22, height: 22)
    Image(systemName: "checkmark")
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(.white)
}
```

**`circleColor`** — insert a `hasTriage` guard at the top:

```swift
private var circleColor: Color {
    if hasTriage { return .punchGray }
    if item.done { return .punchGreen }
    ...
}
```

## Risk Assessment

- **Low risk.** Both changes are localised to the visual rendering of the circle in a single view. No data model or API changes required.
- The fix aligns with the already-implemented rule from the previous triage ticket: "tickets with triage should not be eligible for additional triage (don't open the text input on tap)." Making triage visually dominate all other states is consistent with that intent.
- One edge to verify: a triage item that is also `in_progress` will lose the blue glow ring (the `hasActiveStatus` halo is driven by `isInProgress || isBlocked`, which is independent of the circle fill). The glow should still render correctly; only the inner fill and border colour change.
- `tapOverlay` treats `item.done` as a special case (whole-card toggle, no triage input). If a triage+done ticket needs tap behaviour adjusted, that would be a separate follow-up.

---

**Summary:** The bug is a simple ordering issue in an `if / else if` chain. The `item.done || isResolved` condition is evaluated before `hasTriage`, so the green checkmark overwrites the triage grey fill. Swapping the order so `hasTriage` is checked first — in both `circle` and `circleColor` — resolves the issue with minimal risk.
