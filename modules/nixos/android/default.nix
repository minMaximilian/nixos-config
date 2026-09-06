{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.android;

  android-fhs = pkgs.callPackage ../../../packages/android-fhs {};
in {
  options.myOptions.android = {
    enable = mkEnableOption "Android Studio and development tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      android-studio
      android-tools
      flutter
      jdk17
      jdk21
      android-fhs
    ];

    # Accept Android SDK licenses
    nixpkgs.config.android_sdk.accept_license = true;
  };
}
