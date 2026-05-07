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

  cfg = config.myOptions.codex;
in {
  options.myOptions.codex = {
    enable = mkEnableOption "OpenAI Codex CLI coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      codex
    ];
  };
}
