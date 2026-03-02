#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Silent Timer"
EXECUTABLE_NAME="SilentStatusTimer"
APP_BUNDLE="${ROOT_DIR}/${APP_NAME}.app"
EXECUTABLE_PATH="${ROOT_DIR}/.build/release/${EXECUTABLE_NAME}"
ICON_SOURCE="${ROOT_DIR}/assets/AppIcon1024.png"
ICON_DEST_NAME="AppIcon.icns"
BUNDLE_IDENTIFIER="com.silenttimer.statusbar"

cd "${ROOT_DIR}"

echo "Building release binary..."
swift build -c release

if [[ ! -f "${EXECUTABLE_PATH}" ]]; then
  echo "error: release executable not found at ${EXECUTABLE_PATH}" >&2
  exit 1
fi

echo "Creating app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_BUNDLE}/Contents/Resources"
cp "${EXECUTABLE_PATH}" "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"

if [[ -f "${ICON_SOURCE}" ]]; then
  cp "${ICON_SOURCE}" "${APP_BUNDLE}/Contents/Resources/${ICON_DEST_NAME}"
fi

cat > "${APP_BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>SilentStatusTimer</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_IDENTIFIER}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
    <key>CFBundleName</key>
    <string>Silent Timer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "Built app bundle: ${APP_BUNDLE}"
