{
  config,
  lib,
  pkgs,
  localPackages,
  ...
}: let
  cfg = config.myOptions.helium;
  heliumWithExtensions = localPackages.helium;

  urlPrivacy = config.myOptions.urlPrivacy.package;
  openPrivateUrl = pkgs.writeShellScript "open-private-url" ''
    if [ "$#" -eq 0 ]; then
      exec ${heliumWithExtensions}/bin/helium
    fi

    exec ${urlPrivacy}/bin/url-privacy open \
      --browser ${heliumWithExtensions}/bin/helium \
      "$1"
  '';
in {
  options.myOptions.helium = {
    enable = lib.mkEnableOption "Helium browser";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [heliumWithExtensions];

    xdg.desktopEntries.helium = {
      name = "Browser";
      genericName = "Web Browser";
      exec = "${openPrivateUrl} %u";
      icon = "helium";
      terminal = false;
      categories = ["Network" "WebBrowser"];
      mimeType = ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "helium.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "x-scheme-handler/about" = "helium.desktop";
        "x-scheme-handler/unknown" = "helium.desktop";
      };
    };
  };
}
