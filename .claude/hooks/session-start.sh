#!/bin/bash
# Installs fvm and the Flutter SDK pinned in .fvmrc so cloud sessions use the
# same `fvm flutter ...` commands as local development.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

DART_SDK_DIR=/opt/dart-sdk
PUB_BIN="$HOME/.pub-cache/bin"
export PATH="$PATH:$DART_SDK_DIR/bin:$PUB_BIN"

# fvm.app and GitHub release downloads are blocked by the network policy, so
# bootstrap fvm via a standalone Dart SDK and pub.dev instead.
if ! command -v fvm >/dev/null 2>&1; then
  if [ ! -x "$DART_SDK_DIR/bin/dart" ]; then
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/dart.zip" \
      https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
    unzip -q -o "$tmp/dart.zip" -d "$(dirname "$DART_SDK_DIR")"
    rm -rf "$tmp"
  fi
  dart pub global activate fvm
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"\$PATH:$DART_SDK_DIR/bin:$PUB_BIN\"" >> "$CLAUDE_ENV_FILE"
fi

cd "$CLAUDE_PROJECT_DIR"
# Installs the version from .fvmrc (no-op when already cached).
fvm install --setup
fvm flutter pub get
