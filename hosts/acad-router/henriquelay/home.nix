{
  config,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./stylix.nix
    # Imports the module `pkgs` with the `nur` overlay applied
    # It should work without this but idk why it doesn't
    (import ./programs.nix { inherit config pkgs; })
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "henriquelay";
    homeDirectory = "/home/henriquelay";
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05"; # Please read the comment before changing.
    sessionVariables = {
      # Hint electron apps to use Wayland
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      # Disable window decorator on QT applications
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      TERMINAL = "${pkgs.kitty}/bin/kitty";
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.gruvbox-dark-icons-gtk;
      name = "gruvbox-dark-gtl";
    };
  };

  xdg.desktopEntries = {
    virt-manager = {
      # Fix for virt-manager on wlr
      name = "Virtual Machine Manager (GDK_BACKEND=x11)";
      exec = "env GDK_BACKEND=x11 virt-manager";
      terminal = false;
      categories = [
        "Utility"
        "Emulator"
      ];
    };
  };
}
