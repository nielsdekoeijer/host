#!/usr/bin/env bash
set -exu

nix build .#iso
