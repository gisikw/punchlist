# Diagnosis: Empty Projects Drawer

## Symptoms

When opening the projects drawer (by tapping the project tag in the header), the list occasionally appears empty despite having multiple projects configured on the server. This is an intermittent issue that has happened "once or twice."

## Root Cause

The projects list becomes empty when the initial API call to fetch projects fails. There are three specific scenarios that lead to this:

### 1. **Silent Failure on Initial Load** (Primary Issue)
**Location**: `PunchlistViewModel.swift:51-58`

```swift
Task {
    if let fetched = try? await api.fetchProjects() {
        self.projects = fetched.sorted { ... }
    }
    // ... rest of code
}
```

The `try?` operator converts any thrown error into `nil`, and the `if let` unwrapping silently ignores the failure. If `api.fetchProjects()` throws an error, `self.projects` remains at its initialized empty state (`[]`).

**Possible failure scenarios:**
- Network timeout during initial app launch
- Server returning 4xx/5xx status code
- JSON decoding failure (malformed response, unexpected schema)
- DNS resolution failure
- Certificate validation issues (if HTTPS is misconfigured)

### 2. **Projects Never Re-fetched on App Resume**
**Location**: `PunchlistViewModel.swift:73-83`

When the app returns to the foreground, `refresh()` is called, but it only re-fetches items for the current project:

```swift
func refresh() {
    startDate = Date()
    sse.reconnect()
    let slug = currentProjectSlug
    Task {
        if let fetched = try? await api.fetchItems(project: slug) {
            self.items = self.filtered(fetched)
        }
    }
    refreshAgentStatus()
}
```

**Missing**: `api.fetchProjects()` call. If projects failed to load initially, they will never be retried on subsequent app resumes.

### 3. **JSON Decoding Vulnerability**
**Location**: `Project.swift:15-20`

The `Project` model expects specific JSON keys:
- `tag` (mapped to `slug`)
- `is_default` (optional, mapped to `isDefault`)

But the initializer doesn't have a `name` mapping in `CodingKeys`, yet requires `name` to be set (line 18: `name = slug`). If the server response structure changes or includes unexpected data, decoding could fail silently.

## Affected Code

### Primary Files:
- **`Punchlist/ViewModels/PunchlistViewModel.swift:51-58`** - Initial project fetch with silent error handling
- **`Punchlist/ViewModels/PunchlistViewModel.swift:73-83`** - Refresh logic that doesn't re-fetch projects
- **`Punchlist/Services/KoAPI.swift:12-15`** - Project fetch implementation
- **`Punchlist/Models/Project.swift:15-20`** - JSON decoding logic

### Impacted UI:
- **`Punchlist/Views/ContentView.swift:66-89`** - Project picker that iterates over `viewModel.projects`

## Recommended Fix

### Fix 1: Retry Logic for Project Fetch (High Priority)
Add retry logic with exponential backoff in `start()`. If the initial fetch fails, retry 2-3 times before giving up:

```swift
Task {
    var retries = 0
    while retries < 3 {
        do {
            let fetched = try await api.fetchProjects()
            self.projects = fetched.sorted { a, b in
                if a.slug == "user" { return true }
                if b.slug == "user" { return false }
                return a.slug < b.slug
            }
            break  // Success, exit retry loop
        } catch {
            retries += 1
            if retries < 3 {
                try? await Task.sleep(for: .seconds(Double(retries)))
            }
        }
    }
}
```

### Fix 2: Re-fetch Projects on Refresh (Medium Priority)
Add a project re-fetch to the `refresh()` method:

```swift
func refresh() {
    startDate = Date()
    sse.reconnect()

    // Re-fetch projects in case initial load failed
    Task {
        if let fetched = try? await api.fetchProjects() {
            self.projects = fetched.sorted { /* ... */ }
        }
    }

    let slug = currentProjectSlug
    Task {
        if let fetched = try? await api.fetchItems(project: slug) {
            self.items = self.filtered(fetched)
        }
    }
    refreshAgentStatus()
}
```

### Fix 3: Fallback to "personal" Project (Low Priority)
Ensure there's always at least one project available (the "user" project):

```swift
func start() {
    // Immediately set default project so UI is never empty
    self.projects = [Project(slug: "user", isDefault: true)]

    // ... existing code ...

    Task {
        if let fetched = try? await api.fetchProjects() {
            self.projects = fetched.sorted { /* ... */ }
        }
        // If fetch fails, keep the default "user" project
    }
}
```

### Fix 4: Error Logging (Low Priority)
Replace `try?` with explicit error handling to make debugging easier:

```swift
Task {
    do {
        let fetched = try await api.fetchProjects()
        self.projects = fetched.sorted { /* ... */ }
    } catch {
        // Log error to debug console or debug log
        print("Failed to fetch projects: \(error)")
        // Keep existing projects (or default to user)
    }
}
```

## Risk Assessment

### Risks of Making the Fix:

1. **Retry Logic Risk**:
   - Could delay app startup by ~6 seconds in worst case (3 retries with exponential backoff)
   - Mitigation: Use shorter timeouts (0.5s, 1s, 2s) to keep total delay under 4s

2. **Refresh Logic Risk**:
   - Adds extra network request on every foreground resume
   - Could cause unnecessary traffic if projects rarely change
   - Mitigation: Cache with TTL or only re-fetch if projects list is empty

3. **Fallback Risk**:
   - If "user" project doesn't exist on server, could cause confusion
   - Mitigation: Verify "user" project always exists in the API

4. **Error Logging Risk**:
   - No real risk, just additional console output during development

### What Else Might Be Affected:

- **SSE Connection**: Projects are fetched independently of SSE connection, but if network is completely unavailable, both will fail
- **Project Switching**: If `switchToProject()` is called before projects are loaded, `currentProject` will be `nil` (already handled gracefully in UI)
- **Agent Toggle**: Agent toggle visibility depends on `currentProject != nil`, which could hide the toggle if projects fail to load

### Race Condition Note:

The current code has a subtle race between the SSE connection and project fetch (both start in parallel). If projects load after SSE connects and delivers items, the UI should still work correctly since they're independent state variables.

## Conclusion

The empty projects drawer is caused by **silent failure of the initial project fetch** combined with **no retry mechanism**. The most likely trigger is a transient network issue during app launch. The recommended fix is to add retry logic (Fix 1) and ensure projects are re-fetched on app resume (Fix 2). Adding a fallback default project (Fix 3) would provide additional UX resilience.
