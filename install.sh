#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/daanqq/dotfiles.git}"
SOURCE_SNAPSHOT_DIR=""

log() {
  printf '%s\n' "$*"
}

resolve_source() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if git -C "$script_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s\n' "$script_dir"
    return 0
  fi

  printf '%s\n' "$REPO_URL"
}

is_git_worktree_clean() {
  local path="$1"

  git -C "$path" status --porcelain --untracked-files=all | grep -q '^' && return 1
  return 0
}

prepare_source_repo() {
  local source="$1"

  if [ ! -d "$source" ]; then
    printf '%s\n' "$source"
    return 0
  fi

  if git -C "$source" rev-parse --is-inside-work-tree >/dev/null 2>&1 && is_git_worktree_clean "$source"; then
    printf '%s\n' "$source"
    return 0
  fi

  SOURCE_SNAPSHOT_DIR="$(mktemp -d)"
  git -C "$SOURCE_SNAPSHOT_DIR" init -q
  git -C "$SOURCE_SNAPSHOT_DIR" config user.name snapshot
  git -C "$SOURCE_SNAPSHOT_DIR" config user.email snapshot@example.com
  tar -C "$source" --exclude='.git' -cf - . | tar -C "$SOURCE_SNAPSHOT_DIR" -xf -
  git -C "$SOURCE_SNAPSHOT_DIR" add -A
  git -C "$SOURCE_SNAPSHOT_DIR" commit -qm "snapshot"
  git -C "$SOURCE_SNAPSHOT_DIR" branch -M main
  printf '%s\n' "$SOURCE_SNAPSHOT_DIR"
}

cleanup() {
  if [ -n "$SOURCE_SNAPSHOT_DIR" ] && [ -d "$SOURCE_SNAPSHOT_DIR" ]; then
    rm -rf "$SOURCE_SNAPSHOT_DIR"
  fi
}

trap cleanup EXIT

ensure_apt_packages() {
  sudo apt update
  sudo apt install -y git curl yadm zsh unzip eza bat btop ripgrep fd-find
}

ensure_yadm_repo() {
  local source
  source="$(prepare_source_repo "$(resolve_source)")"

  if yadm rev-parse --git-dir >/dev/null 2>&1; then
    log "yadm repository already exists; syncing from source"
    if yadm remote get-url origin >/dev/null 2>&1; then
      yadm remote set-url origin "$source"
    else
      yadm remote add origin "$source"
    fi
    yadm fetch origin main
    yadm reset --hard origin/main
    return 0
  fi

  backup_existing_dotfiles
  backup_existing_configs

  log "Cloning dotfiles with yadm..."
  yadm clone -b main --no-bootstrap "$source"
}

backup_existing_dotfiles() {
  local target
  for target in "$HOME/.zshrc" "$HOME/.gitconfig"; do
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mv "$target" "$target.bak.$(date +%Y%m%d-%H%M%S)"
      log "Backed up $target"
    fi
  done
}

backup_existing_configs() {
  local target
  for target in "$HOME/.config/btop" "$HOME/.config/windows"; do
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mv "$target" "$target.bak.$(date +%Y%m%d-%H%M%S)"
      log "Backed up $target"
    fi
  done
}

configure_sparse_checkout() {
  yadm sparse-checkout init --cone >/dev/null 2>&1 || true
  yadm sparse-checkout set --skip-checks .config .gitconfig .zshrc
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

install_zoxide() {
  if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
}

install_starship() {
  if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh
  fi
}

install_fnm() {
  if ! command -v fnm >/dev/null 2>&1; then
    curl -fsSL https://fnm.vercel.app/install | bash
  fi
}

install_fzf() {
  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all
  fi
}

install_zsh_autosuggestions() {
  local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

  if [ ! -d "$plugin_dir" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
  fi
}

log "Installing dotfiles..."
ensure_apt_packages
ensure_yadm_repo
configure_sparse_checkout
install_oh_my_zsh
install_zoxide
install_starship
install_fnm
install_fzf
install_zsh_autosuggestions

log "Dotfiles installation complete."
