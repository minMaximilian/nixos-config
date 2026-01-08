{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.zellij;
in {
  options.myOptions.zellij = {
    enable = lib.mkEnableOption "Zellij (headless session persistence)";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        default_mode = "locked";
        default_layout = "compact";
        pane_frames = false;
        on_force_close = "detach";
        mouse_mode = false;
        ui = {
          pane_frames = {
            hide_session_name = true;
          };
        };
        keybinds = {
          _props = {
            clear-defaults = true;
          };
          locked = {
            "bind \"Ctrl q\"" = {
              Detach = {};
            };
          };
        };
      };
    };
  };
}
