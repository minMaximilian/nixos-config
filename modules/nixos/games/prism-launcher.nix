{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.prismLauncher;
  minecraftNativeLibs = import ../../../lib/minecraft-libraries.nix {
    inherit pkgs;
    withUdev = true;
  };
  minecraftDev = pkgs.writeShellScriptBin "minecraft-dev" ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath minecraftNativeLibs}:''${LD_LIBRARY_PATH:-}"
    export JAVA_HOME="${pkgs.temurin-bin-21.home}"
    export JAVA_TOOL_OPTIONS="-Dorg.lwjgl.glfw.libname=libglfw.so ''${JAVA_TOOL_OPTIONS:-}"

    if [ "$#" -eq 0 ]; then
      exec ${pkgs.bashInteractive}/bin/bash
    fi

    exec "$@"
  '';
in {
  options.myOptions.prismLauncher = {
    enable = mkEnableOption "Prism Launcher";
  };

  config = mkIf cfg.enable {
    programs.java = {
      enable = true;
      package = pkgs.temurin-bin-21;
    };

    environment.systemPackages = [
      minecraftDev
      pkgs.zenity
    ];
  };
}
