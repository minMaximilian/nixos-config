{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.myOptions.git;
  vars = config.myOptions.vars;
in {
  options.myOptions.git = {
    enable = mkEnableOption "Git";

    hooks = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable global git hooks";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
      signing.format = "openpgp";
      settings = {
        user = {
          email = vars.gitEmail;
          name = vars.gitName;
        };
        core = {
          editor = "nvim";
        };
        push = {
          autoSetupRemote = true;
        };
      };
    };

    # Enable git hooks module when hooks are enabled
    myOptions.git-hooks.enable = lib.mkIf cfg.hooks.enable true;
  };
}
