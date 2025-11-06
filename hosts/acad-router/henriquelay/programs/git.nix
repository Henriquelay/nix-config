{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      signing = {
        key = "B3903EAC57AD1331995CD96202843DDA217C9D81";
        signByDefault = true;
      };
      settings = {
        user = {
          name = "Henriquelay";
          email = "37563861+Henriquelay@users.noreply.github.com";
        };
        alias = {
          sw = "switch";
          br = "branch";
          co = "checkout";
          st = "status";
          hs = "log --pretty='%C(yellow)%h %Cblue%aN %C(cyan)%cd%C(auto)%d %Creset%s' --graph --date=relative --date-order";
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };

    # Better diff viewer
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        hyperlinks = true;
      };
    };

    gh.enable = true; # GitHub CLI

    gh-dash.enable = true; # Github
    lazygit.enable = true;

    gitui = {
      enable = false;
    };
  };
}
