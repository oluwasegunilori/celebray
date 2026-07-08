#!/usr/bin/env bash
# Capture 13-inch iPad App Store screenshots via Flutter integration tests.
#
# Requirements:
#   - Xcode + iOS Simulator
#   - iPad Pro 13-inch (M4) — 2064×2752 portrait (App Store 13" iPad slot)
#
# Usage:
#   ./scripts/capture_ipad_screenshots.sh
#   DEVICE="iPad Pro 13-inch (M5)" ./scripts/capture_ipad_screenshots.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE="${DEVICE:-iPad Pro 13-inch (M4)}"
OUTPUT_DIR="$ROOT/store_screenshots/ios/13-inch-ipad"

cd "$ROOT"

echo "→ Resolving dependencies"
flutter pub get

echo "→ Booting simulator: $DEVICE"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator >/dev/null 2>&1 || true
sleep 3

echo "→ Running screenshot integration tests on $DEVICE"
export SCREENSHOT_OUTPUT_DIR="$OUTPUT_DIR"
flutter drive \
  --driver=integration_test/driver.dart \
  --target=integration_test/app_store_screenshots_test.dart \
  -d "$DEVICE"

count="$(find "$OUTPUT_DIR" -maxdepth 1 -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$count" == "0" ]]; then
  echo "No screenshots found in $OUTPUT_DIR"
  exit 1
fi

echo ""
echo "✅ Saved $count screenshot(s) to:"
echo "   $OUTPUT_DIR"
echo ""
echo "Upload in App Store Connect → Celebray → iOS App → Screenshots → 13\" iPad Display"
echo "Accepted sizes: 2064×2752, 2752×2064, 2048×2732, or 2732×2048 px"
