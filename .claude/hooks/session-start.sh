#!/bin/bash
# Ensures the Flutter SDK pinned in .fvmrc is installed and fvm is on PATH so
# cloud sessions use the same `fvm flutter ...` commands as local development.
# fvm itself is installed by the environment setup script (.claude/cloud-setup.sh).
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FVM_PATH="/opt/dart-sdk/bin:$HOME/.pub-cache/bin"
export PATH="$PATH:$FVM_PATH"

if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found: paste .claude/cloud-setup.sh into the environment's Setup script." >&2
  exit 1
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"\$PATH:$FVM_PATH\"" >> "$CLAUDE_ENV_FILE"
fi

cd "$CLAUDE_PROJECT_DIR"
# No-op when the cached environment already has this version; fetches it when
# .fvmrc changed since the cache was built.
fvm install --setup
fvm flutter pub get
