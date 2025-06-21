#!/usr/bin/env bash
set -exu 

# enter
sudo nixos-rebuild switch --show-trace --flake
