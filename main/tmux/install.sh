#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ln -s -f "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
cp "$SCRIPT_DIR/.tmux.conf.local" ~/.tmux.conf.local
