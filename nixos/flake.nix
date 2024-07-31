{
  description = "henriquelay's nixos configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    stylix.url = "github:danth/stylix/release-24.05";
  };

  outputs = {
    nixpkgs,
    stylix,
    # hyprland,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    nixosConfigurations."acad-router" = nixpkgs.lib.nixosSystem {
      # specialArgs = {inherit inputs;}; # somehow important
      modules = [
        # {
        #   nixpkgs.overlays = [
        #     (final: prev: {
        #       #       # unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        #       #       # If unfree is needed
        #       #       unstable = import nixpkgs-unstable {
        #       #         inherit system;
        #       #         config.allowUnfree = true;
        #       #       };
        #       hyprland = hyprland.packages.${prev.system};
        #       hyprland-pkgs = hyprland.inputs.nixpkgs.legacyPackages.${prev.system};
        #     })
        #   ];
        # }
        stylix.nixosModules.stylix
        ./configuration.nix
      ];
    };
  };
}
