# Summary: Fix for Personal View Completed Tasks on Cold Start

## What Was Done

Fixed a race condition causing completed tasks to be hidden in personal view on cold start but visible after toggling projects.

**Root Cause**: On cold start, the REST API fetch would load all items (including completed tasks), but the SSE (Server-Sent Events) connection's initial state callback would fire shortly after and overwrite the items array, sometimes with incomplete data. When toggling projects, the timing was different (SSE reconnection took longer), so the REST data was preserved.

**Solution**: Implemented a two-flag system to prevent SSE from overwriting REST data on initial load:
- `hasInitialLoad`: Tracks when REST fetch completes
- `hasHandledInitialSSE`: Tracks when we've skipped the first SSE callback after REST completes

The SSE callback now checks these flags and skips the first callback that arrives after REST completes, preserving the complete data while allowing all subsequent SSE updates through for real-time functionality.

## Changes Made

**File Modified**: `Punchlist/ViewModels/PunchlistViewModel.swift`

1. Added two boolean flags (lines 45-46) to track load state
2. Modified SSE callback (lines 68-81) to conditionally skip first update after REST completes
3. Set `hasInitialLoad = true` after REST fetch in `start()` (line 114) and `switchToProject()` (line 176)
4. Reset both flags when switching projects (lines 159-160) so protection applies to new project

Total impact: ~15 lines of new code

## Notable Decisions

**Two flags instead of one**: The implementation added `hasHandledInitialSSE` beyond the plan's single `hasInitialLoad` flag. This provides more precise state tracking and prevents edge cases where multiple SSE callbacks might arrive in quick succession. This is an improvement over the original plan.

**Symmetric handling**: The same protection is applied in both `start()` (cold start) and `switchToProject()` (view switching), ensuring consistent behavior across all scenarios.

## Behavior After Fix

- ✅ **Cold start**: Completed tasks visible immediately in personal view
- ✅ **Project toggling**: Completed tasks remain visible after switching to/from projects
- ✅ **Real-time updates**: All SSE updates after initial load are applied normally
- ✅ **Preserved functionality**: No impact on existing features or real-time synchronization

## Testing Notes

Per INVARIANTS.md, this project uses a cross-machine build system (source edited on dev sandbox, built on macOS host via Xcode). No automated tests exist. Manual testing plan:

1. Cold start app to personal view → verify completed tasks visible
2. Toggle to project and back → verify completed tasks still visible
3. Add/complete/bump items from another client → verify real-time updates work
4. Switch between multiple projects → verify behavior consistent

## For Future Readers

This fix addresses a timing-dependent race condition between two data sources (REST and SSE). The key insight is that SSE provides real-time updates but its initial state snapshot may be incomplete, while REST provides a complete initial load. The solution preserves REST data on initial load while still allowing SSE to function for real-time updates afterward.

If similar timing issues arise with other views or data sources, consider applying this same pattern: track when the authoritative data source completes, then skip the first update from the real-time source if it arrives after.
