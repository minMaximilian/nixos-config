{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.deadlockModManager;

  deadlock-mod-manager = pkgs.appimageTools.wrapType2 {
    pname = "deadlock-mod-manager";
    version = "0.15.0";

    src = pkgs.fetchurl {
      url = "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases/download/v0.15.0/Deadlock.Mod.Manager_0.15.0_amd64.AppImage";
      hash = "sha256-eW1MPf72G+qEHBjImjMD308IhGrAvxLDiZjtH75JGuc=";
    };

    extraPkgs = pkgs:
      with pkgs; [
        webkitgtk_4_1
        libsoup_3
        openssl
      ];
  };
in {
  options.myOptions.deadlockModManager = {
    enable = mkEnableOption "Deadlock Mod Manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [deadlock-mod-manager];
  };
}
