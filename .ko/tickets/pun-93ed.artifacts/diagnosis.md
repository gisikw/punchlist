# Diagnosis: Container doesn't shrink when large ticket collapses

## Symptoms

When a large ticket with expanded content (description, plan questions, hold-to-close bar) is collapsed, the tickets can seemingly disappear from view. The ScrollView container doesn't immediately shrink to accommodate the reduced content height. Users can recover the missing tickets by scrolling, but the experience is jarring and suggests a layout synchronization issue.

## Root Cause

The issue stems from how SwiftUI's ScrollView handles content size changes during animated layout transitions. The problem occurs at the intersection of several factors:

1. **Animated expansion/collapse**: `ItemRow.swift:88` applies a spring animation to the entire card when `isExpanded` changes:
   ```swift
   .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
   ```

2. **LazyVStack in ScrollView**: `ContentView.swift:180` uses a `LazyVStack` inside a `ScrollView`:
   ```swift
   ScrollView {
       LazyVStack(spacing: 8) {
           ForEach(...) { item in
               ItemRow(...)
           }
       }
   }
   ```

3. **Dynamic content height**: When a ticket expands, it can include:
   - Expanded text section (`ItemRow.swift:62-64`) with ticket ID and description
   - Plan questions view (`ItemRow.swift:71-78`) with multiple questions, options, and potentially text input
   - Hold-to-close bar (`ItemRow.swift:79-80`)

   A large ticket with multiple plan questions can easily grow from ~80pt to 300-500pt in height.

4. **Lazy loading behavior**: `LazyVStack` measures visible items on-demand. When a large item collapses during animation, the LazyVStack may not immediately recalculate the total content height, causing the ScrollView to maintain its previous content size assumption.

5. **Scroll position not adjusted**: When the expanded item collapses, the scroll position isn't being adjusted to account for the content that just disappeared above or at the current scroll position. This leaves the ScrollView "pointed" at content that may now be off-screen.

**Affected Code**:
- `Punchlist/Views/ContentView.swift:176-220` - itemList view with ScrollView and LazyVStack
- `Punchlist/Views/ItemRow.swift:57-111` - ItemRow body with animated expansion
- `ContentView.swift:204-209` - onCollapse handler that triggers the collapse animation

## Recommended Fix

There are several approaches to fix this, in order of preference:

### Option 1: Use ScrollViewReader to maintain scroll position (Recommended)

The ScrollViewReader is already in place (`ContentView.swift:178`) but not being used during collapse. Modify the `onCollapse` handler to:

1. Before collapsing, capture the current scroll position or a reference item
2. After the collapse animation, use `proxy.scrollTo()` to adjust the scroll position
3. This ensures the visible content remains visible even after the height change

This is the least invasive and most predictable solution.

### Option 2: Force layout recalculation on collapse

Add an explicit layout pass after collapse by:
1. Using `.id()` modifier on the LazyVStack that changes when an item collapses
2. Or temporarily disable/re-enable the LazyVStack to force a full remeasure

This is more aggressive and could cause visible flicker.

### Option 3: Replace LazyVStack with VStack

Since the item list appears to be relatively small (not thousands of items), using a regular `VStack` instead of `LazyVStack` would ensure all items are always measured and the ScrollView content size is always accurate. However, this trades the lazy loading optimization for layout correctness.

## Risk Assessment

### Risk of implementing Option 1 (ScrollViewReader adjustment):

**Low to Medium Risk**

- **Could affect**: Scroll position calculations, especially edge cases like collapsing the top or bottom item
- **Edge cases to test**:
  - Collapsing the topmost visible item
  - Collapsing an item while scrolled to bottom
  - Collapsing multiple items in quick succession
  - Collapsing while keyboard is visible
  - Collapsing during an ongoing scroll gesture
- **Potential issues**:
  - Over-correction causing visible "jump" in content
  - Animation fighting between collapse animation and scroll position adjustment
  - Different behavior on different screen sizes
- **Mitigation**: Can be implemented with a feature flag or conditional behavior to test safely

### Risk of implementing Option 2 (Force layout recalculation):

**Medium Risk**

- **Could affect**: Performance with many items, animation smoothness
- **Potential issues**:
  - Visible flicker or content "pop"
  - Breaking lazy loading benefits if list grows large
  - May not fully solve the problem if timing is wrong

### Risk of implementing Option 3 (Replace LazyVStack with VStack):

**Low Risk for correctness, Medium Risk for performance**

- **Could affect**: App performance with large item lists, memory usage
- **Trade-offs**:
  - Guaranteed correct layout at all times
  - Loss of lazy loading optimization
  - If the project task list grows to hundreds of items, could cause performance issues
- **Current context**: Based on the codebase, this appears to be a task management app where projects typically have dozens to maybe a hundred tasks, not thousands. VStack should handle this fine.

## Additional Context

The `.defaultScrollAnchor(.bottom)` on line 218 of ContentView.swift suggests new items are added at the bottom, and the reversed array iteration (line 177) shows items in reverse chronological order. This means most user interaction happens near the bottom of the list, where this bug would be most noticeable when collapsing items.

The animation is intentionally smooth (0.35s spring), which gives more time for the layout/scroll desynchronization to manifest visually.
