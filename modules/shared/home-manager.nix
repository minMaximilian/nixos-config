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
