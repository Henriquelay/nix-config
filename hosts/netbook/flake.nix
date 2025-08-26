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
    copyparty.url = "github:9001/copyparty";

  };

  outputs =
    {
      nixpkgs,
      # nur,
      disko,
      copyparty,
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

          copyparty.nixosModules.default
          (
            { pkgs, ... }:
            {
              # add the copyparty overlay to expose the package to the module
              nixpkgs.overlays = [ 
                copyparty.overlays.default 
                # Custom packages overlay
                (final: prev: {
                  linkredirbot = final.callPackage ../../packages/linkredirbot.nix { };
                  mediaarchivistbot = final.callPackage ../../packages/mediaarchivistbot.nix { };
                })
              ];
            }
          )

          # nur.modules.nixos.default

          ./configuration.nix
        ];
      };
    };
}
