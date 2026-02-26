# Fix Summary: Personal view completed tasks on cold start

## Issue
Completed tasks were hidden in personal view on cold start but appeared after toggling to another project and back.

## Root Cause
The `start()` method didn't load persisted UserDefaults state before initialization, while `switchToProject()` did. This created asymmetric behavior:

- **Cold start path**: Used default value `showCompletedFromSession = false` from property initialization
- **Toggle path**: Loaded `showCompletedFromSession` from UserDefaults before filtering

## Fix Applied
Added UserDefaults state loading in `start()` method (lines 60-64) to match the behavior of `switchToProject()` (lines 143-147):

```swift
// Load any persisted session state for the personal project
// This ensures cold start behavior matches the switchToProject() behavior
let timestamp = UserDefaults.standard.double(forKey: agentSessionKey)
agentSessionStartTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
showCompletedFromSession = UserDefaults.standard.bool(forKey: showCompletedSessionKey)
```

## Changes
- **File**: `Punchlist/ViewModels/PunchlistViewModel.swift`
- **Lines**: 60-64 (added 5 lines: 3 code + 2 comments)
- **Location**: In `start()` method, immediately after project initialization, before SSE connection

## Verification
- Type-checking passed via `just check`
- No compilation errors
- Fix mirrors existing pattern from `switchToProject()` method

## Expected Behavior
Completed tasks will now appear in personal view immediately on cold start, matching the behavior when toggling between projects.

## Risk Assessment
- **Low risk**: Minimal change, uses established pattern
- **Side effects**: `showCompletedFromSession` didSet will trigger on load (redundant UserDefaults write, but harmless)
- **Edge cases**: First launch will use default `false` value (correct behavior)
