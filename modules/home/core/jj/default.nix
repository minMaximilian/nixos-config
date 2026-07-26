{
  lib,
  pkgs,
  config,
  inputs ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.jj;
  vars = config.myOptions.vars;
  jjPackage =
    if inputs ? nixpkgs-stable
    then (import inputs.nixpkgs-stable {inherit (pkgs.stdenv.hostPlatform) system;}).jujutsu
    else pkgs.jujutsu;
in {
  options.myOptions.jj = {
    enable = mkEnableOption "Jujutsu (jj) version control";
  };

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = jjPackage;
      settings = {
        user = {
          email = vars.gitEmail;
          name = vars.gitName;
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
