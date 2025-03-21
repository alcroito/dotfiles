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

$HOME/.local/bin/chezmoi init --apply https://github.com/alcroito/dotfiles.git

