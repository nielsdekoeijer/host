#!/usr/bin/env bash
set -exu

if [[ -f /etc/NIXOS ]]; then
  sudo nixos-rebuild switch --show-trace --flake .
else
  nix run home-manager/master -- switch --flake .#home-manager-only
fi
