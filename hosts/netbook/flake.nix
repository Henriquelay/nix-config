{
  description = "henriquelay's nixos configuration";

  # Secrets management with sops-nix:
  # - Edit secrets: nix run nixpkgs#sops -- hosts/netbook/secrets.yaml
  # - View decrypted: nix run nixpkgs#sops -- -d hosts/netbook/secrets.yaml
  # - Update keys after adding machines: nix run nixpkgs#sops -- updatekeys hosts/netbook/secrets.yaml

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nur = {
    #   url = "github:nix-community/NUR";
    # };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      # nur,
      disko,
      copyparty,
      sops-nix,
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

          sops-nix.nixosModules.sops

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
