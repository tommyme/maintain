#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.config/tmux/ ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -sf "$SCRIPT_DIR/tmux.conf" ~/.config/tmux/tmux.conf
ln -sf "$SCRIPT_DIR/tmux.reset.conf" ~/.config/tmux/tmux.reset.conf
echo "if it's first time to start tmux, press <ctrl-a I> to install dependencies."