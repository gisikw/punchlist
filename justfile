project := "Punchlist.xcodeproj"
scheme := "Punchlist"
app_name := "Punchlist"
remote_dir := "~/Projects/punchlist"
simulator := "iPhone 17 Pro"
archive_path := "~/Punchlist.xcarchive"
export_path := "~/PunchlistExport"
dist_dir := "/var/lib/apple-dist/ipas"
dist_url := "https://DIST_HOST_REDACTED/ipas"

# Load credentials from .deploy-credentials
export BUILD_HOST := `grep BUILD_HOST .deploy-credentials | cut -d= -f2`
export BUILD_USER := `grep BUILD_USER .deploy-credentials | cut -d= -f2`
export BUILD_PASS := `grep BUILD_PASS .deploy-credentials | cut -d= -f2`
export TEAM_ID := `grep TEAM_ID .deploy-credentials | cut -d= -f2`
export BUNDLE_ID := `grep BUNDLE_ID .deploy-credentials | cut -d= -f2`

_ssh cmd:
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST '{{cmd}}'"

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

# Archive for ad-hoc distribution
archive: sync
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && \
       rm -rf {{archive_path}} {{export_path}} && \
       xcodebuild archive \
         -project {{project}} \
         -scheme {{scheme}} \
         -sdk iphoneos \
         -configuration Release \
         -archivePath {{archive_path}} \
         DEVELOPMENT_TEAM=$TEAM_ID \
         CODE_SIGN_IDENTITY=\"Apple Distribution\" \
         2>&1 | tail -20 && \
       cat > /tmp/ExportOptions.plist <<PLIST
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
  <key>method</key>
  <string>ad-hoc</string>
  <key>teamID</key>
  <string>$TEAM_ID</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>thinning</key>
  <string>&lt;none&gt;</string>
</dict>
</plist>
PLIST
       xcodebuild -exportArchive \
         -archivePath {{archive_path}} \
         -exportOptionsPlist /tmp/ExportOptions.plist \
         -exportPath {{export_path}} \
         2>&1 | tail -20'"

# Distribute IPA to DIST_HOST_REDACTED
distribute: archive
    #!/usr/bin/env bash
    set -euo pipefail

    # Pull IPA from obrien to local temp
    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' scp -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST:{{export_path}}/{{app_name}}.ipa $TMPDIR/{{app_name}}.ipa"

    # Generate manifest plist
    cat > "$TMPDIR/{{app_name}}.plist" <<PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>items</key>
      <array>
        <dict>
          <key>assets</key>
          <array>
            <dict>
              <key>kind</key>
              <string>software-package</string>
              <key>url</key>
              <string>{{dist_url}}/{{app_name}}.ipa</string>
            </dict>
          </array>
          <key>metadata</key>
          <dict>
            <key>bundle-identifier</key>
            <string>$BUNDLE_ID</string>
            <key>bundle-version</key>
            <string>1.0</string>
            <key>kind</key>
            <string>software</string>
            <key>title</key>
            <string>{{app_name}}</string>
          </dict>
        </dict>
      </array>
    </dict>
    </plist>
    PLIST

    # Copy to distribution directory
    sudo cp "$TMPDIR/{{app_name}}.ipa" {{dist_dir}}/{{app_name}}.ipa
    sudo cp "$TMPDIR/{{app_name}}.plist" {{dist_dir}}/{{app_name}}.plist
    sudo chmod 644 {{dist_dir}}/{{app_name}}.ipa {{dist_dir}}/{{app_name}}.plist

    echo ""
    echo "Distributed! Install from:"
    echo "  https://DIST_HOST_REDACTED"

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
