{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environments.hyprland;
in {
  options.environments.hyprland = {
    enable = mkEnableOption "Hyprland environment";
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
