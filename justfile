project := "Punchlist.xcodeproj"
scheme := "Punchlist"
remote_dir := "~/Projects/punchlist"
simulator := "iPhone 17 Pro"

# Load credentials from .deploy-credentials
export BUILD_HOST := `grep BUILD_HOST .deploy-credentials | cut -d= -f2`
export BUILD_USER := `grep BUILD_USER .deploy-credentials | cut -d= -f2`
export BUILD_PASS := `grep BUILD_PASS .deploy-credentials | cut -d= -f2`

# Sync source to obrien
sync:
    #!/usr/bin/env bash
    nix-shell -p sshpass rsync --run "sshpass -p '$BUILD_PASS' rsync -avz --exclude='.git' --exclude='.tickets' --exclude='.deploy-credentials' . $BUILD_USER@$BUILD_HOST:{{remote_dir}}/"

# Build for iOS simulator
build: sync
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && xcodebuild -project {{project}} -scheme {{scheme}} -sdk iphonesimulator -destination \"platform=iOS Simulator,name={{simulator}}\" build 2>&1 | tail -20'"

# Build for device (release)
build-device: sync
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && xcodebuild -project {{project}} -scheme {{scheme}} -sdk iphoneos -configuration Release build 2>&1 | tail -20'"

# Clean build artifacts on obrien
clean:
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && xcodebuild -project {{project}} -scheme {{scheme}} clean 2>&1'"

# Type-check Swift files without full build
check: sync
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && swiftc -typecheck -sdk \$(xcrun --sdk iphonesimulator --show-sdk-path) -target arm64-apple-ios17.0-simulator Punchlist/Models/Item.swift Punchlist/Services/PunchlistAPI.swift Punchlist/Services/WebSocketManager.swift Punchlist/ViewModels/PunchlistViewModel.swift Punchlist/Views/ItemRow.swift Punchlist/Views/InputBar.swift Punchlist/Views/ContentView.swift Punchlist/PunchlistApp.swift 2>&1'"
