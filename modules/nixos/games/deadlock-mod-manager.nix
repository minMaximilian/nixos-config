{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.deadlockModManager;

  deadlock-mod-manager = pkgs.stdenv.mkDerivation {
    pname = "deadlock-mod-manager";
    version = "0.18.0";

    src = pkgs.fetchurl {
      url = "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases/download/v0.18.0/Deadlock.Mod.Manager_0.18.0_amd64.deb";
      hash = "sha256-zXkAQNk9eVCyXt3qtSfsUEjyi+h7n335EysW9YoLEJk=";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      wrapGAppsHook4
    ];

    buildInputs = with pkgs; [
      webkitgtk_4_1
      libsoup_3
      openssl
      glib-networking
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp -r usr/* $out/

      runHook postInstall
    '';
  };
in {
  options.myOptions.deadlockModManager = {
    enable = mkEnableOption "Deadlock Mod Manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [deadlock-mod-manager];
  };
}
