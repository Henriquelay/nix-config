{
  description = "Home manager for Henriquelay";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    stylix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    myuser = "henriquelay";
  in {
    homeConfigurations.${myuser} = home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      modules = [
        {nixpkgs.overlays = [nur.overlay];}

        (
          {pkgs, ...}: let
            nur-no-pkgs = import nur {
              nurpkgs = import nixpkgs {system = system;};
              inherit pkgs;
            };
          in {
            home.packages = [
              nur-no-pkgs.repos.nltch.spotify-adblock
            ];
          }
        )

        stylix.homeManagerModules.stylix

        ./home.nix
      ];
    };
  };
}
