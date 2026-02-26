The plan is complete. I've identified that:

1. The agent toggle is currently shown unconditionally for non-personal projects (when certain other conditions are met)
2. We need to add a check for "unblocked tickets" - items that are not done and not blocked
3. The implementation requires:
   - Adding a computed property to check for unblocked tickets in the view model
   - Updating the conditional logic in the view to use this property

The plan is proportional to the scope of the change - it's a small feature that requires touching two files with minimal code changes.
