#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Step 1: Partitioning and formatting with Disko ==="
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko "$SCRIPT_DIR/disk-config.nix"

echo "=== Step 2: Installing NixOS ==="
sudo nixos-install --flake "$SCRIPT_DIR#acad-router" --no-channel-copy

echo "=== Done! Set BIOS to boot from nvme0n1, then reboot. ==="
