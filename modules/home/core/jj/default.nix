{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.jj;
  vars = config.myOptions.vars;
in {
  options.myOptions.jj = {
    enable = mkEnableOption "Jujutsu (jj) version control";
  };

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = vars.gitEmail;
          name = vars.gitName;
        };
      };
    };
  };
}
