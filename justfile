set dotenv-load

project := "Punchlist.xcodeproj"
scheme := "Punchlist"
app_name := "Punchlist"
remote_dir := "~/Projects/punchlist"
simulator := "iPhone 17 Pro"
archive_path := "~/Punchlist.xcarchive"
export_path := "~/PunchlistExport"

# List available recipes
default:
    @just --list

# Run the test suite
test: sync
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && xcodebuild test -project {{project}} -scheme PunchlistTests -sdk iphonesimulator -destination \"platform=iOS Simulator,name={{simulator}}\" 2>&1 | tail -50'"

# Sync source to build host
sync:
    #!/usr/bin/env bash
    nix-shell -p sshpass rsync --run "sshpass -p '$BUILD_PASS' rsync -avz --exclude='.git' --exclude='.tickets' --exclude='.env' --exclude='.ko' . $BUILD_USER@$BUILD_HOST:{{remote_dir}}/"

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
    set -euo pipefail

    # Generate ExportOptions.plist locally, then push to build host
    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT
    cat > "$TMPDIR/ExportOptions.plist" <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>method</key>
      <string>ad-hoc</string>
      <key>teamID</key>
      <string>$TEAM_ID</string>
      <key>signingStyle</key>
      <string>manual</string>
      <key>provisioningProfiles</key>
      <dict>
        <key>$BUNDLE_ID</key>
        <string>Punchlist Ad Hoc</string>
      </dict>
      <key>signingCertificate</key>
      <string>Apple Distribution</string>
      <key>stripSwiftSymbols</key>
      <true/>
      <key>thinning</key>
      <string>&lt;none&gt;</string>
    </dict>
    </plist>
    EOF

    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' scp -o StrictHostKeyChecking=no -o PreferredAuthentications=password $TMPDIR/ExportOptions.plist $BUILD_USER@$BUILD_HOST:/tmp/ExportOptions.plist"

    echo "=== Archiving ==="
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && rm -rf {{archive_path}} {{export_path}} && \
       security unlock-keychain -p build ~/Library/Keychains/build.keychain-db && \
       xcodebuild archive \
         -project {{project}} \
         -scheme {{scheme}} \
         -sdk iphoneos \
         -configuration Release \
         -archivePath {{archive_path}} \
         CODE_SIGN_STYLE=Manual \
         DEVELOPMENT_TEAM=$TEAM_ID \
         CODE_SIGN_IDENTITY=\"Apple Distribution\" \
         PROVISIONING_PROFILE_SPECIFIER=\"Punchlist Ad Hoc\" \
         2>&1 | tail -30'"

    echo "=== Exporting IPA ==="
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'security unlock-keychain -p build ~/Library/Keychains/build.keychain-db && \
       xcodebuild -exportArchive \
         -archivePath {{archive_path}} \
         -exportOptionsPlist /tmp/ExportOptions.plist \
         -exportPath {{export_path}} \
         2>&1 | tail -20'"

# Distribute IPA to ad-hoc server
distribute: archive
    #!/usr/bin/env bash
    set -euo pipefail

    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    # Pull IPA from build host
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' scp -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST:{{export_path}}/{{app_name}}.ipa $TMPDIR/{{app_name}}.ipa"

    # Generate manifest plist
    cat > "$TMPDIR/{{app_name}}.plist" <<EOF
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
              <string>$DIST_URL/{{app_name}}.ipa</string>
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
    EOF

    # Copy to distribution directory
    cp "$TMPDIR/{{app_name}}.ipa" $DIST_DIR/{{app_name}}.ipa
    cp "$TMPDIR/{{app_name}}.plist" $DIST_DIR/{{app_name}}.plist
    chmod 644 $DIST_DIR/{{app_name}}.ipa $DIST_DIR/{{app_name}}.plist

    echo ""
    echo "Distributed! Install from:"
    echo "  $DIST_URL"

# Open install page in browser
install:
    @echo "$DIST_URL"
    @echo "Open on your iOS device to install."

# Clean build artifacts on build host
clean:
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && xcodebuild -project {{project}} -scheme {{scheme}} clean 2>&1'"

# Post-agent-session: push and distribute
agent-session-complete:
    git push
    just distribute

# Type-check Swift files without full build
check: sync
    #!/usr/bin/env bash
    nix-shell -p sshpass --run "sshpass -p '$BUILD_PASS' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password $BUILD_USER@$BUILD_HOST \
      'cd {{remote_dir}} && swiftc -typecheck -sdk \$(xcrun --sdk iphonesimulator --show-sdk-path) -target arm64-apple-ios17.0-simulator Punchlist/**/*.swift 2>&1'"
