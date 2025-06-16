#!/usr/bin/env bash
set -exu 

# mkdir the nixos folder
sudo mkdir -p /mnt/etc/nixos
sudo cp -r * /mnt/etc/nixos
cd /mnt/etc/nixos
