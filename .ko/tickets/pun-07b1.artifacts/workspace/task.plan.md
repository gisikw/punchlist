The plan is complete. I've investigated the codebase and created a detailed implementation plan at `/home/dev/Projects/punchlist/.ko/tickets/pun-07b1.artifacts/plan.md`.

The key finding is that the hold bar currently always toggles items between open/closed, but for blocked tickets it should behave differently based on whether there are open questions. The implementation requires:

1. Adding conditional logic in the hold bar gesture handler
2. Creating new `onOpen` and `onClose` callbacks in `ItemRow` 
3. Adding dedicated `openItem()` and `closeItem()` methods to the view model
4. Wiring everything together in `ContentView`
5. Adding tests to verify the behavior

The plan is ready for your review.
