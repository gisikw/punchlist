warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
building file list ... done
Punchlist/Services/
Punchlist/Services/SSEManager.swift
Punchlist/ViewModels/
Punchlist/ViewModels/PunchlistViewModel.swift
PunchlistTests/
PunchlistTests/PollingFallbackTests.swift

sent 3,914 bytes  received 358 bytes  8,544.00 bytes/sec
total size is 476,572  speedup is 111.56
warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
Command line invocation:
    /Applications/Xcode-26.2.0.app/Contents/Developer/usr/bin/xcodebuild test -project Punchlist.xcodeproj -scheme PunchlistTests -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 17 Pro"

Build settings from command line:
    SDKROOT = iphonesimulator26.2

2026-02-26 10:03:24.667 xcodebuild[88023:3622454] -[XCConfigurationList name]: unrecognized selector sent to instance 0x9938a8940
2026-02-26 10:03:24.668 xcodebuild[88023:3622454] Writing error result bundle to /var/folders/r3/8gbhgqt5489279nkhqjq3xl00000gn/T/ResultBundle_2026-26-02_10-03-0024.xcresult
xcodebuild: error: Unable to read project 'Punchlist.xcodeproj'.
	Reason: The project ‘Punchlist’ is damaged and cannot be opened. Examine the project file for invalid edits or unresolved source control conflicts.

Path: /Users/admin/Projects/punchlist/Punchlist.xcodeproj
Exception: -[XCConfigurationList name]: unrecognized selector sent to instance 0x9938a8940


