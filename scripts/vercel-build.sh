#!/usr/bin/env bash
# Vercel build script for the Flutter web app (app_flutter/).
# Installs Flutter, runs `flutter build web --release`, output ends up at
# app_flutter/build/web (referenced by vercel.json `outputDirectory`).
set -euo pipefail

FLUTTER_VERSION="3.29.3"
FLUTTER_HOME="$HOME/flutter"

echo "=== BuildSmart · Vercel build ==="
echo "Flutter target: $FLUTTER_VERSION"

# Install Flutter (Vercel caches $HOME between builds when possible).
if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "📥 Cloning Flutter $FLUTTER_VERSION ..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME"
else
  echo "✅ Flutter cache hit at $FLUTTER_HOME"
fi
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
