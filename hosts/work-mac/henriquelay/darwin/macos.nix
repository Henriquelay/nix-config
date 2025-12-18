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
    # Add any other macOS-specific environment variables here
  };

  # macOS-specific home configurations
  home.file = {
    # Add macOS-specific dotfiles if needed
    # Example:
    # ".some-config".text = ''
    #   config content here
    # '';
  };

  # macOS-specific program configurations
  programs = {
    # Add any macOS-only program configurations here
  };
}
