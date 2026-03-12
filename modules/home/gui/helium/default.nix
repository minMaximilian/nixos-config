{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.helium;

  version = "0.8.5.1";

  helium = pkgs.appimageTools.wrapType2 {
    pname = "helium";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
      hash = "sha256-jFSLLDsHB/NiJqFmn8S+JpdM8iCy3Zgyq+8l4RkBecM=";
    };

    extraInstallCommands = let
      appimageContents = pkgs.appimageTools.extractType2 {
        inherit (helium) pname version src;
      };
    in ''
      install -Dm444 ${appimageContents}/helium.desktop -t $out/share/applications/
      install -Dm444 ${appimageContents}/helium.png -t $out/share/pixmaps/
      substituteInPlace $out/share/applications/helium.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=helium'
    '';

    meta = {
      description = "Private, fast, and honest web browser";
      homepage = "https://helium.computer";
      license = lib.licenses.gpl3;
      platforms = ["x86_64-linux"];
    };
  };
in {
  options.myOptions.helium = {
    enable = lib.mkEnableOption "Helium browser" // {default = config.myOptions.vars.withGui;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [helium];

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
