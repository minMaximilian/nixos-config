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
      mkEnableOption "Quickshell widget toolkit"
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
        ".config/quickshell/.keep".text = "";
      };

      home.sessionVariables = {
        QML2_IMPORT_PATH = "${pkgs.qt6.qtbase}/qml:${inputs.quickshell.packages.${pkgs.system}.default}/qml";
      };
    };
  };
}
