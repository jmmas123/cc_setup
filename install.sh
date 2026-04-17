#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== cc_setup install ==="
echo ""

# --- Homebrew check ---
if ! command -v brew &>/dev/null; then
    echo "ERROR: Homebrew not found. Install from https://brew.sh"
    exit 1
fi

# --- Packages ---
echo "Installing Homebrew dependencies..."
brew install terminal-notifier 2>/dev/null || true
echo "  terminal-notifier (used by hooks/notify.sh)"

# --- Hook scripts executable ---
chmod +x "$REPO_DIR/hooks"/*.sh 2>/dev/null || true
echo "  hooks/*.sh marked executable"

echo ""
echo "Done. If this is a fresh clone, next step is 'claude' to authenticate."
