#!/usr/bin/env bash

git ls-files --cached --others --exclude-standard -z '*.nix' | xargs -0 nixfmt
