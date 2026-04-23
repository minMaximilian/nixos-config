{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.zed;
  theme = config.myOptions.theme;
in {
  options.myOptions.zed = {
    enable = mkEnableOption "Zed editor";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.television];

    programs.zed-editor = {
      enable = true;

      extensions = [
        "nix"
        "toml"
        "zig"
      ];

      extraPackages = with pkgs; [
        nixd
        alejandra
      ];

      userSettings = {
        vim_mode = true;
        auto_update = false;
        load_direnv = "shell_hook";
        base_keymap = "VSCode";
        hour_format = "hour24";

        tab_size = 2;
        hard_tabs = false;

        show_whitespaces = "trailing";
        relative_line_numbers = true;

        terminal = {
          dock = "bottom";
          copy_on_select = false;
          working_directory = "current_project_directory";
          shell.program = "fish";
        };

        format_on_save = "on";

        lsp = {
          nixd = {
            binary = {
              path_lookup = true;
            };
          };
        };

        languages = {
          Nix = {
            formatter = {
              external = {
                command = "alejandra";
                arguments = ["-"];
              };
            };
          };
        };

        vim = {
          toggle_relative_line_numbers = true;
          use_system_clipboard = "on_yank";
        };

        features = {
          copilot = false;
        };

        telemetry = {
          metrics = false;
        };
      };

      # Nvim keybind equivalents for Zed's vim mode
      userKeymaps = [
        # Normal + Visual mode: leader bindings (mirrors nvim init.lua)
        {
          context = "vim_mode == normal && !menu";
          bindings = {
            # Clipboard yank/paste (nvim: <leader>y, <leader>Y, <leader>p)
            "space y" = ["workspace::SendKeystrokes" "\"+y"];
            "space shift-y" = ["workspace::SendKeystrokes" "\"+Y"];
            "space p" = ["workspace::SendKeystrokes" "\"+p"];

            # Telescope equivalents (nvim: <leader>f, <leader>g, <leader>b, <leader>h)
            "space f" = [
              "task::Spawn"
              {
                task_name = "tv_file_finder";
                reveal_target = "center";
              }
            ];
            "space g" = [
              "task::Spawn"
              {
                task_name = "tv_live_grep";
                reveal_target = "center";
              }
            ];
            "space b" = "tab_switcher::Toggle";

            # File tree (nvim: <leader>e, <leader>o)
            "space e" = "workspace::ToggleLeftDock";
            "space o" = "pane::RevealInProjectPanel";

            # LSP (nvim: <leader>rn, <leader>ca, <leader>dd)
            # gd, gD, gr, gi, K, [d, ]d are Zed vim defaults
            "space r n" = "editor::Rename";
            "space c a" = "editor::ToggleCodeActions";
            "space d d" = "diagnostics::Deploy";
          };
        }
        {
          context = "vim_mode == visual && !menu";
          bindings = {
            "space y" = ["workspace::SendKeystrokes" "\"+y"];
            "space p" = ["workspace::SendKeystrokes" "\"+p"];
          };
        }
        # Insert mode (nvim: <C-k> signature help)
        {
          context = "vim_mode == insert";
          bindings = {
            "ctrl-k" = "editor::ShowSignatureHelp";
          };
        }
        # Terminal: navigate tv results with alt-j/k
        {
          context = "Terminal";
          bindings = {
            "alt-j" = ["workspace::SendKeystrokes" "down"];
            "alt-k" = ["workspace::SendKeystrokes" "up"];
          };
        }
      ];

      # Television tasks for telescope-style fuzzy finding
      userTasks = [
        {
          label = "tv_file_finder";
          command = "f=$(tv files \"$ZED_WORKTREE_ROOT\") && [ -n \"$f\" ] && zeditor \"$f\"";
          hide = "always";
          allow_concurrent_runs = true;
          use_new_terminal = true;
          cwd = "$ZED_WORKTREE_ROOT";
          shell = {
            with_arguments = {
              program = "bash";
              args = ["--noprofile" "--norc" "-c"];
            };
          };
        }
        {
          label = "tv_live_grep";
          command = "f=$(tv text \"$ZED_WORKTREE_ROOT\") && [ -n \"$f\" ] && zeditor \"$f\"";
          hide = "always";
          allow_concurrent_runs = true;
          use_new_terminal = true;
          cwd = "$ZED_WORKTREE_ROOT";
          shell = {
            with_arguments = {
              program = "bash";
              args = ["--noprofile" "--norc" "-c"];
            };
          };
        }
      ];
    };
  };
}
