#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ln -sf "${repo_root}/dotfiles/aerospace/.aerospace.toml" "${HOME}/.aerospace.toml"

echo "Linked AeroSpace config → ${HOME}/.aerospace.toml"
