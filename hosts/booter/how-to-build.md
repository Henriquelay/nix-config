export NIX_PATH=nixos-config=$PWD/iso.nix:nixpkgs=channel:nixos-25.05
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage
