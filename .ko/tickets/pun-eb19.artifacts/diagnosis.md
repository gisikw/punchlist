# Diagnosis: Ticket Disappears After Creation in Project View

## Symptoms

When creating a new ticket in a non-personal project (e.g., `#projectname`):
1. Ticket appears immediately in the list after creation
2. A few seconds later, the ticket disappears from the view
3. Switching projects or closing/reopening the app makes the ticket reappear

**Key observation**: This only happens in project views, not in the personal (`user`) view.

## Root Cause

**Race condition between optimistic UI update and SSE stream filtering logic.**

The bug involves the interaction between three systems:

### 1. Optimistic UI (lines 153-175 in PunchlistViewModel.swift)
When `addItem()` is called while connected to SSE:
- The function calls `api.addItem()` asynchronously via `Task { await action() }`
- **No optimistic local update is made** when `isConnected` is true (line 162-163)
- The UI relies entirely on the SSE stream to reflect the new item

### 2. SSE Stream Updates (lines 52-58 in PunchlistViewModel.swift)
When SSE receives an update:
- Calls `self.items = self.filtered(items)` (line 54)
- The `filtered()` function is applied to ALL items from the SSE stream

### 3. Filtering Logic (lines 365-386 in PunchlistViewModel.swift)
```swift
private func filtered(_ items: [Item]) -> [Item] {
    if isPersonal { return items }  // Personal view shows all items

    return items.filter { item in
        if !item.done { return true }  // Show all open items

        // For closed items, only show if from current session
        guard showCompletedFromSession,
              let sessionStart = agentSessionStartTime,
              let modifiedString = item.modified else {
            return false  // Hide closed items by default
        }

        // Parse timestamp and compare
        // ...
    }
}
```

**The bug**: When a new ticket is created via SSE:
1. The API receives the creation request
2. SSE broadcasts the new ticket immediately (ticket appears)
3. A few seconds later, SSE sends another update (possibly a full state refresh or a status update)
4. The `filtered()` function processes this update
5. **If the ticket has `done: true` or `status: "closed"`**, it gets filtered out because:
   - `item.done` is true (line 369 check fails)
   - `showCompletedFromSession` is likely false or not set
   - The ticket doesn't pass the closed-item visibility check

**Alternative scenario**: The newly created ticket might not have a `modified` timestamp initially, or it's created with a status that gets changed shortly after, causing it to be filtered out unexpectedly.

## Affected Code

**Primary file**: `Punchlist/ViewModels/PunchlistViewModel.swift`

### Key functions:
1. **`addItem(text:)`** (lines 153-175)
   - Does NOT create optimistic UI when connected
   - Relies on SSE echo for confirmation

2. **`filtered(_:)`** (lines 365-386)
   - Filters out closed items in project views
   - Only shows closed items if they're from the current agent session

3. **SSE callback** (lines 52-58)
   - Applies filtering to all SSE updates
   - No distinction between "echo of my action" vs "other updates"

### Related files:
- `Punchlist/Services/SSEManager.swift` (lines 98-110): Handles SSE item updates
- `Punchlist/Models/Item.swift` (lines 21-33): Item decoding, `done` derived from `status == "closed"`

## Recommended Fix

**Option 1: Optimistic UI for Connected State (Recommended)**

Add optimistic UI updates even when connected, similar to the offline behavior:

```swift
func addItem(text: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    let slug = currentProjectSlug

    // Create temporary optimistic item
    let temp = Item(
        id: "temp-\(UUID().uuidString)",  // Temporary ID
        text: trimmed,
        done: false,
        created: ISO8601DateFormatter().string(from: Date())
    )
    items.insert(temp, at: 0)

    // Send to API
    Task { [api] in
        try? await api.addItem(project: slug, title: trimmed)
        // SSE will provide the authoritative update with real ID
    }

    afterAction()
}
```

**Advantages**:
- Immediate UI feedback regardless of connection state
- Consistent behavior between online/offline modes
- SSE update will replace the temporary item with the real one

**Option 2: Track Pending Operations**

Maintain a set of pending operation IDs and exempt them from filtering temporarily:

```swift
private var pendingCreations: Set<String> = []

func addItem(text: String) {
    // ... existing code ...
    let tempId = "pending-\(Date().timeIntervalSince1970)"
    pendingCreations.insert(tempId)

    Task {
        let realId = try? await api.addItem(project: slug, title: trimmed)
        // Remove from pending after a delay
        Task {
            try? await Task.sleep(for: .seconds(5))
            pendingCreations.remove(tempId)
        }
    }
}

private func filtered(_ items: [Item]) -> [Item] {
    // Exempt items in pendingCreations from filtering
    // ...
}
```

**Option 3: Fix Filtering Logic**

Modify the filtering to be more lenient for recently created items:

```swift
private func filtered(_ items: [Item]) -> [Item] {
    if isPersonal { return items }

    return items.filter { item in
        if !item.done { return true }

        // Show recently created items (within last 10 seconds)
        let formatter = ISO8601DateFormatter()
        if let createdDate = formatter.date(from: item.created),
           Date().timeIntervalSince(createdDate) < 10 {
            return true
        }

        // Existing logic for session-based filtering...
    }
}
```

## Risk Assessment

### Option 1 Risks (Optimistic UI - RECOMMENDED):
- **Low risk**: Follows existing offline pattern
- **Potential issue**: Duplicate items briefly visible (optimistic + SSE)
  - Mitigation: Deduplicate by ID in SSE callback, remove temp IDs
- **Potential issue**: Temporary ID might persist if SSE never confirms
  - Mitigation: Add timeout to remove unconfirmed temp items after 10s

### Option 2 Risks (Track Pending):
- **Medium complexity**: Requires careful state management
- **Potential issue**: Memory leaks if pending set isn't cleaned up
- **Potential issue**: Doesn't solve the root cause if filtering is the actual problem

### Option 3 Risks (Time-based filtering):
- **Low risk for creation**: Recently created items always show
- **Potential issue**: Clock skew between client and server
- **Potential issue**: Might show items that should be filtered for other reasons

### Side Effects to Consider:
1. **SSE update handling**: Need to deduplicate optimistic items when real item arrives
2. **Item identity**: SwiftUI's `ForEach(id:)` uses item.id - temporary IDs must be unique
3. **Filtering edge cases**: Items might transition between filtered/visible states during the window
4. **Performance**: Adding/removing items from the list rapidly could cause UI jank

### What Else Might Be Affected:
- `toggleItem()`, `bumpItem()`, `deleteItem()` - should use same optimistic pattern for consistency
- Item animations - optimistic items should animate in/out smoothly
- Offline queue - ensure optimistic items don't get queued when online
- SSE reconnection - optimistic items should be cleared on reconnect if not confirmed

## Additional Investigation Needed

To confirm the exact trigger, we'd need to:
1. **Add logging** to track when items are filtered out and why
2. **Inspect SSE stream** to see what the server sends after ticket creation
3. **Check ko server behavior** - does it send multiple events for one creation?
4. **Verify item status** - are newly created items marked as `done: true` or `status: "closed"` initially?

However, the optimistic UI fix (Option 1) should resolve the user-visible issue regardless of the exact server behavior.
