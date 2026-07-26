{
  config,
  inputs ? {},
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.myOptions.impeccable;
  hasImpeccable = inputs ? impeccable;
  skill = "${inputs.impeccable}/.agents/skills/impeccable";
in {
  options.myOptions.impeccable.enable =
    mkEnableOption "Impeccable agent skill";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasImpeccable;
        message = "myOptions.impeccable requires inputs.impeccable";
      }
    ];

    home.file = {
      ".agents/skills/impeccable".source = skill;
      ".codex/skills/impeccable".source = skill;
      ".codex/commands/impeccable.toml".text = ''
        description = "Use Impeccable for frontend design, critique, audit, polish, or UI improvement"
        prompt = "Use the impeccable skill. Treat this as the /impeccable arguments: {{args}}"
      '';
    };
  };
}
