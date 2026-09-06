{inputs, ...}: {
  imports = [./checks.nix];
  systems = [
    "x86_64-linux"
    # "aarch64-linux"
    # "aarch64-darwin"
    # "x86_64-darwin"
  ];

  perSystem = {
    pkgs,
    system,
    lib,
    ...
  }: {
    formatter = pkgs.alejandra;

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        nixd
      ];
    };

    # Minecraft mod development shell.
    # Run with: nix develop .#minecraft
    devShells.minecraft = let
      # jetbrains.idea is unfree, so use a pkgs instance that allows it.
      unfreePkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # Full (non-headless) JDK: the Minecraft client needs AWT.
      java = pkgs.jdk21;
      # Native libs LWJGL/GLFW dlopen at runtime; exposed via LD_LIBRARY_PATH.
      libs = import ../lib/minecraft-libraries.nix {
        inherit pkgs;
        withUdev = true;
      };
    in
      pkgs.mkShell {
        nativeBuildInputs = [
          java
          pkgs.git
          pkgs.zenity
          unfreePkgs.jetbrains.idea
        ];

        buildInputs = libs;

        env = {
          LD_LIBRARY_PATH = lib.makeLibraryPath libs;
          JAVA_HOME = "${java.home}";
          # Force LWJGL to load the wayland-capable glfw from LD_LIBRARY_PATH
          # instead of its bundled copy (fixes GLFW 0x1000E platform detection).
          JAVA_TOOL_OPTIONS = "-Dorg.lwjgl.glfw.libname=libglfw.so";
        };
      };
  };
}
