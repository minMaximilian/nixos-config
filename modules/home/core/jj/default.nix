{
  lib,
  localPackages,
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
      package = localPackages.jujutsu;
      settings = {
        user = {
          email = config.programs.git.settings.user.email;
          name = config.programs.git.settings.user.name;
        };
        ui = {
          editor = "nvim";
        };
        git = {
          push = "origin";
        };
        remotes.origin.auto-track-bookmarks = "*";
      };
    };
  };
}
