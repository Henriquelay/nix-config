{
  description = "henriquelay's nixos configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    stylix.url = "github:danth/stylix/release-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs @ {
    nixpkgs,
    stylix,
    home-manager,
    nur,
    # hyprland,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations."acad-router" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }

        nur.nixosModules.nur

        stylix.nixosModules.stylix
        ./configuration.nix
      ];
    };
  };
}
