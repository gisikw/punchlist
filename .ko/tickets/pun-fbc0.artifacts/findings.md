# Findings: Dynamic Input Growth with Word-Wrap

## Summary

**Yes, the add item input can grow dynamically with word-wrap.** The codebase already uses this pattern successfully in another component, and SwiftUI provides the necessary API (`axis: .vertical` + `lineLimit`). However, there are **important UX considerations** that should be addressed before implementing this change.

## Current Implementation

The input bar is currently implemented in `Punchlist/Views/InputBar.swift:9-21`:

```swift
TextField("Add item...", text: $text)
    .focused(isFocused)
    .textFieldStyle(.plain)
    .padding(14)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(color: .black.opacity(0.08), radius: 1.5, y: 1)
    .submitLabel(.done)
```

This is a single-line `TextField` that doesn't expand vertically as text wraps.

## Proven Pattern in Codebase

The codebase already implements dynamic multi-line text input in `Punchlist/Views/PlanQuestionsView.swift:132-146`:

```swift
TextField("Your answer...", text: binding, axis: .vertical)
    .font(.system(size: 12))
    .foregroundStyle(Color.punchText)
    .lineLimit(2...4)
    .submitLabel(.done)
    .focused($focusedQuestion, equals: question.id)
    .padding(8)
    .background(
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.punchGray.opacity(0.06))
    )
```

This demonstrates that:
1. SwiftUI's `TextField` with `axis: .vertical` supports dynamic height
2. The `lineLimit(2...4)` provides a bounded growth range (2-4 lines)
3. The pattern is already working in production in this app
4. Text wrapping within the constrained height works as expected

## Technical Approach

To make the input bar grow dynamically, the implementation would be:

```swift
TextField("Add item...", text: $text, axis: .vertical)
    .lineLimit(1...4)  // Start at 1 line, grow to max 4
    .focused(isFocused)
    .textFieldStyle(.plain)
    .padding(14)
    // ... rest of styling
```

Key parameters:
- `axis: .vertical` - enables multi-line text with dynamic height
- `lineLimit(1...4)` - constrains growth (minimum 1 line, maximum 4 lines)
- The TextField will grow automatically as text wraps

## UX Considerations & Potential Issues

### 1. **Scroll Anchor Behavior** ⚠️ CRITICAL

**Issue**: The main list uses `.defaultScrollAnchor(.bottom)` (ContentView.swift:218), which keeps the view anchored to the bottom where new items appear. When the input bar grows, it will push content upward, potentially causing:
- Jarring scroll jumps as the input expands
- Items disappearing off-screen as the input takes up space
- User losing their place in the list while typing

**Impact**: HIGH - This is the most significant UX concern.

**Mitigation Options**:
- Lock scroll position while input is focused
- Add smooth animation to input height changes
- Consider shrinking the visible list area rather than pushing it up
- Test with various list lengths and input text scenarios

### 2. **Keyboard Interaction**

**Current Behavior**: `.scrollDismissesKeyboard(.interactively)` (ContentView.swift:217) allows dismissing keyboard by scrolling.

**Consideration**: Growing input + keyboard + scroll interactions could be complex:
- Does scrolling while typing feel natural?
- Should the input shrink back when keyboard dismisses?
- How does focus management work with keyboard appearance?

**Impact**: MEDIUM - Needs careful testing on actual devices.

### 3. **Visual Balance**

**Current State**: Input bar has fixed height with 14pt padding (InputBar.swift:12).

**With Dynamic Height**:
- Input could consume significant screen real estate (up to 4 lines)
- Fixed padding (14pt) might feel too large when input is expanded
- Shadow and rounded corners will need to grow smoothly
- White background box growing could feel heavy at 4 lines

**Impact**: MEDIUM - Visual design may need refinement.

### 4. **Newline Handling** ⚠️ IMPORTANT

**Issue**: The PlanQuestionsView implementation actively prevents newlines (lines 124-126):

```swift
if newValue.contains("\n") {
    otherText[question.id] = newValue.replacingOccurrences(of: "\n", with: "")
    focusedQuestion = nil
}
```

This suggests the app intentionally treats Return/Enter as "submit" rather than "newline".

**Question**: Should the add item input:
- A) Allow explicit newlines (user can add multi-line tasks)?
- B) Treat Return as submit (like current behavior)?
- C) Require a specific gesture to submit (e.g., Cmd+Enter)?

**Current Behavior**: `.submitLabel(.done)` + `.onSubmit` means Return submits the item.

**Impact**: HIGH - This is a behavioral decision that affects usability.

### 5. **Layout Constraints**

**Current Layout** (ContentView.swift:22-26):
```swift
VStack(spacing: 0) {
    itemList
    offlineNotice
    inputBar
}
```

The input bar is fixed at the bottom. When it grows:
- It takes space from the itemList above
- The VStack will need to accommodate dynamic height
- Animations should be smooth to avoid jarring transitions

**Impact**: LOW - SwiftUI handles this automatically, but animation tuning needed.

### 6. **Item Text Display Comparison**

**Note**: Item text in ItemRow.swift:270-276 already supports multi-line:

```swift
Text(item.text)
    .lineLimit(nil)
    .multilineTextAlignment(.leading)
```

This means tasks can be multi-line when displayed. The question is whether the *input* should allow creating them directly with line breaks, or if multi-line tasks should only come from text wrapping.

## Design Philosophy Check

From INVARIANTS.md:
- "Input bar fixed at bottom — always visible, not part of the scroll" (line 29)
- "No modals, no toasts, no confirmations — mutations are instant and silent" (line 30-31)

Growing the input bar maintains "fixed at bottom" but changes the "always visible" in that it becomes larger/more prominent. This seems acceptable.

From README.md:
- "The input bar lives where your thumbs already are" (line 21)
- "Type, tap done, keep moving" (line 21)

A growing input might slightly change thumb reach, but probably not significantly for 1-4 lines.

## Recommended Actions

### If Proceeding with Implementation:

1. **Add dynamic height to InputBar.swift**:
   - Add `axis: .vertical` parameter
   - Set `lineLimit(1...4)` for bounded growth
   - Test padding adjustments (may need less padding when expanded)

2. **Handle scroll behavior**:
   - Add scroll position locking when input is focused
   - Smooth animations for height changes
   - Consider ScrollViewReader for scroll control

3. **Decide on newline behavior**:
   - Keep Return as submit (current UX pattern) OR
   - Allow newlines and require Cmd+Return to submit
   - This is a product decision, not a technical one

4. **Visual refinement**:
   - Test shadow/border scaling with height
   - Verify padding feels right at all sizes
   - Ensure white input box doesn't feel too heavy

5. **Comprehensive device testing**:
   - Test on various iPhone screen sizes
   - Test with different keyboard types
   - Test scrolling + typing + keyboard interactions
   - Verify thumb reach remains comfortable

### Alternative Approach:

If the UX issues prove too complex, consider:
- Keep single-line input
- Let text wrap visually during typing (text scrolls horizontally within the input)
- Display multi-line after item is created (already supported in ItemRow)

This maintains simplicity while still showing full text once submitted.

## Conclusion

**Technical feasibility**: ✅ YES - The implementation is straightforward and proven in the codebase.

**UX complexity**: ⚠️ MEDIUM-HIGH - Multiple interaction patterns need careful consideration:
1. Scroll anchor behavior (critical)
2. Newline vs submit behavior (requires product decision)
3. Visual design balance (refinement needed)

**Recommendation**: Proceed with implementation BUT prototype and test thoroughly before shipping. The scroll anchor issue is the biggest risk and should be addressed first. Consider whether the added complexity is worth the benefit of inline multi-line editing vs. the current simple single-line input.

The feature is **viable but not trivial** - it will require thoughtful UX work beyond just adding the technical capability.
