{
  description = "henriquelay's macOS (nix-darwin) configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: nur if needed on macOS
    # nur.url = "github:nix-community/NUR";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      helix,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "henriquelay";
    in
    {
      darwinConfigurations."PLAT-LT-085" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          helix-flake = helix;
        };
        modules = [
          home-manager.darwinModules.home-manager

          ./darwin-configuration.nix
        ];
      };
    };
}
