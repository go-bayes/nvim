#!/usr/bin/env bash
set -euo pipefail

# Clone this Neovim config repo and symlink it to ~/.config/nvim
# Usage: ./scripts/bootstrap.sh git@github.com:<USER>/nvim.git [~/.config/nvim] [clone_parent_dir]

REPO_URL="${1:-}"
if [[ -z "$REPO_URL" ]]; then
  echo "Usage: $0 git@github.com:<USER>/nvim.git [target_dir] [clone_parent]" >&2
  exit 1
fi

TARGET_DIR="${2:-$HOME/.config/nvim}"
CLONE_PARENT="${3:-$HOME/.local/share/nvim-repos}"
mkdir -p "$CLONE_PARENT"

TS=$(date +%Y%m%d-%H%M%S)
if [[ -e "$TARGET_DIR" && ! -L "$TARGET_DIR" ]]; then
  mv "$TARGET_DIR" "${TARGET_DIR}-backup-${TS}"
  echo "Backed up existing config to ${TARGET_DIR}-backup-${TS}"
fi

CLONE_DIR="$CLONE_PARENT/nvim-${TS}"
git clone "$REPO_URL" "$CLONE_DIR"

mkdir -p "$(dirname "$TARGET_DIR")"
ln -s "$CLONE_DIR" "$TARGET_DIR"

echo "Symlinked $CLONE_DIR → $TARGET_DIR"
echo "Open Neovim and run :Lazy sync, then restart."

