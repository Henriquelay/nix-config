{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Henriquelay";
    userEmail = "37563861+Henriquelay@users.noreply.github.com";
    signing = {
      key = "B3903EAC57AD1331995CD96202843DDA217C9D81";
      signByDefault = true;
    };
    aliases = {
      sw = "switch";
      br = "branch";
      co = "checkout";
      st = "status";
    };
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  programs.lazygit = {
    enable = false;
  };
}
