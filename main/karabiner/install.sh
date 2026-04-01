#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/karabiner/karabiner.json"

mkdir -p "$HOME/.config/karabiner"

if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
    echo "Backing up existing config to ${TARGET}.bak"
    mv "$TARGET" "${TARGET}.bak"
fi

ln -sf "$SCRIPT_DIR/karabiner.json" "$TARGET"
echo "Linked $TARGET -> $SCRIPT_DIR/karabiner.json"
