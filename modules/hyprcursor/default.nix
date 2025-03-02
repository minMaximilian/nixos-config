{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.hyprcursor;

  cursorTheme = "Bibata-Modern-Classic";
  cursorSize = 16;
in {
  options.myOptions.hyprcursor = {
    enable =
      mkEnableOption "Hyprcursor cursor theme"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hyprcursor
      libxml2
      dconf
    ];

    environment.etc."X11/Xresources".text = ''
      Xcursor.theme: ${cursorTheme}
      Xcursor.size: ${toString cursorSize}
    '';

    home-manager.users.${config.myOptions.vars.username} = {config, ...}: let
      inherit (config.colorScheme) palette;
    in {
      home.packages = [
        inputs.hyprcursor.packages.${pkgs.system}.hyprcursor
        pkgs.bibata-cursors
      ];

      home.pointerCursor = {
        name = cursorTheme;
        size = cursorSize;
        package = pkgs.bibata-cursors;
        gtk.enable = true;
        x11.enable = true;
      };

      xdg.configFile."hyprcursor/themes/custom/hyprcursor.toml".text = ''
        [theme]
        name = "custom"
        author = "user"

        [colors]
        primary = "#${palette.base0D}"
        secondary = "#${palette.base0C}"
        tertiary = "#${palette.base0B}"
      '';

      xdg.configFile."hyprcursor/themes/custom/cursors".source = "${pkgs.bibata-cursors}/share/icons/${cursorTheme}/cursors";

      xdg.configFile."hyprcursor/hyprcursor.conf".text = ''
        theme = "custom"
      '';

      wayland.windowManager.hyprland.settings = {
        exec-once = ["hyprcursor"];

        env = [
          "HYPRCURSOR_THEME,custom"
          "HYPRCURSOR_SIZE,${toString cursorSize}"
          "XCURSOR_THEME,${cursorTheme}"
          "XCURSOR_SIZE,${toString cursorSize}"
        ];
      };

      gtk = {
        enable = true;
        cursorTheme = {
          name = cursorTheme;
          size = cursorSize;
        };

        gtk2.extraConfig = ''
          gtk-cursor-theme-name="${cursorTheme}"
          gtk-cursor-theme-size=${toString cursorSize}
        '';

        gtk3.extraConfig = {
          "gtk-cursor-theme-name" = cursorTheme;
          "gtk-cursor-theme-size" = cursorSize;
        };

        gtk4.extraConfig = {
          "gtk-cursor-theme-name" = cursorTheme;
          "gtk-cursor-theme-size" = cursorSize;
        };
      };

      dconf.enable = true;
      dconf.settings."org/gnome/desktop/interface" = {
        cursor-theme = cursorTheme;
        cursor-size = cursorSize;
      };
    };
  };
}
