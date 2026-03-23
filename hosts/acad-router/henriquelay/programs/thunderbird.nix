{ ... }:
{
  accounts.email.accounts = {
    gmail-primary = {
      primary = true;
      flavor = "gmail.com";
      address = "henriquelayber@gmail.com";
      realName = "Henrique Layber";
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };

    gmail-secondary = {
      flavor = "gmail.com";
      address = "riklaytech@gmail.com";
      realName = "RIKLAY";
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };

};

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "javascript.enabled" = false;
      };
    };
  };

}
