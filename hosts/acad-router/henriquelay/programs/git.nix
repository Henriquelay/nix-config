{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Henriquelay";
      userEmail = "37563861+Henriquelay@users.noreply.github.com";
      delta = {
        enable = true;
        options = {
          hyperlinks = true;
        };
      };
      signing = {
        key = "B3903EAC57AD1331995CD96202843DDA217C9D81";
        signByDefault = true;
      };
      aliases = {
        sw = "switch";
        br = "branch";
        co = "checkout";
        st = "status";
        hs = "log --pretty='%C(yellow)%h %Cblue%aN %C(cyan)%cd%C(auto)%d %Creset%s' --graph --date=relative --date-order";
      };
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };

    lazygit.enable = false;

    gitui = {
      enable = false;
    };
  };
}
