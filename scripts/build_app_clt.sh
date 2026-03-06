#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="AwakeCup"
BUNDLE_ID="com.example.AwakeCup"
VERSION="0.1.0"
BUILD="1"
MIN_MACOS="13.0"

SRC_DIR="$ROOT_DIR/AwakeCup"
OUT_DIR="$ROOT_DIR/build-clt"
APP_DIR="$OUT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
PLIST_PATH="$CONTENTS_DIR/Info.plist"

rm -rf "$OUT_DIR"
mkdir -p "$MACOS_DIR"

SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
ARCH="$(uname -m)"
if [[ "$ARCH" != "arm64" && "$ARCH" != "x86_64" ]]; then
  echo "Unsupported arch: $ARCH" >&2
  exit 2
fi

echo "Building $APP_NAME.app using Command Line Tools..."
echo "SDK: $SDK_PATH"
echo "Arch: $ARCH"

# Compile the SwiftUI menubar app into an executable inside the app bundle.
xcrun --sdk macosx swiftc \
  -O \
  -sdk "$SDK_PATH" \
  -target "${ARCH}-apple-macos${MIN_MACOS}" \
  -framework SwiftUI \
  -framework AppKit \
  -framework ServiceManagement \
  -framework IOKit \
  -o "$MACOS_DIR/$APP_NAME" \
  "$SRC_DIR"/*.swift

chmod +x "$MACOS_DIR/$APP_NAME"

# Write a concrete Info.plist (the Xcode one uses build-setting placeholders).
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${BUILD}</string>
  <key>LSMinimumSystemVersion</key>
  <string>${MIN_MACOS}</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
EOF

plutil -lint "$PLIST_PATH" >/dev/null

# Optional: ad-hoc sign for smoother local launching.
if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
fi

echo "Done."
echo "App bundle: $APP_DIR"
echo "Launch with: open \"$APP_DIR\""

