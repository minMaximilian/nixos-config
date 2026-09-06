{
  lib,
  pkgs,
  jetbrains,
  symlinkJoin,
  makeWrapper,
  package,
  plugins ? [],
}: let
  pluggedPackage =
    if plugins == []
    then package
    else jetbrains.plugins.addPlugins package plugins;
  minecraftNativeLibs = import ../../lib/minecraft-libraries.nix {inherit pkgs;};
in
  symlinkJoin {
    name = "${pluggedPackage.name}-mc-wrapped";
    paths = [pluggedPackage];
    nativeBuildInputs = [makeWrapper];
    # Child Gradle and Minecraft processes inherit the Wayland-capable GLFW.
    postBuild = ''
      for b in idea-oss idea idea-community idea-ultimate; do
        if [ -e "$out/bin/$b" ]; then
          wrapProgram "$out/bin/$b" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath minecraftNativeLibs}" \
            --set-default JAVA_TOOL_OPTIONS "-Dorg.lwjgl.glfw.libname=libglfw.so"
        fi
      done
    '';
  }
