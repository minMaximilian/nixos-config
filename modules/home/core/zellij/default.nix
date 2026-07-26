{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.zellij;
  nvim = "${config.home.profileDirectory}/bin/nvim";
in {
  options.myOptions.zellij = {
    enable = lib.mkEnableOption "Zellij (headless session persistence)";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        default_mode = "normal";
        default_layout = "compact";
        pane_frames = false;
        on_force_close = "detach";
        mouse_mode = false;
        session_serialization = true;
        show_startup_tips = false;
        show_release_notes = false;
        scrollback_editor = nvim;
        ui = {
          pane_frames = {
            hide_session_name = true;
          };
        };
        keybinds = {
          normal = {
            "bind \"Alt e\"" = {
              EditScrollback = {};
            };
          };
          pane = {
            "bind \"c\"" = {
              CloseFocus = {};
            };
          };
          tab = {
            "bind \"c\"" = {
              CloseTab = {};
            };
          };
        };
      };
    };
  };
}
