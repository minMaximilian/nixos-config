{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.amp;
in {
  options.myOptions.amp = {
    enable = mkEnableOption "amp CLI tool";
  };

  config = mkIf cfg.enable {
    home.sessionPath = ["$HOME/.amp/bin"];

    home.packages = with pkgs; [
      amp-cli
    ];

    xdg.configFile."amp/settings.json".text = builtins.toJSON {
      "amp.gauge" = "tokens";
    };

    xdg.configFile."amp/plugins/impeccable.ts".text = builtins.readFile ./impeccable.ts;
  };
}
