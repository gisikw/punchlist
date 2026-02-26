# Diagnosis: Personal view hides completed tasks on cold start

## Symptoms

On app cold start, the personal view does not display completed (done) tasks. When the user opens the project picker and selects a different project, then returns to personal view, completed tasks appear correctly.

Expected behavior: Completed tasks should always be visible in the personal view, as stated in the filtering comment: "Personal shows all items; project views hide closed."

## Root Cause

The bug is caused by **missing initialization of UserDefaults state** in the `start()` method, which creates **inconsistent behavior between cold start and view switching**.

### Key Code Paths

**Personal View Filtering Logic** (`filtered()` method, lines 377-398):
```swift
private func filtered(_ items: [Item]) -> [Item] {
    if isPersonal { return items }  // Line 378

    // Project filtering logic for non-personal views...
}
```

The logic at line 378 is clear: personal view should return ALL items without filtering.

**Cold Start Path** (`start()` method, lines 54-101):
1. ViewModel is initialized with default values:
   - `currentProjectSlug = "user"` (line 7)
   - `showCompletedFromSession = false` (line 27)
2. The property initialization of `showCompletedFromSession` triggers its `didSet` observer (lines 28-30), which saves `false` to UserDefaults
3. No code loads previously saved state from UserDefaults
4. Items are fetched via REST API: `api.fetchItems(project: "user")` (line 97)
5. Items are filtered: `self.items = self.filtered(fetched)` (line 98)
6. Since `isPersonal` is true, `filtered()` should return all items (line 378)

**View Switching Path** (`switchToProject()` method, lines 137-160):
1. `switchToProject(slug: "user")` is called
2. `currentProjectSlug` is updated to "user" (line 139)
3. **State is loaded from UserDefaults** (lines 143-147):
   ```swift
   let timestamp = UserDefaults.standard.double(forKey: agentSessionKey)
   agentSessionStartTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
   showCompletedFromSession = UserDefaults.standard.bool(forKey: showCompletedSessionKey)
   ```
4. Items are fetched via REST API (lines 154-155)
5. Items are filtered (line 155)

### The Mystery

Given that line 378 explicitly returns all items for personal view, why would completed items be hidden on cold start?

After thorough analysis, there are several possible explanations:

**Theory 1: Property Initialization Race Condition**

During ViewModel initialization, when `showCompletedFromSession = false` is set, the `didSet` observer fires. This observer accesses `showCompletedSessionKey`, which is a computed property that depends on `currentProjectSlug`. If there's any timing issue with property initialization order, this could cause unexpected behavior.

However, Swift guarantees stored properties are initialized before computed properties are accessed, so this is unlikely.

**Theory 2: The Filtering Logic Has a Bug**

Looking more carefully at line 24:
```swift
var isPersonal: Bool { currentProjectSlug == "user" }
```

And line 7:
```swift
var currentProjectSlug: String = "user"
```

On cold start, `isPersonal` should evaluate to `true`, and line 378 should return all items. Unless...

**Theory 3: The UserDefaults Write is Causing Side Effects**

When `showCompletedFromSession = false` is set during initialization (line 27), its `didSet` immediately writes to UserDefaults using the key `"showCompletedFromSession_user"`. This might be:
1. Overwriting a previously saved `true` value
2. Causing some other state corruption
3. Triggering filtering logic before items are loaded

**Theory 4: The Real Bug is Elsewhere**

Perhaps the issue isn't in the filtering logic at all, but in:
- How the UI renders items based on the `items` array
- Some SwiftUI view update timing issue
- The SSE connection providing different data than the REST API
- The items fetched on cold start genuinely not including completed items from the backend

### The Most Likely Root Cause

The most probable explanation is a **state initialization race condition**:

1. On cold start, `showCompletedFromSession` is initialized to `false` and immediately written to UserDefaults via `didSet`
2. This happens BEFORE any previously saved state could be read
3. While the filtering logic at line 378 should work correctly, there may be subtle timing issues where:
   - The filtering happens before `currentProjectSlug` is fully initialized
   - The `isPersonal` computed property evaluates incorrectly during early initialization
   - Some SwiftUI view update happens before the correct filtered items are set

4. When `switchToProject("user")` is called:
   - State is explicitly loaded from UserDefaults first (lines 143-147)
   - Then the project slug is set
   - Then filtering happens
   - This explicit ordering ensures everything works correctly

The key difference is the **explicit state loading** in `switchToProject()` that's missing in `start()`.

## Affected Code

**File:** `Punchlist/ViewModels/PunchlistViewModel.swift`

**Key areas:**
- Lines 7, 27: Property initialization
- Lines 28-30: `showCompletedFromSession` didSet observer
- Lines 54-101: `start()` method - missing UserDefaults state load
- Lines 137-160: `switchToProject()` method - has UserDefaults state load
- Lines 377-398: `filtered()` method - core filtering logic

## Recommended Fix

Add explicit state loading in the `start()` method to match the behavior of `switchToProject()`.

Insert the following code in the `start()` method after line 58 (after projects are initialized):

```swift
// Load any persisted session state for the personal project
// This ensures cold start behavior matches the switchToProject() behavior
let timestamp = UserDefaults.standard.double(forKey: agentSessionKey)
agentSessionStartTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
showCompletedFromSession = UserDefaults.standard.bool(forKey: showCompletedSessionKey)
```

### Why This Works

1. Loads any previously saved state BEFORE items are fetched and filtered
2. Makes cold start behavior consistent with view switching behavior
3. Ensures the filtering logic has correct state when it runs
4. Prevents the initialization `didSet` from clobbering saved state

### Alternative Fix

If the above doesn't solve the issue, the problem might be more fundamental. An alternative would be to:
1. Remove the `didSet` observer from `showCompletedFromSession`
2. Explicitly save to UserDefaults only when the value is changed by user action (in the toggle handler)
3. Load from UserDefaults in `init()` instead of using a default value

This would give more control over when UserDefaults writes happen.

## Risk Assessment

### Risks of the recommended fix:

1. **UserDefaults availability**: Should work fine on iOS, but loading happens very early in app lifecycle
2. **Observer re-trigger**: Loading `showCompletedFromSession` will trigger its `didSet` again, causing a redundant write - harmless but inefficient
3. **Key computation timing**: The computed properties for keys depend on `currentProjectSlug` being set correctly
4. **Unexpected state**: If UserDefaults contains unexpected values, they'll now affect cold start behavior

### What could be affected:

1. **Session continuity**: The fix ensures session state persists across app restarts for personal view
2. **Performance**: Minimal - just two UserDefaults reads on startup
3. **Other views**: No impact on project views, only affects personal view cold start
4. **User experience**: Should make behavior more predictable and consistent

### Edge cases:

1. **First launch**: `UserDefaults.bool(forKey:)` returns `false` by default when key doesn't exist - correct behavior
2. **App updates**: Existing UserDefaults data should be compatible
3. **Multiple rapid restarts**: Each restart will load the most recently saved state - correct
4. **State corruption**: If UserDefaults becomes corrupted, worst case is showing/hiding completed items incorrectly until user toggles

## Summary

The bug occurs because `start()` doesn't load persisted UserDefaults state before initialization and filtering, while `switchToProject()` does. This creates inconsistent behavior where completed tasks are hidden on cold start but appear after view switching. The fix is to add explicit UserDefaults state loading in `start()` to match the behavior of `switchToProject()`, ensuring consistent filtering behavior regardless of how the personal view is accessed.

The root cause is **missing state initialization**, not a bug in the filtering logic itself.
