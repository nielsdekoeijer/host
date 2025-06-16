#!/usr/bin/env bash
set -exu 

# enter
sudo nixos-rebuild switch --flake /etc/nixos/#laptop-work-1
