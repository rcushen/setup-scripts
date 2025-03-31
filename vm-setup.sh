#!/bin/bash
set -e

# Parameters (can be passed as environment variables)
GITHUB_USERNAME=${GITHUB_USERNAME:-"your_default_username"}
GITHUB_EMAIL=${GITHUB_EMAIL:-"your_default_email"}
GITHUB_CONFIG_REPO=${GITHUB_CONFIG_REPO:-"your_default_repo"}

# Update and install packages
apt update
apt install -y build-essential git curl wget tmux htop ripgrep fd-find neovim zsh

# Set up neovim configuration
git clone https://github.com/$GITHUB_USERNAME/$GITHUB_CONFIG_REPO ~/.config/nvim

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure git
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"

# Set up tmux config
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "set -g mouse on
set -g default-terminal \"screen-256color\"" > ~/.tmux.conf

# Add useful aliases
echo 'alias ll="ls -la"
alias crons="crontab -l"
alias edcron="crontab -e"' >> ~/.bashrc

# Create cron status tool
echo '#!/bin/bash
echo "=== CRON STATUS ==="
crontab -l
echo "\n=== LAST RUNS ==="
grep CRON /var/log/syslog | tail -10' > ~/cron-status.sh
chmod +x ~/cron-status.sh

echo "Setup complete!"
