#!/usr/bin/env bash
set -exu 

# install
sudo nixos-install --flake .#laptop-work-1
sudo chmod -R 775 /mnt/etc/nixos

