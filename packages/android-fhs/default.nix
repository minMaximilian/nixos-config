{buildFHSEnv}:
buildFHSEnv {
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
}
