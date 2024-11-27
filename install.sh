#!/bin/bash

set -e # Exit on Error
set -x # Log Executions

################################################################################
# Install commands                                                             #
################################################################################
cd "$HOME" || return
echo -e "BEEP BOOP. Setting up..."

################################################################################
# Chezmoi                                                                      #
################################################################################
curl -sfL https://get.chezmoi.io/lb | bash

export PATH=$HOME/.local/bin:$PATH
chezmoi init --apply https://github.com/alcroito/dotfiles.git

