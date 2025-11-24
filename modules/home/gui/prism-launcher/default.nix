{
  config,
  pkgs,
  lib,
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
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];

    home.file = {
      ".local/share/java/8".source = pkgs.temurin-bin-8;
      ".local/share/java/17".source = pkgs.temurin-bin-17;
      ".local/share/java/21".source = pkgs.temurin-bin-21;
    };

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
}
