{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.nautilus;
in {
  options.myOptions.nautilus = {
    enable = lib.mkEnableOption "Nautilus file manager" // {default = config.myOptions.vars.withGui;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      file-roller # archive support
    ];

    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-hidden-files = true;
      };
    };

    xdg.desktopEntries.nautilus = {
      name = "Files";
      genericName = "File Manager";
      exec = "nautilus %U";
      icon = "org.gnome.Nautilus";
      terminal = false;
      categories = ["System" "FileManager"];
      mimeType = ["inode/directory"];
    };
  };
}
