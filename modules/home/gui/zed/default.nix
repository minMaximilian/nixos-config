{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.zed;
in {
  options.myOptions.zed = {
    enable = lib.mkEnableOption "Zed Editor";
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extraPackages = [pkgs.nil];
      # Symlink the remote server binary (essential for WSL remote)
      installRemoteServer = true;

      userKeymaps = [
        {
          context = "Editor && vim_mode == normal";
          bindings = {
            "space f" = "file_finder::Toggle";
            "space y" = "editor::Copy";
          };
        }
        {
          context = "Editor && vim_mode == visual";
          bindings = {
            "space y" = "editor::Copy";
          };
        }
      ];
    };
  };
}
