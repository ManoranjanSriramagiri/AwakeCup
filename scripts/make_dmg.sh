#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="AwakeCup"

bash "$ROOT_DIR/scripts/build_app_clt.sh"

OUT_DIR="$ROOT_DIR/build-clt"
DMG_PATH="$ROOT_DIR/${APP_NAME}.dmg"

rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$OUT_DIR" -ov -format UDZO "$DMG_PATH" >/dev/null || {
  echo "DMG creation failed (hdiutil)."
  echo "If you are running in a restricted/sandboxed environment, run this script from your normal macOS Terminal."
  exit 1
}

echo "DMG created: $DMG_PATH"

