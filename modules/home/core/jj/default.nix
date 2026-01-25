{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.jj;
in {
  options.myOptions.jj = {
    enable = mkEnableOption "Jujutsu (jj) version control";
  };

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "53843385+minMaximilian@users.noreply.github.com";
          name = "minMaximilian";
        };
      };
    };
  };
}
