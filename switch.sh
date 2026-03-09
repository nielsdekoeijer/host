#!/usr/bin/env bash

set -exu
HOSTNAME=$(hostname)

# Check if GITHUB_TOKEN is set and not empty
NIX_OPTS=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  NIX_OPTS=(--option access-tokens "github.com=${GITHUB_TOKEN}")
fi

if [[ -f /etc/NIXOS ]]; then
  # Pass the options to nixos-rebuild
  sudo nixos-rebuild switch --show-trace "${NIX_OPTS[@]}" --flake ".#${HOSTNAME}"
else
  # Pass the options to both `nix run` (to fetch the flake) and `home-manager` (to evaluate it)
  nix "${NIX_OPTS[@]}" run home-manager/master -- switch -b backup "${NIX_OPTS[@]}" --flake .#home-manager-only-wsl
fi
