{
  config,
  lib,
  pkgs,
  localPackages,
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
    home.packages = [
      localPackages.codex
    ];

    home.activation.configureCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
      config_file="$HOME/.codex/config.toml"

      run mkdir -p "$HOME/.codex"
      run touch "$config_file"
      run ${pkgs.perl}/bin/perl -0pi -e '
        s/^(?:approval_policy|sandbox_mode)\s*=.*\n//mg;
        s/\n?\[plugins\."impeccable\@personal"\]\n(?:[^\[]*\n?)//g;
        s/\n?\[plugins\."impeccable\@impeccable"\]\n(?:[^\[]*\n?)//g;
        s/\n?\[marketplaces\.impeccable\]\n(?:[^\[]*\n?)//g;
        $_ = qq{approval_policy = "never"\nsandbox_mode = "workspace-write"\n\n} . $_;
      ' "$config_file"

    '';
  };
}
