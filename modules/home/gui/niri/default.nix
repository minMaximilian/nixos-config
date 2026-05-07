{
  config,
  pkgs,
  lib,
  inputs ? {},
  self ? null,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.myOptions.niri;
  hasNiri = inputs ? niri;
  theme = config.myOptions.theme;

  terminal = config.myOptions.vars.terminal or "ghostty";

  # Helper: action attrset shorthand
  spawn = cmd: {action.spawn = cmd;};
  act = name: {action.${name} = {};};
  actArg = name: arg: {action.${name} = arg;};

  # Workspace 1..10 with key 1..0
  workspaceKeys = [
    {
      key = "1";
      n = 1;
    }
    {
      key = "2";
      n = 2;
    }
    {
      key = "3";
      n = 3;
    }
    {
      key = "4";
      n = 4;
    }
    {
      key = "5";
      n = 5;
    }
    {
      key = "6";
      n = 6;
    }
    {
      key = "7";
      n = 7;
    }
    {
      key = "8";
      n = 8;
    }
    {
      key = "9";
      n = 9;
    }
    {
      key = "0";
      n = 10;
    }
  ];

  workspaceFocusBinds = builtins.listToAttrs (map (w: {
      name = "Mod+${w.key}";
      value = {action.focus-workspace = w.n;};
    })
    workspaceKeys);

  workspaceMoveBinds = builtins.listToAttrs (map (w: {
      name = "Mod+Shift+${w.key}";
      value = {action.move-column-to-workspace = w.n;};
    })
    workspaceKeys);
in {
  # NOTE: We do not import inputs.niri.homeModules.niri here. When the NixOS
  # module (modules/nixos/desktop/niri.nix) is enabled, niri-flake's
  # nixos/common.nix already wires the home-manager module into every user.
  # If you want to use this module standalone (no NixOS niri), import
  # inputs.niri.homeModules.niri yourself in your home configuration.

  options.myOptions.niri = {
    enable = mkEnableOption "Niri compositor (home-manager config)";

    monitors = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "Niri output configuration. Keys are output names.";
      example = {
        "DP-3" = {
          mode = {
            width = 3440;
            height = 1440;
            refresh = 144.0;
          };
          position = {
            x = 2560;
            y = 0;
          };
          scale = 1.0;
        };
      };
    };

    extraSpawnAtStartup = mkOption {
      type = types.listOf (types.listOf types.str);
      default = [];
      description = "Extra commands to spawn at startup (each as argv list).";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasNiri;
        message = "myOptions.niri (home) requires inputs.niri (sodiboo/niri-flake).";
      }
    ];

    home.packages = with pkgs; [
      awww # successor to swww
      xwayland-satellite
      wl-clipboard
      cliphist
      grimblast
      wtype
      pamixer
    ];

    programs.niri.settings = {
      prefer-no-csd = true;

      input = {
        keyboard.xkb = {
          layout = "us";
          options = "ctrl:nocaps";
        };
        touchpad = {
          natural-scroll = false;
          dwt = true; # disable while typing
        };
        mouse = {
          accel-profile = "flat";
          accel-speed = 0.0;
        };
        focus-follows-mouse.enable = true;
      };

      outputs = cfg.monitors;

      layout = {
        gaps = 3;
        border = {
          enable = true;
          width = theme.borderWidth;
        };
        focus-ring = {
          enable = false;
        };
        default-column-width = {proportion = 0.5;};
        preset-column-widths = [
          {proportion = 0.33333;}
          {proportion = 0.5;}
          {proportion = 0.66667;}
          {proportion = 1.0;}
        ];
      };

      hotkey-overlay.skip-at-startup = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot-%Y-%m-%d_%H-%M-%S.png";

      environment = {
        QT_QPA_PLATFORMTHEME = "qt5ct";
        DISPLAY = ":0";
      };

      cursor = {
        hide-when-typing = false;
      };

      animations.enable = false;

      spawn-at-startup =
        [
          {command = ["sh" "-c" "awww-daemon"];}
          {command = ["sh" "-c" "sleep 1 && awww img ${toString cfg.wallpaper}"];}
          {command = ["sh" "-c" "sleep 2 && qs ipc call lockscreen lock"];}
          {command = ["sh" "-c" "wl-paste --type text --watch cliphist store"];}
          {command = ["sh" "-c" "wl-paste --type image --watch cliphist store"];}
          {command = ["xwayland-satellite"];}
          {command = ["steam"];}
          {command = ["vesktop"];}
          {command = ["helium"];}
          {command = ["solaar" "--window=hide"];}
        ]
        ++ map (cmd: {command = cmd;}) cfg.extraSpawnAtStartup;

      window-rules = [
        # Steam → workspace 1
        {
          matches = [{app-id = "^steam$";}];
          open-on-workspace = "1";
        }
        # Vesktop → workspace 2
        {
          matches = [{app-id = "^vesktop$";}];
          open-on-workspace = "2";
        }
        # Helium → workspace 3
        {
          matches = [{app-id = "^helium$";}];
          open-on-workspace = "3";
        }
      ];

      workspaces = {
        "1" = {};
        "2" = {};
        "3" = {};
        "4" = {};
        "5" = {};
        "6" = {};
        "7" = {};
        "8" = {};
        "9" = {};
        "10" = {};
      };

      binds =
        {
          # Apps / launchers
          "Mod+Q" = spawn ["sh" "-c" terminal];
          "Mod+Space" = spawn ["${pkgs.rofi}/bin/rofi" "-show" "drun"];
          "Mod+Shift+Space" = spawn ["${pkgs.rofi}/bin/rofi" "-show" "run"];
          "Mod+Alt+Space" = spawn ["${pkgs.rofi}/bin/rofi" "-show" "window"];

          # Window
          "Mod+C" = act "close-window";
          "Mod+F" = act "fullscreen-window";

          # Screenshots
          "Print" = spawn ["grimblast" "--notify" "copy" "area"];
          "Mod+S" = spawn ["sh" "-c" "grimblast --notify save area ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"];
          "Mod+Shift+S" = spawn ["sh" "-c" "grimblast --notify save active ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"];
          "Mod+Alt+S" = spawn ["grimblast" "--notify" "copy" "area"];

          # Focus (hjkl) — h/l = column scroll, j/k = window in column
          "Mod+H" = act "focus-column-left";
          "Mod+L" = act "focus-column-right";
          "Mod+J" = act "focus-window-down";
          "Mod+K" = act "focus-window-up";

          # Resize column / window height
          "Mod+Ctrl+H" = actArg "set-column-width" "-5%";
          "Mod+Ctrl+L" = actArg "set-column-width" "+5%";
          "Mod+Ctrl+J" = actArg "set-window-height" "+5%";
          "Mod+Ctrl+K" = actArg "set-window-height" "-5%";

          # Move column / window
          "Mod+Left" = act "move-column-left";
          "Mod+Right" = act "move-column-right";
          "Mod+Up" = act "move-window-up";
          "Mod+Down" = act "move-window-down";
          "Mod+Shift+H" = act "move-column-left";
          "Mod+Shift+L" = act "move-column-right";
          "Mod+Shift+K" = act "move-window-up";
          "Mod+Shift+J" = act "move-window-down";

          # Move column to monitor (replaces movecurrentworkspacetomonitor for trial)
          "Mod+Alt+H" = act "move-column-to-monitor-left";
          "Mod+Alt+L" = act "move-column-to-monitor-right";
          "Mod+Alt+K" = act "move-column-to-monitor-up";
          "Mod+Alt+J" = act "move-column-to-monitor-down";

          # Focus monitors (left/right substitute for index 1/2/3)
          "Mod+Alt+1" = act "focus-monitor-left";
          "Mod+Alt+2" = act "focus-monitor-right";
          "Mod+Alt+3" = act "focus-monitor-up";

          # Audio
          "XF86AudioRaiseVolume" = spawn ["pamixer" "-i" "5"];
          "XF86AudioLowerVolume" = spawn ["pamixer" "-d" "5"];
          "XF86AudioMute" = spawn ["pamixer" "-t"];
          "Mod+Equal" = spawn ["pamixer" "-i" "5"];
          "Mod+Minus" = spawn ["pamixer" "-d" "5"];
          "Mod+M" = spawn ["pamixer" "-t"];

          # Audio tooling
          "Mod+Alt+O" = spawn ["audio-switcher" "output"];
          "Mod+Alt+I" = spawn ["audio-switcher" "input"];
          "Mod+Alt+P" = spawn ["pavucontrol"];
          "Mod+Alt+Q" = spawn ["qpwgraph"];
          "Mod+Alt+E" = spawn ["easyeffects"];
          "Mod+Alt+V" = spawn ["rofi-volume"];

          # Clipboard
          "Mod+V" = spawn ["sh" "-c" "cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy && wtype -M ctrl v -m ctrl"];
          "Mod+Shift+V" = spawn ["sh" "-c" "cliphist wipe"];

          # Niri-specific extras (no hyprland equivalent)
          "Mod+Tab" = act "focus-workspace-down";
          "Mod+Shift+Tab" = act "focus-workspace-up";
          "Mod+R" = act "switch-preset-column-width";
          "Mod+Shift+F" = act "maximize-column";
          "Mod+O" = act "toggle-overview";
        }
        // workspaceFocusBinds
        // workspaceMoveBinds;
    };
  };
}
