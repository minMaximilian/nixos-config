{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.myOptions.git;
in {
  options.myOptions.git = {
    enable = mkEnableOption "Git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
      signing.format = "openpgp";
      settings = {
        core = {
          editor = "nvim";
        };
        push = {
          autoSetupRemote = true;
        };
      };
    };
  };
}
