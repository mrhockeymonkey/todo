#!/bin/bash
# Cloud environment setup script. Not run from the repo: paste this into the
# claude.ai environment settings (Setup script). Its result is cached, so new
# sessions start with fvm and the Flutter SDK already installed.
set -euo pipefail

# fvm.app and GitHub release downloads are blocked, so bootstrap fvm from a
# standalone Dart SDK + pub.dev.
if [ ! -x /opt/dart-sdk/bin/dart ]; then
  curl -fsSL -o /tmp/dart.zip https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
  unzip -q -o /tmp/dart.zip -d /opt && rm /tmp/dart.zip
fi
export PATH="$PATH:/opt/dart-sdk/bin:$HOME/.pub-cache/bin"
command -v fvm >/dev/null || dart pub global activate fvm

# Pre-fetch the Flutter SDK pinned in each cloned repo's .fvmrc, so the
# cached environment already has it.
shopt -s nullglob
for rc in /home/user/*/.fvmrc; do
  (cd "$(dirname "$rc")" && fvm install --setup)
done
