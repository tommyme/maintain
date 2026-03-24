# agent.plugin.zsh - Agent skills sync management

AGENTS_SKILLS_DIR="$HOME/.agents/skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
OPENCLAW_SKILLS_DIR="$HOME/.openclaw/skills"

# Sync all skills in ~/.agents/skills to Claude and OpenClaw skill dirs
agent-sync() {
  local created=0

  if [[ ! -d "$AGENTS_SKILLS_DIR" ]]; then
    echo "[agent-sync] ERROR: $AGENTS_SKILLS_DIR not found"
    return 1
  fi

  for skill_path in "$AGENTS_SKILLS_DIR"/*/; do
    [[ -d "$skill_path" ]] || continue
    local name=$(basename "$skill_path")

    for target_dir in "$CLAUDE_SKILLS_DIR" "$OPENCLAW_SKILLS_DIR"; do
      [[ -d "$target_dir" ]] || continue
      if [[ ! -e "$target_dir/$name" ]]; then
        ln -s "$skill_path" "$target_dir/$name"
        echo "[agent-sync] created: $target_dir/$name"
        ((created++))
      elif [[ -L "$target_dir/$name" ]]; then
        # Check for broken symlinks
        if [[ ! -e "$(readlink "$target_dir/$name")" ]]; then
          rm "$target_dir/$name"
          ln -s "$skill_path" "$target_dir/$name"
          echo "[agent-sync] fixed broken: $target_dir/$name"
          ((created++))
        fi
      fi
    done
  done

  # Remove broken/stale symlinks not pointing to ~/.agents/skills
  local removed=0
  for target_dir in "$CLAUDE_SKILLS_DIR" "$OPENCLAW_SKILLS_DIR"; do
    [[ -d "$target_dir" ]] || continue
    for link in "$target_dir"/*; do
      [[ -L "$link" ]] || continue
      if [[ ! -e "$link" ]]; then
        rm "$link"
        echo "[agent-sync] removed broken: $link"
        ((removed++))
      fi
    done
  done

  local skills=("$AGENTS_SKILLS_DIR"/*/)
  if (( created == 0 && removed == 0 )); then
    echo "[agent-sync] all skills in sync (${#skills[@]} skills)"
  else
    echo "[agent-sync] synced: +$created created, -$removed removed (${#skills[@]} skills)"
  fi
}

# List all skills in ~/.agents/skills
agent-list() {
  echo "Skills in $AGENTS_SKILLS_DIR:"
  for skill_path in "$AGENTS_SKILLS_DIR"/*/; do
    [[ -d "$skill_path" ]] || continue
    local name=$(basename "$skill_path")
    local claude_ok="✗"
    local openclaw_ok="✗"
    [[ -e "$CLAUDE_SKILLS_DIR/$name" ]] && claude_ok="✓"
    [[ -e "$OPENCLAW_SKILLS_DIR/$name" ]] && openclaw_ok="✓"
    printf "  %-40s claude:%s  openclaw:%s\n" "$name" "$claude_ok" "$openclaw_ok"
  done
}

agent-sync
alias claude="claude --allow-dangerously-skip-permissions"

# opencode
export PATH=$HOME/.opencode/bin:$PATH
# OpenClaw Completion
source "$HOME/.openclaw/completions/openclaw.zsh"
