warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
building file list ... done
PunchlistTests/
PunchlistTests/PunchlistTests.swift

sent 2,106 bytes  received 128 bytes  4,468.00 bytes/sec
total size is 470,614  speedup is 210.66
warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
Command line invocation:
    /Applications/Xcode-26.2.0.app/Contents/Developer/usr/bin/xcodebuild test -project Punchlist.xcodeproj -scheme PunchlistTests -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 17 Pro"

Build settings from command line:
    SDKROOT = iphonesimulator26.2

2026-02-26 09:55:54.872 xcodebuild[87858:3620091] -[XCConfigurationList name]: unrecognized selector sent to instance 0xb79ed9900
2026-02-26 09:55:54.873 xcodebuild[87858:3620091] Writing error result bundle to /var/folders/r3/8gbhgqt5489279nkhqjq3xl00000gn/T/ResultBundle_2026-26-02_09-55-0054.xcresult
xcodebuild: error: Unable to read project 'Punchlist.xcodeproj'.
	Reason: The project ‘Punchlist’ is damaged and cannot be opened. Examine the project file for invalid edits or unresolved source control conflicts.

Path: /Users/admin/Projects/punchlist/Punchlist.xcodeproj
Exception: -[XCConfigurationList name]: unrecognized selector sent to instance 0xb79ed9900


