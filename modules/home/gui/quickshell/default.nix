{
  config,
  pkgs,
  lib,
  inputs ? {},
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.quickshell;
  theme = config.myOptions.theme;
  themeLib = config.lib.theme;
  wallpaper = config.myOptions.hyprland.wallpaper or null;
  hasQuickshell = inputs ? quickshell;
  hasStylix = themeLib.hasStylix or false;

  quickshellPkg = (inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    libgbm = pkgs.libgbm;
  }).withModules [pkgs.kdePackages.qt5compat];

  colors =
    if hasStylix
    then config.lib.stylix.colors
    else null;

  col = name: fallback:
    if hasStylix
    then "#${colors.${name}}"
    else fallback;

  # Config.qml is the only Nix-generated file — injects Stylix colors + theme values
  configQml = pkgs.writeText "Config.qml" ''
    pragma Singleton

    import QtQuick
    import Quickshell

    Singleton {
        /* Colors from Stylix */
        readonly property color baseColor: "${col "base00" "#1e1e2e"}"
        readonly property color mantleColor: "${col "base01" "#181825"}"
        readonly property color surfaceColor: "${col "base02" "#313244"}"
        readonly property color overlayColor: "${col "base03" "#6c7086"}"
        readonly property color textColor: "${col "base05" "#cdd6f4"}"
        readonly property color redColor: "${col "base08" "#f38ba8"}"
        readonly property color sapphireColor: "${col "base0C" "#74c7ec"}"
        readonly property color blueColor: "${col "base0D" "#89b4fa"}"
        readonly property color pinkColor: "${col "base0F" "#f5c2e7"}"

        /* Font */
        readonly property string fontFamily: "${theme.fonts.mono}"
        readonly property int fontSize: ${toString theme.fonts.size.medium}

        /* OSD Slider */
        readonly property int osdSliderWidth: 400
        readonly property int osdSliderHeight: 40
        readonly property int osdSliderIconSize: 22
        readonly property int osdSliderBarHeight: 6
        readonly property int osdSliderBorderSize: ${toString theme.borderWidth}
        readonly property int osdSliderBorderRadius: ${toString theme.borderRadius}
        readonly property int osdSliderMargin: ${toString theme.padding.medium}

        readonly property color osdSliderBackground: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, ${toString theme.opacity.background})
        readonly property color osdSliderUnfilled: overlayColor
        readonly property color osdSliderFilled: textColor

        readonly property color osdVolumeBorder: blueColor
        readonly property color osdBrightnessBorder: blueColor

        /* Notifications */
        readonly property int notificationWidth: 400
        readonly property int notificationIconSize: 36
        readonly property int notificationMargin: ${toString theme.margin}
        readonly property int notificationSpacing: 5
        readonly property int notificationBorderWidth: ${toString theme.borderWidth}
        readonly property int notificationBorderRadius: ${toString theme.borderRadius}
        readonly property int notificationPadding: ${toString theme.padding.large}
        readonly property int notificationDefaultTimeout: 5000

        readonly property color notificationBackground: Qt.rgba(mantleColor.r, mantleColor.g, mantleColor.b, ${toString theme.opacity.background})
        readonly property color notificationBorderNormal: blueColor
        readonly property color notificationBorderLow: overlayColor
        readonly property color notificationBorderUrgent: redColor

        readonly property int notificationTitleSize: ${toString theme.fonts.size.medium}
        readonly property int notificationBodySize: ${toString theme.fonts.size.small}
        readonly property color notificationTitleColor: textColor
        readonly property color notificationBodyColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.7)

        /* Statusbar */
        readonly property int barHeight: 32
        readonly property int barMargin: ${toString theme.margin}
        readonly property int barPadding: ${toString theme.padding.small}
        readonly property int barSpacing: ${toString theme.margin}
        readonly property int barBorderRadius: ${toString theme.borderRadius}

        readonly property color barPillBackground: Qt.rgba(mantleColor.r, mantleColor.g, mantleColor.b, ${toString theme.opacity.background})
        readonly property color barPillHover: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, ${toString theme.opacity.background})

        readonly property color accentBlue: blueColor
        readonly property color accentCyan: sapphireColor
        readonly property color accentRed: redColor
        readonly property color accentYellow: "${col "base0A" "#f9e2af"}"
        readonly property color accentGreen: "${col "base0B" "#a6e3a1"}"
        readonly property color accentPurple: "${col "base0E" "#cba6f7"}"
        readonly property color accentOrange: "${col "base09" "#fab387"}"

        /* Lockscreen */
        readonly property string wallpaperPath: "${
      if wallpaper != null
      then toString wallpaper
      else ""
    }"
    }
  '';

  # Assemble: copy QML tree, then overlay the generated Config.qml
  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    cp -r ${./qml} $out
    chmod -R u+w $out
    cp ${configQml} $out/Config.qml
  '';
in {
  options.myOptions.quickshell = {
    enable = mkEnableOption "Quickshell desktop shell";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasQuickshell;
        message = "myOptions.quickshell requires inputs.quickshell";
      }
    ];

    home.packages = [
      quickshellPkg
      pkgs.brightnessctl
      pkgs.papirus-icon-theme
    ];

    xdg.configFile."quickshell".source = quickshellConfig;

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell desktop shell";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${quickshellPkg}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
