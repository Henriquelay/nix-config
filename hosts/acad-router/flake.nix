{
  description = "henriquelay's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

    disko = {
      url = "github:nix-community/disko";
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
      disko,
      # ucodenix,
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
          inherit system;
          specialArgs = {
            helix-flake = helix;
          };
          modules = [
            nur.modules.nixos.default

            home-manager.nixosModules.home-manager

            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  # Custom packages overlay
                  (final: prev: {
                    fae_linux = final.callPackage ../../packages/factorio_achievements_enabler.nix { };
                    helix-assist = final.callPackage ../../packages/helix-assist.nix { };
                    monochrome = final.callPackage ../../packages/monochrome.nix { };
                    bambu-studio = prev.appimageTools.wrapType2 rec {
                      name = "BambuStudio";
                      pname = "bambu-studio";
                      version = "02.04.00.70";
                      ubuntu_version = "24.04_PR-8834";

                      src = prev.fetchurl {
                        url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-${ubuntu_version}.AppImage";
                        sha256 = "sha256:26bc07dccb04df2e462b1e03a3766509201c46e27312a15844f6f5d7fdf1debd";
                      };

                      profile = ''
                        export SSL_CERT_FILE="${prev.cacert}/etc/ssl/certs/ca-bundle.crt"
                        export GIO_MODULE_DIR="${prev.glib-networking}/lib/gio/modules/"
                      '';

                      extraPkgs =
                        pkgs: with pkgs; [
                          cacert
                          glib
                          glib-networking
                          gst_all_1.gst-plugins-bad
                          gst_all_1.gst-plugins-base
                          gst_all_1.gst-plugins-good
                          webkitgtk_4_1
                        ];
                    };
                  })
                ];
              }
            )

            # ucodenix.nixosModules.default

            stylix.nixosModules.stylix

            ./configuration.nix
          ];
        };
      };
    };
}
