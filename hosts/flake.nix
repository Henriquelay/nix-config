{
  description = "henriquelay's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # hyprland.url = "github:hyprwm/Hyprland";
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
  };

  outputs =
    {
      nixpkgs,
      stylix,
      home-manager,
      nur,
      helix,
      # ucodenix,
      # hyprland,
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
          # specialArgs = { inherit inputs; }; # this is the important part (hyprland)
          inherit system;
          specialArgs = {
            helix-flake = helix;
          };
          modules = [
            nur.modules.nixos.default

            home-manager.nixosModules.home-manager

            # ucodenix.nixosModules.default

            stylix.nixosModules.stylix

            ./acad-router/configuration.nix
          ];
        };
        "netbook" = nixpkgs.lib.nixosSystem {

          inherit system;
          modules = [
            nur.modules.nixos.default

            ./netbook/configuration.nix
          ];
        };
      };
    };
}
