{
  pkgs,
  withUdev ? false,
}:
with pkgs;
  [libGL glfw3-minecraft libpulseaudio openal]
  ++ lib.optional withUdev udev
  ++ [wayland libxkbcommon]
