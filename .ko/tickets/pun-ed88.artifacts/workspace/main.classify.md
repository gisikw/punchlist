Looking at this ticket, I need to classify the type of work required.

## Analysis

The ticket describes a **decommissioning task** with specific, concrete steps:
1. Stop and disable a systemd unit
2. Archive or delete a repository
3. Update DNS/reverse proxy configuration
4. Update documentation

These are declarative instructions for what to **build/change**, not questions about whether something is broken or whether an approach is feasible. The ticket asserts that "punchlist-server is dead code" and lists the actions needed to remove it.

This is clearly a **task** - the expected output is configuration changes, cleanup actions, and documentation updates.

```json
{"disposition": "route", "workflow": "task"}
```
