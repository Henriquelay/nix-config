# from https://github.com/cpu/rust-flake

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          config,
          self',
          pkgs,
          lib,
          system,
          ...
        }:
        let
          # Package dependencies
          runtimeDepsCore = with pkgs; [ ];
          buildDepsCore = with pkgs; [
            # pkg-config # used with -sys crates
            rustPlatform.bindgenHook
          ];
          runtimeDepsGUI = with pkgs; [ ];
          buildDepsGUI = with pkgs; [
            # pkg-config # used with -sys crates
            rustPlatform.bindgenHook
          ];
          devDeps = with pkgs; [
            gdb
            rust-analyzer
            cargo-flamegraph
          ];

          cargoTomlCore = builtins.fromTOML (builtins.readFile ./bitfy-agent-core/Cargo.toml);
          cargoTomlGUI = builtins.fromTOML (builtins.readFile ./bitfy-agent-desktop/Cargo.toml);
          msrvCore = cargoTomlCore.package.rust-version;
          msrvGui = cargoTomlGUI.package.rust-version;

          rustPackageCore =
            features:
            (pkgs.makeRustPlatform {
              cargo = pkgs.rust-bin.stable.latest.minimal;
              rustc = pkgs.rust-bin.stable.latest.minimal;
            }).buildRustPackage
              {
                inherit (cargoTomlCore.package) name version;
                src = ./bitfy-agent-core;
                cargoLock.lockFile = ./bitfy-agent-core/Cargo.lock;
                buildFeatures = features;
                buildInputs = runtimeDepsCore;
                nativeBuildInputs = buildDepsCore;
                # Uncomment if cargo tests require networking or otherwise
                # don't play nicely with the Nix build sandbox:
                # doCheck = false;
              };

          rustPackageGUI =
            features:
            (pkgs.makeRustPlatform {
              cargo = pkgs.rust-bin.stable.latest.minimal;
              rustc = pkgs.rust-bin.stable.latest.minimal;
            }).buildRustPackage
              {
                inherit (cargoTomlGUI.package) name version;
                src = ./bitfy-agent-desktop;
                cargoLock.lockFile = ./bitfy-agent-desktop/Cargo.lock;
                buildFeatures = features;
                buildInputs = runtimeDepsGUI;
                nativeBuildInputs = buildDepsGUI;
                # Uncomment if cargo tests require networking or otherwise
                # don't play nicely with the Nix build sandbox:
                # doCheck = false;
              };

          mkDevShell =
            rustc:
            pkgs.mkShell {
              shellHook = ''
                export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
              '';
              buildInputs = runtimeDepsCore ++ runtimeDepsGUI;
              nativeBuildInputs = buildDepsCore ++ buildDepsGUI ++ devDeps ++ [ rustc ];
            };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };

          packages.default = self'.packages.core;
          devShells.default = self'.devShells.stable;

          # No features used so far
          packages.core = (rustPackageCore "");
          packages.gui = (rustPackageGUI "");

          devShells.nightly = (
            mkDevShell (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
          );
          devShells.stable = (mkDevShell pkgs.rust-bin.stable.latest.default);
          devShells.msrv = (mkDevShell pkgs.rust-bin.stable.${msrvCore}.default);
        };
    };
}
