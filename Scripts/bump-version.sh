#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <marketing-version: x.y.z> <build-number>" >&2
  exit 2
fi

VERSION="$1"
BUILD_NUMBER="$2"

case "$VERSION" in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) echo "error: marketing version must contain three integers" >&2; exit 2 ;;
esac

case "$BUILD_NUMBER" in
  *[!0-9]*|'') echo "error: build number must be a positive integer" >&2; exit 2 ;;
esac

perl -0pi -e 's/MARKETING_VERSION: "[^"]+"/MARKETING_VERSION: "'"$VERSION"'"/' project.yml
perl -0pi -e 's/CURRENT_PROJECT_VERSION: "[^"]+"/CURRENT_PROJECT_VERSION: "'"$BUILD_NUMBER"'"/' project.yml
perl -0pi -e 's/Text\("[0-9]+\.[0-9]+\.[0-9]+ \([0-9]+\)"\)/Text("'"$VERSION"' ('"$BUILD_NUMBER"')")/' Bameyasu/Views/SettingsView.swift

echo "Bameyasu ${VERSION} (${BUILD_NUMBER})"
