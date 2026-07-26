{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.krita;
  krita = let
    pname = "krita";
    version = "5.3.2.1";
    src = pkgs.fetchurl {
      url = "https://download.kde.org/stable/krita/${version}/krita-${version}-x86_64.AppImage";
      hash = "sha256-2UCS2qoa1CPYKnKX4LMcriz9zQ0GWVt/UPhGt2w7Puc=";
    };
    appimageContents = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in
    pkgs.appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        mkdir -p $out/share
        cp -r ${appimageContents}/usr/share/{applications,icons} $out/share/
      '';
    };
in {
  options.myOptions.krita = {
    enable = mkEnableOption "Krita digital painting application";
  };

  config = mkIf cfg.enable {
    home.packages = [krita];
  };
}
