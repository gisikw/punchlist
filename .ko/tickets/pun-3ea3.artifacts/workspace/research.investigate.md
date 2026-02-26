## Investigation Complete

I've found the source of the pulsing effect on blocked tickets. Here's what's happening:

### The Root Cause

The pulse animation is **only intended for in-progress items**, but there's a subtle state management issue in `Punchlist/Views/ItemRow.swift`.

**The key mismatch:**
- `hasPulse` (line 37-39) correctly limits pulsing to `in_progress` items only
- `hasActiveStatus` (line 41-43) applies special border/shadow styling to **both** `in_progress` AND `blocked` items

**Why recently blocked items pulse:**
When a ticket transitions from `in_progress` → `blocked`, the `pulseActive` state variable may briefly remain `true` until the view re-renders and the `onChange` handler fires (lines 102-110). This creates a transient window where blocked items show the pulsing border/shadow effect.

### The Fix

The simplest fix is to add an explicit state reset when items become blocked, or to strengthen the pulse checks in the border/shadow opacity calculations to use `hasPulse && pulseActive` instead of just checking them separately.

I've documented three potential solutions in `findings.md`:
1. Strengthen the pulse checks (recommended)
2. Force pulse state reset on status change  
3. Make it intentional if you actually want blocked items to pulse

The full analysis with code references and recommended fixes is in `.ko/tickets/pun-3ea3.artifacts/findings.md`.
