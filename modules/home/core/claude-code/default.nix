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

  cfg = config.myOptions.claude-code;
in {
  options.myOptions.claude-code = {
    enable = mkEnableOption "Claude Code CLI (configured manually with GLM Coding Plan via z.ai)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
    ];

    # NOTE: ~/.claude/settings.json is intentionally NOT managed by home-manager.
    # Configure it manually with the GLM Coding Plan env vars, e.g.:
    #
    # {
    #   "env": {
    #     "ANTHROPIC_AUTH_TOKEN": "<your z.ai api key>",
    #     "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    #     "API_TIMEOUT_MS": "3000000"
    #   }
    # }
    #
    # See: https://docs.z.ai/scenario-example/develop-tools/claude
  };
}
