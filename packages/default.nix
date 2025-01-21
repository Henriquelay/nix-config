let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in
{
  notekit = pkgs.callPackage ./notekit.nix { };
  #clatexmath = pkgs.callPackage ./clatexmath.nix {};
  factorio_achievements_enabler = pkgs.callPackage ./factorio_achievements_enabler.nix { };
  siphash = pkgs.callPackage ./siphash.nix { };
}
