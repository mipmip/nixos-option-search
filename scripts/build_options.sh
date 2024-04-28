#!/usr/bin/env sh

# Copyright 2024 Pim Snel <post@pimsnel.com>
# License: MIT

if [ -z $RELEASE ]; then
  RELEASE=master
fi

echo "building NixOS options from ${RELEASE}"

nix run github:NixOS/nixos-search#flake-info -- --json nixpkgs ${RELEASE} > ./data/flake-nixos-${RELEASE}.json

ls -al ./data
rm -f ./static/data/options-release-${RELEASE}.json
ruby ./scripts/parse_options-json.rb
