## Summary

I've completed the diagnosis of the bug where completed tasks are hidden in personal view on cold start but appear after toggling projects.

**Root Cause:** Missing state initialization in the `start()` method. When the app launches, `showCompletedFromSession` is initialized to `false` and immediately written to UserDefaults via its `didSet` observer, potentially overwriting any saved state. Unlike `switchToProject()`, which explicitly loads state from UserDefaults (lines 143-147), the `start()` method doesn't load this state before using it.

**Key Finding:** While the `filtered()` method correctly returns all items for personal view at line 378 (`if isPersonal { return items }`), the asymmetry between cold start and view switching creates inconsistent behavior. The `switchToProject()` method loads persisted state first, then filters, while `start()` relies on property defaults without loading saved preferences.

**Recommended Fix:** Add UserDefaults state loading in `start()` after line 58, matching the pattern used in `switchToProject()`:
```swift
let timestamp = UserDefaults.standard.double(forKey: agentSessionKey)
agentSessionStartTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
showCompletedFromSession = UserDefaults.standard.bool(forKey: showCompletedSessionKey)
```

The full diagnosis with symptoms, root cause analysis, affected code, fix recommendations, and risk assessment has been written to `/home/dev/Projects/punchlist/.ko/tickets/pun-d645.artifacts/diagnosis.md`.
