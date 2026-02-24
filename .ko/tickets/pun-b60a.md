---
id: pun-b60a
status: closed
deps: []
created: 2026-02-24T20:17:54Z
type: task
priority: 2
---
# Fix project-mode tap targets per Kevin's screenshots

## Notes

**2026-02-24:** Screenshot reference: `notes/attachments/2026-02-24_20-20-12_IMG_2426.jpeg`

Project-mode tap zones for undone, expanded card:
- **Yellow (body/left ~80%):** expand tap zone. On already-expanded card this is a no-op, but should be consistent across all cards.
- **Blue (right strip, ~20% where chevron lives):** bump (increase priority).
- **Pink (hold-to-close bar at bottom of expanded area):** hold to complete/close the ticket.

**Both modes use the same tap zone split:**
- **Left ~80%:** primary action (toggle done/undone in personal, expand in project)
- **Right ~20% (chevron area):** bump

**Project mode additionally** (`notes/attachments/2026-02-24_20-20-12_IMG_2426.jpeg`):
- **Hold-to-close bar at bottom of expanded area:** hold to complete/close

Current code already has the 80/20 split, but needs review to ensure:
1. Expand zone covers full card body (not just header) for collapsed project cards
2. The hold-to-close bar receives gestures properly (not blocked by overlays)
