{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {};
    backupFileExtension = "bak";
  };

  home-manager.users.max = {pkgs, ...}: {
    programs.home-manager.enable = true;

    home = {
      username = "max";
      homeDirectory = "/home/max";
      stateVersion = "24.11";

      sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
        NIXPKGS_ALLOW_UNFREE = "1";

        NIXOS_OZONE_WL = "1";
        BROWSER = "firefox";
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        XDG_SESSION_TYPE = "wayland";
      };

      packages = with pkgs; [
      ];
    };

    xdg = {
      enable = true;
      mimeApps.enable = true;
    };
  };
}
