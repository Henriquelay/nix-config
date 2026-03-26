{ ... }:
{
  accounts.email.accounts = {
    henriquelayber = {
      primary = true;
      flavor = "gmail.com";
      address = "henriquelayber@gmail.com";
      realName = "Henrique Layber";
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };

    riklaytech = {
      flavor = "gmail.com";
      address = "riklaytech@gmail.com";
      realName = "RIKLAY";
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };

    surt = {
      flavor = "gmail.com";
      address = "henrique.layber@surt.com";
      realName = "Henrique Layber";
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

        # Block remote content in messages
        "mailnews.message_display.disable_remote_image" = true;
        "permissions.default.image" = 2; # Block all images not from original server

        # Render messages as simple HTML (blocks remote content loading)
        "mailnews.display.html_as" = 0;
        "mailnews.display.html_sanitizer.drop_media" = false;

        # Disable link clicking - open nothing externally
        "network.protocol-handler.external-default" = false;
        "network.protocol-handler.expose-all" = false;
        "network.protocol-handler.warn-external-default" = true;

        # Disable Thunderbird's built-in web browsing capabilities
        "network.protocol-handler.external.http" = false;
        "network.protocol-handler.external.https" = false;

        # Disable prefetch and speculative connections
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.http.speculative-parallel-limit" = 0;

        # Disable telemetry and update checks
        "app.update.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;

        # Disable RSS/feed fetching
        "rss.display.prefer_plaintext" = true;

        # Disable chat/messaging protocols
        "mail.chat.enabled" = false;
      };
    };
  };

}
