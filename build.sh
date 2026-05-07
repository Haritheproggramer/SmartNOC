#!/usr/bin/env bash
set -e

# ── Flutter version ────────────────────────────────────────────────────────────
FLUTTER_VERSION="3.41.6"          # Must match the version used locally
FLUTTER_CHANNEL="stable"

# ── Install Flutter if not already present ─────────────────────────────────────
if [ ! -d "$HOME/flutter" ]; then
  echo "→ Downloading Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)..."
  git clone \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git \
    "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "→ Flutter version: $(flutter --version --no-version-check 2>&1 | head -1)"

# ── Pre-cache web artifacts (silently) ────────────────────────────────────────
flutter precache --web --no-android --no-ios --no-macos --no-linux --no-windows --no-fuchsia

# ── Get dependencies ───────────────────────────────────────────────────────────
flutter pub get

# ── Build ──────────────────────────────────────────────────────────────────────
echo "→ Building Flutter web release..."
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "→ Build complete. Output in build/web"
