{
  config,
  pkgs,
  lib,
  ...
}:
{
  # macOS-specific session variables
  home.sessionVariables = {
    TZ = "America/Sao_Paulo";
  };

  # Sync nix apps to ~/Applications for Spotlight indexing
  # This is a workaround for mac-app-util being unavailable due to ECL build failure
  home.activation.copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app_dir="$HOME/Applications/Nix Apps"
    run rm -rf "$app_dir"
    run mkdir -p "$app_dir"

    find "${config.home.homeDirectory}/.nix-profile/Applications" -maxdepth 1 -name "*.app" -type l 2>/dev/null | while read -r app; do
      app_name=$(basename "$app")
      run cp -rL "$app" "$app_dir/$app_name"
    done
  '';

  # macOS-specific program configurations
  programs = {
  };
}
