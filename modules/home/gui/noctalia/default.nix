{
  config,
  pkgs,
  lib,
  inputs ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.myOptions.noctalia;
  hasNoctalia = inputs ? noctalia;
  wallpaperDirectory = "${../../../../assets}";
  theme = config.myOptions.theme;
  systemctl = "${pkgs.systemd}/bin/systemctl";
  noctalia = "${config.home.profileDirectory}/bin/noctalia";
  servicePath =
    lib.makeBinPath [
      pkgs.bash
      pkgs.coreutils
      pkgs.systemd
    ]
    + ":${config.home.profileDirectory}/bin:/run/current-system/sw/bin";
in {
  imports = lib.optionals hasNoctalia [
    inputs.noctalia.homeModules.default
  ];

  options.myOptions.noctalia = {
    enable = mkEnableOption "Noctalia desktop shell";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasNoctalia;
        message = "myOptions.noctalia requires inputs.noctalia";
      }
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings =
        {
          notification = {
            enable_daemon = true;
          };

          bar.main = {
            position = "top";
            reserve_space = true;
            margin_ends = 8;
            margin_edge = 6;
            radius = theme.borderRadius;
            background_opacity = theme.opacity.background;
            padding = 12;
            widget_spacing = 8;
          };

          shell.panel = {
            background_blur = true;
            transparency_mode = "glass";
            borders = true;
            shadow = true;
          };

          shell.launch_apps_as_systemd_services = true;

          shell.session.actions = [
            {
              action = "lock";
              enabled = true;
              command = "${noctalia} msg session lock";
              variant = "default";
              shortcut = "1";
            }
            {
              action = "logout";
              enabled = true;
              variant = "default";
              shortcut = "2";
            }
            {
              action = "suspend";
              enabled = true;
              command = "${systemctl} suspend";
              variant = "default";
              shortcut = "3";
            }
            {
              action = "reboot";
              enabled = true;
              command = "${systemctl} reboot";
              variant = "default";
              shortcut = "4";
            }
            {
              action = "shutdown";
              enabled = true;
              command = "${systemctl} poweroff";
              variant = "destructive";
              shortcut = "5";
            }
          ];
        }
        // {
          wallpaper = {
            enabled = true;
            fill_mode = "crop";
            directory = wallpaperDirectory;
          };
        };
    };

    systemd.user.services.noctalia.Service = {
      Environment = ["PATH=${servicePath}"];
    };
  };
}
