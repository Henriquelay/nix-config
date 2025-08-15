{
  description = "henriquelay's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nur = {
    #   url = "github:nix-community/NUR";
    # };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      # nur,
      disko,
      ...
    }
    # @inputs
    :
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations."netbook" = nixpkgs.lib.nixosSystem {

        inherit system;
        modules = [
          disko.nixosModules.disko

          # nur.modules.nixos.default

          ./configuration.nix
        ];
      };
    };
}
