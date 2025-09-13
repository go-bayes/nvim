#!/usr/bin/env bash
set -euo pipefail

# Setup an SSH key for GitHub on macOS/Linux and print the public key
# Usage: ./scripts/setup_github_ssh.sh [email@example.com]

EMAIL="${1:-}"
KEY_DIR="$HOME/.ssh"
KEY_PATH="$KEY_DIR/id_ed25519"

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

if [[ ! -f "$KEY_PATH" ]]; then
  if [[ -z "$EMAIL" ]]; then
    read -rp "GitHub email (for key comment): " EMAIL
  fi
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
  echo "Generated key at: $KEY_PATH"
else
  echo "SSH key already exists: $KEY_PATH"
fi

CONFIG="$KEY_DIR/config"
if ! grep -q "^Host github.com$" "$CONFIG" 2>/dev/null; then
  {
    echo "Host github.com"
    echo "  AddKeysToAgent yes"
    # macOS specific keychain helper (ignored elsewhere)
    echo "  UseKeychain yes"
    echo "  IdentityFile $KEY_PATH"
  } >> "$CONFIG"
  chmod 600 "$CONFIG"
  echo "Updated $CONFIG with GitHub host entry"
fi

eval "$(ssh-agent -s)" >/dev/null
UNAME=$(uname -s || true)
if [[ "$UNAME" == "Darwin" ]]; then
  # macOS: store passphrase in Keychain
  ssh-add --apple-use-keychain "$KEY_PATH"
else
  ssh-add "$KEY_PATH"
fi

echo
if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$KEY_PATH.pub"
  echo "Public key copied to clipboard. Paste into GitHub → Settings → SSH and GPG keys."
else
  echo "Add this public key to GitHub (copied below):"
  echo "------------------------------------------------------------"
  cat "$KEY_PATH.pub"
  echo "------------------------------------------------------------"
fi

echo
echo "Test auth: ssh -T git@github.com"
echo "If prompted the first time, type 'yes'. You should see a greeting."

