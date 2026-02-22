# Punchlist

A minimal iOS task list app. SwiftUI front-end that talks to a Go backend via REST + WebSocket.

## Architecture

- **SwiftUI / iOS 17+** — uses `@Observable`, no UIKit wrappers
- **No local persistence** — all state comes from the server via WebSocket push
- **Offline queue** — mutations buffer in memory during disconnects and replay on reconnect
- **Zero dependencies** — URLSession for HTTP, URLSessionWebSocketTask for WebSocket

## Building

Builds happen on a remote macOS host via SSH. See `just --list` for available recipes.

```bash
cp .env.example .env                 # fill in real values
just build                           # simulator build
just build-device                    # device build
just archive                         # archive for ad-hoc distribution
just distribute                      # push IPA to distribution server
```

## Development

```bash
nix develop          # enter dev shell
just check           # type-check Swift without full build
just build           # full simulator build
```

## Project Structure

```
Punchlist/
  PunchlistApp.swift         # App entry point
  Models/
    Item.swift               # Task item model
    Project.swift            # Project model
  Services/
    PunchlistAPI.swift       # REST API client
    WebSocketManager.swift   # WebSocket connection manager
  ViewModels/
    PunchlistViewModel.swift # Main view model
  Views/
    ContentView.swift        # Primary list view
    ItemRow.swift            # Individual item row
    InputBar.swift           # Bottom input bar
```
