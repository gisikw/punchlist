warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
building file list ... done

sent 1,202 bytes  received 24 bytes  2,452.00 bytes/sec
total size is 465,883  speedup is 380.00
warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels' does not exist, ignoring
Command line invocation:
    /Applications/Xcode-26.2.0.app/Contents/Developer/usr/bin/xcodebuild test -project Punchlist.xcodeproj -scheme PunchlistTests -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 17 Pro"

Build settings from command line:
    SDKROOT = iphonesimulator26.2

2026-02-26 09:51:56.875 xcodebuild[87813:3618972] -[XCConfigurationList name]: unrecognized selector sent to instance 0x8c58c4840
2026-02-26 09:51:56.876 xcodebuild[87813:3618972] Writing error result bundle to /var/folders/r3/8gbhgqt5489279nkhqjq3xl00000gn/T/ResultBundle_2026-26-02_09-51-0056.xcresult
xcodebuild: error: Unable to read project 'Punchlist.xcodeproj'.
	Reason: The project ‘Punchlist’ is damaged and cannot be opened. Examine the project file for invalid edits or unresolved source control conflicts.

Path: /Users/admin/Projects/punchlist/Punchlist.xcodeproj
Exception: -[XCConfigurationList name]: unrecognized selector sent to instance 0x8c58c4840


