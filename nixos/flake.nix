{
  description = "henriquelay's nixos configuration";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    nixpkgs,
    stylix,
    ...
  } @ inputs: {
    nixosConfigurations."acad-router" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        stylix.nixosModules.stylix
        ./configuration.nix
      ];
    };
  };
}
