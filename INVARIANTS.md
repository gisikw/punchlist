# Invariants

Explicit contracts for Punchlist iOS. If a convention matters, it's here.

## Architecture

- **API client only** — no local data persistence. The Go backend is the
  single source of truth. Base URL is configured via environment/build settings.
- **SSE for state** — the server pushes the full item array via Server-Sent
  Events on connect and on every mutation. The client replaces its entire
  model on each event. No diffing, no merge logic.
- **Mutations fire immediately** — all API calls (add, toggle, open, close,
  bump, delete) fire via `Task{}` regardless of SSE connection state. When
  SSE is disconnected, the UI also applies optimistic local state for
  immediate visual feedback. There is no offline queue; mutations are not
  deferred until reconnect.
- **No local database** — no CoreData, no SwiftData, no SQLite. Items live
  in memory and come from the server.

## UI

- **List is reversed** — most recent / active items appear at the bottom,
  near the input. This is `column-reverse` in CSS; in SwiftUI it means the
  ScrollView anchors to the bottom.
- **Three interactions per item**: tap to toggle done, bump arrow to move to
  bottom (near input), and swipe-to-delete (native gesture, maps to DELETE
  endpoint).
- **Bump arrow hidden on done items** — done items don't get bumped.
- **Done items**: strikethrough text, gray color, green filled circle with
  checkmark. Undone items: empty circle with border.
- **Input bar fixed at bottom** — always visible, not part of the scroll.
- **No modals, no toasts, no confirmations** — mutations are instant and
  silent. The SSE echo confirms success.
- **Color palette matches web client**: background `#FAFAFA`, text `#2D2A2E`,
  secondary `#939293`, done green `#A9DC76`, focus blue `#78DCE8`.

## Code

- **SwiftUI only** — no UIKit wrappers unless absolutely forced by a
  platform gap.
- **iOS 17+** — use `@Observable`, not `ObservableObject`/`@Published`.
- **One model file, one API file, one SSE file, one view model, three
  views.** If a file exceeds ~300 lines, split along behavioral seams.
- **No third-party dependencies.** URLSession for HTTP, URLSession delegate
  for SSE streaming. No Alamofire, no Starscream, no SwiftPM packages.
- **No generics for one-off types.** The item model is concrete.

## Data Model

```swift
struct Item: Codable, Identifiable {
    let id: String       // UnixNano string from server
    var text: String
    var done: Bool
    let created: String  // RFC3339
}
```

The server assigns IDs (UnixNano). The client never generates real IDs —
optimistic offline items use temporary IDs that get replaced on sync.

## Network

- **Reconnect with exponential backoff** — 1s initial, doubles to 30s cap.
  Reset on successful connect.
- **Offline indicator** — shown after 1.5s of disconnect (not immediately, to
  avoid flicker on brief interruptions).
- **All mutations are fire-and-forget** — POST to `/ko` endpoint, don't wait
  for response. The SSE event echo is the confirmation.

## Build

- **Cross-machine build** — source is edited on the dev sandbox and rsynced
  to a macOS build host via SSH. Xcode builds happen on the build host.
  Credentials are in `.env` (gitignored).
- **No CI/CD yet** — manual builds. If this changes, document it here.

## Policy

- Decisions that shape code are explicit, not implicit.
- No implicit patterns — if a convention matters, it's in this file.
- When in doubt, match the behavior of the existing web client.
