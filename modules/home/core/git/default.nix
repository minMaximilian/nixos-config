{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.git;
in {
  options.myOptions.git = {
    enable =
      mkEnableOption "Git"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          email = "53843385+minMaximilian@users.noreply.github.com";
          name = "minMaximilian";
        };
        core = {
          editor = "nvim";
        };
      };
    };
  };
}
