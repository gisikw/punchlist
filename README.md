# Punchlist

<p align="center">
  <img src="assets/icon-ocean.svg" width="128" height="128" alt="Punchlist app icon — a pink boxing glove on an ocean blue gradient" />
</p>

<p align="center">
  <em>A task list that stays out of your way.</em>
</p>

---

Most task apps want to be project management software when they grow up. Punchlist doesn't. It's a personal to-do list — fast, opinionated, and intentionally small.

The key insight: **your next action belongs at the bottom of the list, not the top.** Traditional task lists put your most important item as far from your thumb as possible, then ask you to scroll past everything you're avoiding. Punchlist builds from the bottom up. The thing you need to do next is always right there, close at hand.

**Tap an item to finish it.** It gets a checkmark, turns green, and floats to the top of the list — as far away from you as it can get. Done means done; it's out of your way but still visible if you want to see what you've accomplished.

**Pull an item down to make it next.** No drag-and-drop reordering, no priority matrices, no due dates. If something needs to happen next, pull it to the bottom. That's it. One gesture, zero decisions.

**Add from the bottom.** The input bar lives where your thumbs already are. Type, tap done, keep moving. New items land right where they belong — at the front of the queue.

<p align="center">
  <img src="assets/screenshot.png" width="300" alt="Punchlist screenshot — a simple task list with completed items at the top and the input bar at the bottom" />
</p>

## Why it works

Punchlist is built on a few deliberate constraints:

- **No local database.** State lives on a server and syncs over WebSocket. Your list is always current, never stale.
- **No offline anxiety.** If you lose connection, mutations queue up in memory and replay when you're back. You never notice.
- **No dependencies.** Zero third-party libraries. URLSession for HTTP, URLSessionWebSocketTask for WebSocket. That's the whole networking stack.
- **No reordering UI.** You can finish things and you can pick what's next. That's the entire interaction model. Fewer choices means less friction.

## Building

Punchlist is a SwiftUI app targeting iOS 17+. Builds happen on a remote macOS host via SSH.

```bash
cp .env.example .env          # fill in real values
just build                    # simulator build
just build-device             # device build
just distribute               # archive + push IPA for ad-hoc distribution
```

## Development

```bash
nix develop                   # enter dev shell
just check                    # type-check Swift without full build
just build                    # full simulator build
```
