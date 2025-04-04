#!/bin/bash
set -euo pipefail

# Install git if not already installed
if ! command -v git &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y git
fi

# Clone the repository with the setup script
git clone https://github.com/rcushen/setup-scripts.git
cd setup-scripts

# Make the setup script executable and run it
chmod +x setup.sh
./setup.sh
