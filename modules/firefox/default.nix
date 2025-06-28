{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.myOptions.firefox;

  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "131.0";
    hash = "sha256-CxPZxo9G44lRocNngjfwTBHSqL5dEJ5MNO5Iauoxp2Y=";
  };
in {
  options.myOptions.firefox = {
    enable =
      mkEnableOption "Firefox browser with custom configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {osConfig, ...}: {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;

        profiles.${config.myOptions.vars.username} = {
          id = 0;
          name = config.myOptions.vars.username;
          isDefault = true;

          extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            bitwarden
            sponsorblock
            ublock-origin
          ];

          bookmarks = {
            force = true;
            settings = import ./bookmarks.nix;
          };
          search = import ./search.nix;
          settings = import ./settings.nix {inherit lib;};

          extraConfig = ''
            ${builtins.readFile "${betterfox}/Fastfox.js"}
            ${builtins.readFile "${betterfox}/Peskyfox.js"}
            ${builtins.readFile "${betterfox}/Securefox.js"}
            ${builtins.readFile "${betterfox}/Smoothfox.js"}

            user_pref("extensions.formautofill.addresses.enabled", false);
            user_pref("extensions.formautofill.creditCards.enabled", false);
            user_pref("dom.security.https_only_mode_pbm", true);
            user_pref("identity.fxaccounts.enabled", false);
            user_pref("browser.tabs.firefox-view-next", false);
            user_pref("privacy.sanitize.sanitizeOnShutdown", false);
          '';
        };
      };

      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = ["firefox.desktop"];
            "x-scheme-handler/http" = ["firefox.desktop"];
            "x-scheme-handler/https" = ["firefox.desktop"];
          };
        };
      };
    };
  };
}
