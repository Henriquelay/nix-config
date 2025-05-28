{ config, pkgs, ... }:
{
  stylix.targets.librewolf = {
    profileNames = [ "default" ];
  };
  programs.librewolf = {
    settings = {
      "webgl.disabled" = false;
      "identity.fxaccounts.enabled" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheetums" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
      "privacy.donottrackheader.enabled" = true;
      "privacy.fingerprintingProtection" = true;
      "privacy.resistFingerprinting" = true;
      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.fingerprinting.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
    };
  };
} 
