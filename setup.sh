#!/bin/bash
set -euo pipefail

# Requires a fine-grained GitHub PAT exported as GH_TOKEN before running.
# Create one at: https://github.com/settings/tokens?type=beta
# Scope to only the repos this script needs (rcushen/nvim, rcushen/tmux).
# Required permissions: Contents (Read), Pull requests (Read and write), Metadata (Read).
: "${GH_TOKEN:?GH_TOKEN must be set before running this script}"

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install essential developer tools
sudo apt install -y build-essential git curl wget unzip zip \
                      software-properties-common apt-transport-https \
                      ca-certificates gnupg lsb-release python3 python3-pip \
                      cron htop jq \
                      ripgrep fd-find fzf xclip

# On Debian/Ubuntu fd is installed as fdfind; alias it to fd
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd

# Install zsh and set as default shell (takes effect on next login)
sudo apt install -y zsh
chsh -s $(which zsh)

# Install oh-my-zsh (non-interactive: skip shell change and auto-launch)
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && rm -f $out \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Configure git identity
git config --global user.name "Ryan Cushen"
git config --global user.email "cushenr@gmail.com"

# Generate SSH key if one doesn't already exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "cushenr@gmail.com" -N "" -f ~/.ssh/id_ed25519
    echo ""
    echo "SSH key generated. Add the following public key to GitHub (https://github.com/settings/keys):"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
fi

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

# Install Node.js via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
\. "$NVM_DIR/nvm.sh"
nvm install --lts

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
LAZYGIT_ARCH=$(dpkg --print-architecture | sed 's/amd64/x86_64/;s/arm64/arm64/;s/armhf/armv6/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm -f lazygit.tar.gz lazygit

echo "Setup completed successfully!"
