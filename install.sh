#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/daanqq/dotfiles.git}"

log() {
  printf '%s\n' "$*"
}

ensure_apt_packages() {
  sudo apt update
  sudo apt install -y git curl yadm zsh unzip eza bat btop ripgrep fd-find
}

ensure_yadm_repo() {
  if yadm rev-parse --git-dir >/dev/null 2>&1; then
    log "yadm repository already exists"
    return 0
  fi

  log "Cloning dotfiles with yadm..."
  yadm clone --no-bootstrap "$REPO_URL"
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
