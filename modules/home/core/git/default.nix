{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.git;
  vars = config.myOptions.vars;
in {
  options.myOptions.git = {
    enable = mkEnableOption "Git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          email = vars.gitEmail;
          name = vars.gitName;
        };
        core = {
          editor = "nvim";
        };
      };
    };
  };
}
