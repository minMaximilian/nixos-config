{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.commet;

  commet = pkgs.stdenv.mkDerivation rec {
    pname = "commet";
    version = "0.4.0";

    src = pkgs.fetchurl {
      url = "https://github.com/commetchat/commet/releases/download/v${version}/commet-linux-portable-x64.tar.gz";
      hash = "sha256-rhGPU0uJuUFiQHTSNhRGtwARzEBUzxwNBGJ7S0U7COc=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs; [
      gtk3
      libepoxy
      mpv
      libass
      olm
      mesa
      libdrm
      glib
      cairo
      pango
      gdk-pixbuf
      harfbuzz
      fontconfig
      freetype
      libx11
      libxcursor
      libxrandr
      libxi
      libxext
      libxfixes
      libxcomposite
      libxdamage
      libxrender
      libxtst
      libxkbcommon
      webkitgtk_4_1
      libsoup_3
      alsa-lib
      libpulseaudio
      dbus
      at-spi2-atk
      stdenv.cc.cc.lib
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/commet
      cp -r bundle/* $out/opt/commet/

      chmod +x $out/opt/commet/commet

      mkdir -p $out/bin
      makeWrapper $out/opt/commet/commet $out/bin/commet \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      mkdir -p $out/share/applications
      cat > $out/share/applications/commet.desktop << EOF
      [Desktop Entry]
      Name=Commet
      Comment=A comfortable Matrix chat client
      Exec=$out/bin/commet
      Type=Application
      Categories=Network;Chat;InstantMessaging;
      EOF

      runHook postInstall
    '';

    meta = with lib; {
      description = "A comfortable Matrix chat client";
      homepage = "https://commet.chat";
      license = licenses.agpl3Only;
      platforms = ["x86_64-linux"];
    };
  };
in {
  options.myOptions.commet = {
    enable = mkEnableOption "Commet Chat";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [commet];
  };
}
