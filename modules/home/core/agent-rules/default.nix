{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.agentRules;

  instructions = builtins.readFile ./instructions.md;
in {
  options.myOptions.agentRules.enable =
    lib.mkEnableOption "shared global instructions for coding agents";

  config = lib.mkIf cfg.enable {
    home.file.".codex/AGENTS.md".text = instructions;
  };
}
