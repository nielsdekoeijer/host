#!/usr/bin/env bash
set -exu

if [[ -f /etc/NIXOS ]]; then
  # sudo nixos-rebuild switch --show-trace --flake .
  sudo nixos-rebuild switch --show-trace --flake .#personal-laptop
else
  nix run home-manager/master -- switch -b backup --flake .#home-manager-only-wsl
fi
