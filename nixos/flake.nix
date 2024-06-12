{
  description = "henriquelay's nixos configuration";
  
  inputs.hyprland.url = "github:hyprwm/Hyprland";

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations."acad-router" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
