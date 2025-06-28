{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.quickshell;
in {
  options.myOptions.quickshell = {
    enable =
      mkEnableOption "Enable Quickshell"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.quickshell.packages.${pkgs.system}.default
      pkgs.qt6ct
    ];

    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    environment.sessionVariables = {
      QML2_IMPORT_PATH = "${pkgs.qt6.qtbase}/qml:${inputs.quickshell.packages.${pkgs.system}.default}/qml";
    };

    home-manager.users.${config.myOptions.vars.username} = {
      home.packages = [
        inputs.quickshell.packages.${pkgs.system}.default
      ];

      home.file = {
        # Main shell configuration with stylix color substitution
        ".config/quickshell/shell.qml".text = 
          builtins.replaceStrings
            [
              "#1e1e2e"  # base00 - Default Background
              "#181825"  # base01 - Lighter Background  
              "#313244"  # base03 - Comments, Borders
              "#89b4fa"  # base0D - Functions, Active Elements
              "#cdd6f4"  # base05 - Default Foreground
              "JetBrainsMono Nerd Font"  # Font family
            ]
            [
              "#${config.lib.stylix.colors.base00}"
              "#${config.lib.stylix.colors.base01}" 
              "#${config.lib.stylix.colors.base03}"
              "#${config.lib.stylix.colors.base0D}"
              "#${config.lib.stylix.colors.base05}"
              "${config.stylix.fonts.monospace.name}"
            ]
            (builtins.readFile ./shell.qml);
      };

      home.sessionVariables = {
        QML2_IMPORT_PATH = "${pkgs.qt6.qtbase}/qml:${inputs.quickshell.packages.${pkgs.system}.default}/qml";
      };
    };
  };
}
