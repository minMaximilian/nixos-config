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

  cfg = config.myOptions.eww;
  hasStylix = config.lib.theme.hasStylix or false;
  theme = config.myOptions.theme;
  themeLib = config.lib.theme;
in {
  options.myOptions.eww = {
    enable =
      mkEnableOption "Eww widgets"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
    };

    xdg.configFile."eww/eww.yuck".text = ''
      ; Volume widget variables
      (defpoll volume :interval "500ms"
        "pamixer --get-volume")

      (defpoll volume-muted :interval "500ms"
        "pamixer --get-mute")

      (defpoll audio-sinks :interval "1s"
        `pactl list sinks | awk '
          /^Sink #/ { id=$2; gsub("#","",id) }
          /Description:/ {
            desc=$0;
            gsub(/^[[:space:]]*Description: /,"",desc);
            print id "|" desc
          }'`)

      (defpoll current-sink :interval "500ms"
        "pactl get-default-sink")

      ; Fullscreen overlay to catch clicks outside
      (defwindow volume-overlay
        :monitor 0
        :geometry (geometry
          :x "0%"
          :y "0%"
          :width "100%"
          :height "100%"
          :anchor "center")
        :stacking "overlay"
        :exclusive false
        :focusable false
        (eventbox :onclick "eww close volume-popup volume-overlay"
          (box :class "overlay")))

      ; Volume popup - anchored top-right, below bar
      (defwindow volume-popup
        :monitor 0
        :geometry (geometry
          :x "160px"
          :y "40px"
          :width "280px"
          :anchor "top right")
        :stacking "overlay"
        :exclusive false
        :focusable false
        (volume-widget))

      ; Volume widget - vertical layout
      (defwidget volume-widget []
        (box :class "volume-box" :orientation "v" :space-evenly false :spacing 8
          ; Volume control row
          (box :class "volume-row" :orientation "h" :space-evenly false :spacing 8
            (button :class "volume-icon" :onclick "pamixer -t"
              (label :text {volume-muted == "true" ? "󰖁" :
                            volume < 30 ? "" :
                            volume < 70 ? "" : ""}))
            (scale :class "volume-slider"
                   :value volume
                   :min 0
                   :max 100
                   :hexpand true
                   :orientation "h"
                   :onchange "pamixer --set-volume {}")
            (label :class "volume-label" :text "''${volume}%"))

          ; Audio devices
          (for sink in {jq(audio-sinks, "split(\"\n\") | map(select(. != \"\"))")}
            (button :class "sink-button ''${jq(sink, "split(\"|\")[0]") == current-sink ? "active" : ""}"
                    :onclick "pactl set-default-sink ''${jq(sink, "split(\"|\")[0]")}"
              (label :text {jq(sink, "split(\"|\")[1]")}
                     :limit-width 30
                     :halign "start")))))
    '';

    xdg.configFile."eww/eww.scss".text = mkIf hasStylix (let
      colors = config.lib.stylix.colors;
      mkRgba = themeLib.mkRgba;
    in ''
      * {
        all: unset;
        font-family: "${theme.fonts.mono}", "Symbols Nerd Font Mono";
      }

      .overlay {
        background-color: transparent;
      }

      .volume-box {
        background-color: ${mkRgba "base00" theme.opacity.background};
        border-radius: ${themeLib.css.borderRadius};
        padding: ${themeLib.css.paddingLarge};
        border: ${themeLib.css.borderWidth} solid ${mkRgba "base04" 0.2};
      }

      .volume-row {
        margin-bottom: ${themeLib.css.paddingSmall};
      }

      .volume-icon {
        font-size: ${themeLib.css.fontSizeLarge};
        color: #${colors.base0B};
        min-width: 24px;
      }

      .volume-icon:hover {
        color: #${colors.base0C};
      }

      .volume-slider {
        min-height: 6px;
      }

      .volume-slider trough {
        background-color: ${mkRgba "base02" theme.opacity.inactive};
        border-radius: 3px;
        min-height: 6px;
      }

      .volume-slider slider {
        background-color: #${colors.base0E};
        border-radius: 50%;
        min-width: 14px;
        min-height: 14px;
        margin: -4px 0;
      }

      .volume-slider highlight {
        background-color: #${colors.base0B};
        border-radius: 3px;
      }

      .volume-label {
        font-size: ${themeLib.css.fontSizeSmall};
        color: #${colors.base05};
        min-width: 32px;
      }

      .sink-button {
        padding: ${themeLib.css.margin} ${themeLib.css.paddingMedium};
        border-radius: ${themeLib.css.margin};
        background-color: ${mkRgba "base02" 0.3};
        margin-top: 2px;
      }

      .sink-button:hover {
        background-color: ${mkRgba "base02" 0.6};
      }

      .sink-button.active {
        background-color: ${mkRgba "base0B" 0.15};
      }

      .sink-button.active label {
        color: #${colors.base0B};
      }

      .sink-button label {
        font-size: ${themeLib.css.fontSizeSmall};
        color: #${colors.base05};
      }
    '');

    home.packages = with pkgs; [
      pamixer
      pulseaudio
    ];
  };
}
