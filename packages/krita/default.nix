{
  appimageTools,
  fetchurl,
}: let
  krita = let
    pname = "krita";
    version = "5.3.2.1";
    src = fetchurl {
      url = "https://download.kde.org/stable/krita/${version}/krita-${version}-x86_64.AppImage";
      hash = "sha256-2UCS2qoa1CPYKnKX4LMcriz9zQ0GWVt/UPhGt2w7Puc=";
    };
    appimageContents = appimageTools.extractType2 {inherit pname version src;};
  in
    appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        mkdir -p $out/share
        cp -r ${appimageContents}/usr/share/{applications,icons} $out/share/
      '';
    };
in
  krita
