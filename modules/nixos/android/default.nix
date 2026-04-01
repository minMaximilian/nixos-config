{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.android;
  username = config.myOptions.vars.username;

  android-fhs = pkgs.buildFHSEnv {
    name = "android-fhs";
    targetPkgs = pkgs:
      with pkgs; [
        android-studio
        android-tools
        flutter
        jdk17
        jdk21
        glibc
        zlib
        libGL
        mesa
        nss
        nspr
        expat
        libdrm
        freetype
        fontconfig
        pulseaudio
        libpng
        ncurses5
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
        libsm
        libice
        vulkan-loader
      ];
    runScript = "bash";
    extraBwrapArgs = [
      "--dev-bind"
      "/dev/kvm"
      "/dev/kvm"
    ];
    profile = ''
      export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
      export ANDROID_HOME="$HOME/Android/Sdk"
    '';
  };
in {
  options.myOptions.android = {
    enable = mkEnableOption "Android Studio and development tools";
  };

  config = mkIf cfg.enable {
    # KVM access for Android emulator
    users.users.${username}.extraGroups = ["kvm"];

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
