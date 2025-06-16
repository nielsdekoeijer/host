#!/usr/bin/env bash
set -exu 

# format disk
sudo nix --extra-experimental-features nix-command flakes run github:nix-community/disko -- --mode zap_create_mount ./systems/laptop/disko.nix

