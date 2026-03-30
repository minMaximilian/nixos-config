{
  config,
  lib,
  pkgs,
  inputs ? {},
  ...
}: let
  cfg = config.myOptions.helium;
  hasHelium = inputs ? helium;
  heliumPkg =
    if hasHelium
    then inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    else null;
in {
  options.myOptions.helium = {
    enable = lib.mkEnableOption "Helium browser" // {default = config.myOptions.vars.withGui;};
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hasHelium;
        message = "myOptions.helium requires inputs.helium (github:AlvaroParker/helium-nix)";
      }
    ];

    home.packages = [heliumPkg];

    xdg.desktopEntries.helium = {
      name = "Browser";
      genericName = "Web Browser";
      exec = "helium %U";
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
