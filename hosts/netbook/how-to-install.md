after booting, with flakes enabled

nix run github:nix-community/nixos-anywhere -- \
        --flake .#netbook \
        --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
        --target-host henriquelay@netbook

(@netbook is in hosts file)

From https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/
