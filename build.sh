#!/bin/sh
set -eu

DEVICE_NAME="${1:-iPhone 17 Pro}"
ACTION="${2:-build}"

case "$ACTION" in
  build|test) ;;
  *)
    echo "error: action must be 'build' or 'test'; release archives use the reviewed release process" >&2
    exit 1
    ;;
esac

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "error: XcodeGen is required (brew install xcodegen)" >&2
  exit 1
fi

xcodegen generate

DESTINATION="platform=iOS Simulator,name=${DEVICE_NAME},OS=latest"
xcodebuild \
  -project Bameyasu.xcodeproj \
  -scheme Bameyasu \
  -destination "$DESTINATION" \
  -derivedDataPath DerivedData \
  "$ACTION" \
  CODE_SIGNING_ALLOWED=NO
