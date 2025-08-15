{
  description = "henriquelay's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ucodenix.url = "github:e-tho/ucodenix";
    nur = {
      url = "github:nix-community/NUR";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      stylix,
      home-manager,
      nur,
      helix,
      disko,
      # ucodenix,
      ...
    }
    # @inputs
    :
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        "acad-router" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            helix-flake = helix;
          };
          modules = [
            nur.modules.nixos.default

            home-manager.nixosModules.home-manager

            # ucodenix.nixosModules.default

            stylix.nixosModules.stylix

            ./configuration.nix
          ];
        };
      };
    };
}
