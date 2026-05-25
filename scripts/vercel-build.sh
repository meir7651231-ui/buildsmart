#!/usr/bin/env bash
# Vercel build script for the Flutter web app (app_flutter/).
# Installs Flutter, runs `flutter build web --release`, output ends up at
# app_flutter/build/web (referenced by vercel.json `outputDirectory`).
set -euo pipefail

FLUTTER_VERSION="3.44.0"
FLUTTER_HOME="$HOME/flutter"

echo "=== BuildSmart · Vercel build ==="
echo "Flutter target: $FLUTTER_VERSION"

# Install Flutter (Vercel caches $HOME between builds when possible).
# Re-clone if cached version doesn't match the target version.
CACHED_VERSION=""
if [ -x "$FLUTTER_HOME/bin/flutter" ]; then
  CACHED_VERSION=$("$FLUTTER_HOME/bin/flutter" --version 2>/dev/null | grep -oP 'Flutter \K[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
fi

if [ "$CACHED_VERSION" = "$FLUTTER_VERSION" ]; then
  echo "✅ Flutter cache hit at $FLUTTER_HOME ($CACHED_VERSION)"
else
  echo "📥 Cloning Flutter $FLUTTER_VERSION (cached: ${CACHED_VERSION:-none}) ..."
  rm -rf "$FLUTTER_HOME"
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"
flutter --version

echo ""
echo "🏗️  Building Flutter web ..."
cd app_flutter
flutter pub get
flutter build web --release --pwa-strategy=offline-first

echo ""
echo "✅ Output: app_flutter/build/web"
ls -la build/web | head -8
