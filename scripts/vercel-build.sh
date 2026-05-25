#!/usr/bin/env bash
# Vercel build script for the Flutter web app (app_flutter/).
set -euo pipefail

FLUTTER_VERSION="3.44.0"
FLUTTER_HOME="$HOME/flutter"
FLUTTER_CDN="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "=== BuildSmart · Vercel build ==="
echo "Flutter target: $FLUTTER_VERSION"

# Check cached version via version file (faster than running flutter --version).
CACHED_VERSION=""
if [ -f "$FLUTTER_HOME/version" ]; then
  CACHED_VERSION=$(cat "$FLUTTER_HOME/version" | tr -d '[:space:]')
fi

if [ "$CACHED_VERSION" = "$FLUTTER_VERSION" ]; then
  echo "✅ Flutter cache hit ($CACHED_VERSION)"
else
  echo "📥 Downloading Flutter $FLUTTER_VERSION from CDN ..."
  rm -rf "$FLUTTER_HOME"
  mkdir -p "$(dirname "$FLUTTER_HOME")"
  curl -fsSL "$FLUTTER_CDN" | tar xJ -C "$(dirname "$FLUTTER_HOME")"
fi

# Git safe.directory — needed when Flutter is extracted as root on Vercel.
git config --global --add safe.directory "$FLUTTER_HOME" 2>/dev/null || true

export PATH="$FLUTTER_HOME/bin:$PATH"
flutter --version

echo ""
echo "🏗️  Building Flutter web ..."
cd app_flutter
flutter pub get
flutter build web --release

echo ""
echo "✅ Output: app_flutter/build/web"
ls -la build/web | head -8
