{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.rofi;
  hasStylex = config.lib ? stylix && config.lib.stylix ? colors;
in {
  imports = [
    ./volume-control.nix
  ];

  options.myOptions.rofi = {
    enable = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "${pkgs.ghostty}/bin/ghostty";
      extraConfig = {
        modi = "run,drun,window";
        icon-theme = "Papirus";
        show-icons = true;
        drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
        disable-history = false;
        display-drun = "Applications";
        display-run = "Commands";
        display-window = "Windows";
        display-Network = "Networks";
        sidebar-mode = true;
      };
      theme = mkIf hasStylex (let
        inherit (config.lib.formats.rasi) mkLiteral;
        colors = config.lib.stylix.colors;
      in {
        "*" = {
          font = "CaskaydiaCove Nerd Font 14";
          background = mkLiteral "rgba(${colors.base00-rgb-r}, ${colors.base00-rgb-g}, ${colors.base00-rgb-b}, 0.9)";
          background-alt = mkLiteral "rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, 0.9)";
          foreground = mkLiteral "#${colors.base05}";
          selected = mkLiteral "#${colors.base0D}";
          active = mkLiteral "#${colors.base0B}";
          urgent = mkLiteral "#${colors.base08}";
        };

        "window" = {
          transparency = "real";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
          fullscreen = false;
          width = mkLiteral "600px";
          x-offset = mkLiteral "0px";
          y-offset = mkLiteral "0px";
          enabled = true;
          border-radius = mkLiteral "10px";
          border = mkLiteral "2px solid";
          border-color = mkLiteral "@selected";
          background-color = mkLiteral "@background";
        };

        "mainbox" = {
          enabled = true;
          spacing = mkLiteral "0px";
          background-color = mkLiteral "transparent";
          orientation = mkLiteral "vertical";
          children = map mkLiteral ["inputbar" "listbox"];
        };

        "listbox" = {
          spacing = mkLiteral "10px";
          padding = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          orientation = mkLiteral "vertical";
          children = map mkLiteral ["message" "listview"];
        };

        "inputbar" = {
          enabled = true;
          spacing = mkLiteral "10px";
          padding = mkLiteral "15px";
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "@foreground";
          orientation = mkLiteral "horizontal";
          children = map mkLiteral ["prompt" "entry"];
          border-radius = mkLiteral "10px 10px 0 0";
        };

        "prompt" = {
          enabled = true;
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@selected";
        };

        "entry" = {
          enabled = true;
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
          cursor = mkLiteral "text";
          placeholder = "Search...";
          placeholder-color = mkLiteral "inherit";
        };

        "listview" = {
          enabled = true;
          columns = 1;
          lines = 8;
          cycle = true;
          dynamic = true;
          scrollbar = false;
          layout = mkLiteral "vertical";
          reverse = false;
          fixed-height = true;
          fixed-columns = true;
          spacing = mkLiteral "5px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
        };

        "element" = {
          enabled = true;
          spacing = mkLiteral "10px";
          padding = mkLiteral "8px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
          cursor = mkLiteral "pointer";
        };

        "element normal.normal" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        "element selected.normal" = {
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "@selected";
        };

        "element-icon" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          size = mkLiteral "32px";
          cursor = mkLiteral "inherit";
        };

        "element-text" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        "message" = {
          background-color = mkLiteral "transparent";
        };

        "textbox" = {
          padding = mkLiteral "10px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@background-alt";
          text-color = mkLiteral "@foreground";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        "error-message" = {
          padding = mkLiteral "10px";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@background";
          text-color = mkLiteral "@urgent";
        };
      });
    };
  };
}
