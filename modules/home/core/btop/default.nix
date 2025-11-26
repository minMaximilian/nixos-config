{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.btop;
in {
  options.myOptions.btop = {
    enable =
      mkEnableOption "btop system monitor"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = true;
        graph_symbol = "braille";
        update_ms = 1000;
      };
    };
  };
}
