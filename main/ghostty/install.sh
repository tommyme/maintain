#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.config/ghostty
ln -sf "$SCRIPT_DIR/config" ~/.config/ghostty/config
echo "Ghostty config installed."