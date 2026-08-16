#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <marketing-version: x.y.z> <build-number>" >&2
  exit 2
fi

VERSION="$1"
BUILD_NUMBER="$2"

if ! printf '%s\n' "$VERSION" | /usr/bin/grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'; then
  echo "error: marketing version must contain three integers" >&2
  exit 2
fi

if ! printf '%s\n' "$BUILD_NUMBER" | /usr/bin/grep -Eq '^[1-9][0-9]*$'; then
  echo "error: build number must be a positive integer" >&2
  exit 2
fi

perl -0pi -e 's/MARKETING_VERSION: "[^"]+"/MARKETING_VERSION: "'"$VERSION"'"/' project.yml
perl -0pi -e 's/CURRENT_PROJECT_VERSION: "[^"]+"/CURRENT_PROJECT_VERSION: "'"$BUILD_NUMBER"'"/' project.yml

echo "Bameyasu ${VERSION} (${BUILD_NUMBER})"
