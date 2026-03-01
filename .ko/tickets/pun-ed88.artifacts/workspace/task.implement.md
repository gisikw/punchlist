Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
No punchlist units found on ratched. The service is gone.

**Summary**

The plan had one remaining task: verify the punchlist systemd service is no longer running on ratched.

**Task 1 — Verify punchlist service is inactive on ratched**
- Ran `fort ratched systemd '{"action":"list"}'` and filtered for "punchlist" — no results.
- The NixOS gitops deployment (removing `apps/punchlist/default.nix`) has been applied and the service no longer exists on ratched.

All work for this ticket is complete. No deviations from the plan.
