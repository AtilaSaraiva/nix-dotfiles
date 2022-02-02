#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused gnupg common-updater-scripts

versions="$(curl -s --show-error "https://api.github.com/repos/CyberShadow/btdu/releases/latest" | jq -r '.tag_name' | tail -c +2)"

src

sha256=$(nix-prefetch-url --type sha256
