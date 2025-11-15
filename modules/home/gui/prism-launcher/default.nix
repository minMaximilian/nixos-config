{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.prismLauncher;
in {
  options.myOptions.prismLauncher = {
    enable =
      mkEnableOption "Prism Launcher with custom configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    users.users.${config.myOptions.vars.username}.extraGroups = [
      "video"
    ];

    programs.java = {
      enable = true;
      package = pkgs.temurin-bin-21;
    };

    environment.systemPackages = with pkgs; [
      prismlauncher
      temurin-bin-21
      temurin-bin-17
      temurin-bin-8
    ];

    home-manager.users.${config.myOptions.vars.username} = {
      xdg.desktopEntries.prismlauncher = {
        name = "Prism Launcher";
        exec = "prismlauncher";
        terminal = false;
        categories = ["Game"];
        type = "Application";
        icon = "prismlauncher";
        comment = "Minecraft launcher with support for multiple instances and mods";
      };

      xdg.configFile."PrismLauncher/prismlauncher.cfg" = {
        text = ''
          [General]
          AutoUpdate=true
          JavaPath=${pkgs.temurin-bin-21}/bin/java
          ModrinthEnabled=true
          CurseForgeEnabled=true
        '';
      };
    };
  };
}
