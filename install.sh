#!/bin/bash
echo "Installing dotfiles..."

# install apt packages
sudo apt update
sudo apt upgrade -y
sudo apt install -y zsh unzip eza bat btop stow ripgrep fd-find

# install packages
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sS https://starship.rs/install.sh | sh
curl -fsSL https://fnm.vercel.app/install | bash

# install fzf
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

rm -rf .zshrc

# apply stow
cd .dotfiles
stow git zsh btop

echo "Dotfiles installation complete."
