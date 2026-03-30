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
    version = "0.17.0";

    src = pkgs.fetchurl {
      url = "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases/download/v0.17.0/Deadlock.Mod.Manager_0.17.0_amd64.deb";
      hash = "sha256-w0JuMgCrAIbrrw0o+5jauD+ADUi7bqQfPWCIsPnfEEg=";
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
