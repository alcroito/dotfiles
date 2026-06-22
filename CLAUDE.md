# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [chezmoi](https://chezmoi.io)-managed cross-platform dotfiles repository (`alcroito/dotfiles`). It targets macOS (Intel + Apple Silicon), several Linux distros (Ubuntu, Debian, Arch/EndeavourOS, Fedora, CentOS/Rocky/RHEL, Alpine), Windows, and WSL from a single source tree.

## Critical: the source root is `home/`, not the repo root

`.chezmoiroot` contains `home`, so chezmoi's source directory is `home/`. All managed files, scripts, templates, and chezmoi special files live under `home/`. The repo root only holds bootstrap scripts (`install.sh`, `install.ps1`), `README.md`, and the `scripts/` helper directory.

## chezmoi file-naming conventions (how source maps to target)

Source filenames under `home/` are attribute-encoded, not literal:
- `dot_foo` → `~/.foo` (e.g. `dot_zshrc.tmpl` → `~/.zshrc`, `dot_config/` → `~/.config/`)
- `private_` prefix → target mode `0600` (e.g. `private_dot_ssh/` → `~/.ssh/`)
- `.tmpl` suffix → rendered as a Go text/template before being written; the suffix is stripped
- `run_onchange_before_*` / `run_onchange_after_*` → scripts executed (in numbered order) before/after applying the rest of the state, re-run whenever their rendered content changes

When editing a managed file, edit the source under `home/` — never the deployed copy in `$HOME`. Adding a new dotfile means creating it under `home/` with the right name encoding.

## Template data model

`home/.chezmoi.toml.tmpl` is the config template. On `chezmoi init` it prompts (via `promptStringOnce`/`promptBoolOnce`, so answers persist) and writes a `[data]` section consumed by every `.tmpl`. Key variables referenced throughout the repo:
- `.osid` — primary platform switch: `darwin`, `linux-ubuntu`, `linux-debian`, `linux-arch`, `linux-endeavouros`, `linux-fedora`, `linux-rocky`, `linux-rhel`, `linux-centos`, `linux-alpine`, `windows`. Built from `.chezmoi.os` + `.chezmoi.osRelease.id`.
- `.machine_id` — per-host identifier (e.g. `macbook_home`, `macbook_home_arm`, `work_macbook_pro_arm`, `chie`) used for host-specific branches.
- `.location` — `home` / `work` / `vm`; selects the git name/email identity.
- `install_*` flags (`install_packages`, `install_secrets`, `install_nvim`, `install_nvim_bob`, `install_nvim_deps`, `install_nvim_plugs`, `install_qt_deps`) — guard whether `run_onchange` scripts do anything; most scripts open with `{{ if .install_X }}`.
- `.arch_alt` — normalized arch string (`x86_64`, `arm64`, …).

Platform-specific behavior is expressed as `{{ if eq .osid "..." }}` branches inside templates, and as ignore rules in `home/.chezmoiignore` (which itself is a template — it excludes Windows paths on Unix and vice versa).

## Composition: `.chezmoitemplates`

Reusable shell snippets live in `home/.chezmoitemplates/` (e.g. `zshrc_unix`, `zshrc_aliases`, `zshrc_macos_common_arm`, `zshrc_plugins_arch`). `home/dot_zshrc.tmpl` is essentially a dispatcher that `{{ template "..." . }}`-includes these partials conditionally on `.osid`, `.chezmoi.arch`, and `.machine_id`. To change shell config, edit the relevant partial rather than inlining into `dot_zshrc.tmpl`.

## Install scripts (`.chezmoiscripts/`)

Split into `unix/` and `windows/` subdirs (the other platform's dir is ignored via `.chezmoiignore`). Naming is `run_onchange_{before,after}_NNN_description.{sh,ps1}.tmpl`; the `NNN` prefix orders execution. They handle package installation (per-distro `apt`/`dnf`/`pacman`/`scoop`/`choco`/`winget` branches), neovim, Qt build deps, and Proton Pass setup. Because they are `run_onchange`, chezmoi re-executes a script only when its rendered output changes — keep that in mind when editing (changing a script causes it to re-run on next apply).

## Secrets

Managed via **Proton Pass CLI** (`pass-cli`), configured as chezmoi's `[secret].command`. Templates pull secrets with `secretJSON "item" "view" ... "pass://..."` (see `home/private_dot_ssh/private_work_ssh_2025_dec.tmpl`). All secret handling is gated behind `{{ if .install_secrets }}`. The `run_onchange_before_*_proton_pass` / `*_login_proton_pass` scripts install and authenticate the CLI. On Windows over SSH, private-key retrieval is intentionally skipped (Credential Manager is inaccessible); `scripts/windows/Clear-ChezmoiProtonPassState.ps1` resets that state.

## Neovim config

`home/dot_config/nvim/` is a Lua + [lazy.nvim](https://github.com/folke/lazy.nvim) setup. `init.vim` sources `~/.vimrc` then `require("config.nvim_init")`; plugin specs live one-per-file under `lua/plugins/`, core config under `lua/config/`. Lua is formatted with `stylua` (`stylua.toml` present). Most recent commits in this repo are nvim tweaks.

## Common commands

```bash
# Preview what would change without applying (always do this first)
chezmoi diff

# Apply the source state to $HOME
chezmoi apply -v

# Edit a managed file via chezmoi (opens the source under home/)
chezmoi edit ~/.zshrc

# Render a template to stdout to debug template logic
chezmoi execute-template < home/dot_zshrc.tmpl
chezmoi cat ~/.zshrc          # render a specific managed file

# Inspect the resolved template data ([data] from .chezmoi.toml.tmpl)
chezmoi data

# Re-run init (re-prompts config) — usually not needed once set up
chezmoi init

# Fresh-machine bootstrap (what install.sh ultimately runs)
chezmoi init --apply https://github.com/alcroito/dotfiles.git
```

Run chezmoi commands from anywhere; it resolves the source dir via its own config, honoring `.chezmoiroot`. After editing source files here, `chezmoi diff` then `chezmoi apply` to deploy.
