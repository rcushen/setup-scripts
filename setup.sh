#!/bin/bash
set -euo pipefail

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install essential developer tools
sudo apt install -y build-essential git curl wget unzip zip \
                      software-properties-common apt-transport-https \
                      ca-certificates gnupg lsb-release python3 python3-pip \
                      cron htop jq

# Install zsh
sudo apt install -y zsh
chsh -s $(which zsh)
zsh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

sudo apt update
sudo apt install gh

# Configure git identity
git config --global user.name "Ryan Cushen"
git config --global user.email "cushenr@gmail.com"

# Authenticate with GitHub CLI
gh auth login --web

# Install Neovim
sudo apt update
sudo apt install neovim -y

# Install tmux
sudo apt install -y tmux

# Create config directories if they don't exist
mkdir -p ~/.config/nvim
mkdir -p ~/.config/tmux

# Clone packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Clone your configs
gh repo clone rcushen/nvim ~/.config/nvim || git clone git@github.com:rcushen/nvim ~/.config/nvim
gh repo clone rcushen/tmux ~/.config/tmux || git clone git@github.com:rcushen/tmux ~/.config/tmux

# Link tmux config
ln -sf ~/.config/tmux/.tmux.conf ~/.tmux.conf

# Install Node.js
sudo apt install -y nodejs

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

echo "Setup completed successfully!"
