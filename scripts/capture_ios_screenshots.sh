#!/usr/bin/env bash
# Capture iPhone App Store screenshots via Flutter integration tests.
#
# Requirements:
#   - Xcode + iOS Simulator
#   - iPhone 17 Pro Max (6.7" — covers App Store 6.7" screenshot slot)
#
# Usage:
#   ./scripts/capture_ios_screenshots.sh
#   DEVICE="iPhone 17 Pro" ./scripts/capture_ios_screenshots.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE="${DEVICE:-iPhone 17 Pro Max}"
OUTPUT_DIR="$ROOT/store_screenshots/ios/6.7-inch"

cd "$ROOT"

echo "→ Resolving dependencies"
flutter pub get

echo "→ Booting simulator: $DEVICE"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator >/dev/null 2>&1 || true

echo "→ Running screenshot integration tests"
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
echo "Upload these in App Store Connect → Celebray → iOS App → Screenshots → 6.7\" Display"
echo ""
echo "App Preview videos must be recorded manually (QuickTime → File → New Screen Recording)."
