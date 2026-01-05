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
    mkIf
    ;

  cfg = config.myOptions.zenBrowser;
  username = config.myOptions.vars.username;

  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "146.0";
    hash = "sha256-zGpfQk2gY6ifxIk1fvCk5g5SIFo+o8RItmw3Yt3AeCg=";
  };
in {
  options.myOptions.zenBrowser = {
    enable =
      mkEnableOption "Zen browser with custom configuration"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;

      profiles.${username} = {
        id = 0;
        name = username;
        isDefault = true;

        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
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
          "text/html" = ["zen.desktop"];
          "x-scheme-handler/http" = ["zen.desktop"];
          "x-scheme-handler/https" = ["zen.desktop"];
        };
      };
    };
  };
}
