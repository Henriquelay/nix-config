{
  description = "henriquelay's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # hyprland.url = "github:hyprwm/Hyprland";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # stylix.url = "github:danth/stylix/release-24.05";
    stylix.url = "github:danth/stylix";
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ucodenix.url = "github:e-tho/ucodenix";
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    {
      nixpkgs,
      stylix,
      home-manager,
      nur,
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
      nixosConfigurations."acad-router" = nixpkgs.lib.nixosSystem {
        # specialArgs = { inherit inputs; }; # this is the important part (hyprland)
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = true;
            };
          }

          # ucodenix.nixosModules.default

          nur.modules.nixos.default

          stylix.nixosModules.stylix
          ./configuration.nix
        ];
      };
    };
}
