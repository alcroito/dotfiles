#!/bin/sh

set -e # Exit on Error
set -x # Log Executions

################################################################################
# Install commands                                                             #
################################################################################
cd "$HOME" || return
echo -e "BEEP BOOP. Setting up..."

################################################################################
# macOS Detection and Prerequisites                                           #
################################################################################
if [ "$(uname)" = "Darwin" ]; then
    echo "macOS detected"

    if ! command -v git >/dev/null 2>&1; then
        if ! xcode-select -p 1>/dev/null 2>&1; then
          tmp_file=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
          touch "$tmp_file"
          label=$(softwareupdate -l | grep -B 1 -E 'Command Line Tools' | awk -F'*' '/^ *\\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)
          # $label is like 'Command Line Tools for Xcode-16.0'
          if [ -n "$label" ]; then
            softwareupdate -i "$label"
          fi
          rm -f "$tmp_file"
        fi
    else
        echo "Git is already available"
    fi
fi

################################################################################
# Chezmoi                                                                      #
################################################################################
curl -sfL https://get.chezmoi.io/lb | sh

$HOME/.local/bin/chezmoi init --apply https://github.com/alcroito/dotfiles.git

