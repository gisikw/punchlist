## Goal
Ensure the projects drawer never appears empty by adding retry logic and refreshing projects on app resume.

## Context
The projects drawer shows an empty list when the initial `api.fetchProjects()` call fails during app launch. This is an intermittent issue caused by transient network failures. The existing code uses `try?` which silently swallows errors, and the `refresh()` method never re-fetches projects on app resume.

Key files:
- `PunchlistViewModel.swift:51-58` — Initial project fetch with silent error handling
- `PunchlistViewModel.swift:73-83` — Refresh logic that only re-fetches items, not projects
- `ContentView.swift:66-89` — Project picker UI that iterates `viewModel.projects`
- `Project.swift` — Project model with JSON decoding

The app follows these conventions:
- No third-party dependencies (per INVARIANTS.md)
- Observable pattern with @Observable (iOS 17+)
- Fire-and-forget mutations with WebSocket confirmation
- No local database, server is source of truth

No test files exist in the codebase yet.

## Approach
Implement a two-pronged fix: (1) add retry logic with exponential backoff to the initial project fetch in `start()`, and (2) re-fetch projects in `refresh()` to recover from initial failures when the app resumes. Use a default "user" project as immediate fallback to ensure the UI is never empty. Keep retry delays short (0.5s, 1s, 2s) to avoid delaying app startup.

## Tasks
1. [Punchlist/ViewModels/PunchlistViewModel.swift:start] — Add immediate fallback to populate `projects` with default "user" project before async fetch, preventing empty state during network calls.
   Verify: App builds without errors.

2. [Punchlist/ViewModels/PunchlistViewModel.swift:start] — Replace silent `try?` with explicit error handling and retry logic (max 3 attempts, exponential backoff: 0.5s, 1s, 2s) for `api.fetchProjects()`.
   Verify: Projects load successfully on first try and recover after simulated network failure.

3. [Punchlist/ViewModels/PunchlistViewModel.swift:refresh] — Add project re-fetch at the start of `refresh()` method to recover from initial load failures when app returns to foreground.
   Verify: Projects re-fetch when app resumes from background.

4. Manual verification — Test with airplane mode: toggle airplane mode on during app launch, then toggle off. Confirm projects drawer populates after network recovers.
   Verify: Projects appear in drawer after connectivity is restored.

## Open Questions
None — the diagnosis document provides clear analysis and the fix is straightforward. The default "user" project is guaranteed to exist based on the codebase (used as the personal list). No architectural changes needed, just adding resilience to existing fetch logic.
