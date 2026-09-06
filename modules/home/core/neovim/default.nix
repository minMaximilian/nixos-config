{
  config,
  pkgs,
  lib,
  inputs ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.neovim;
  hasNixCats = inputs ? nixCats;
  hasNeovimNightly = inputs ? neovim-nightly;
  hasZlsOverlay = inputs ? zls-overlay;
  hasStylix = config.lib ? stylix && config.lib.stylix ? colors;
  colors =
    if hasStylix
    then config.lib.stylix.colors
    else null;
in {
  options.myOptions.neovim = {
    enable = mkEnableOption "Neovim with nixCats";
    debug.enable = mkEnableOption "Neovim debug adapters";
    godot.enable = mkEnableOption "Godot and C# editor integrations";
  };

  imports = lib.optionals hasNixCats [
    inputs.nixCats.homeModule
  ];

  config = mkIf cfg.enable ({
      assertions = [
        {
          assertion = hasNixCats;
          message = "myOptions.neovim requires inputs.nixCats to be available";
        }
      ];
    }
    // lib.optionalAttrs hasNixCats {
      nixCats = {
        enable = true;
        packageNames = ["nixcats-nvim"];
        luaPath = ./.;

        packageDefinitions.replace = {
          nixcats-nvim = {pkgs, ...}: {
            settings = {
              aliases = ["nvim" "vim" "vi"];
              wrapRc = true;
              neovim-unwrapped =
                if hasNeovimNightly
                then inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.neovim
                else pkgs.neovim-unwrapped;
            };
            categories = {
              general = true;
              debug = cfg.debug.enable;
              godot = cfg.godot.enable;
            };
            extra = lib.optionalAttrs hasStylix {
              colors =
                lib.genAttrs
                [
                  "base00"
                  "base01"
                  "base02"
                  "base03"
                  "base04"
                  "base05"
                  "base06"
                  "base07"
                  "base08"
                  "base09"
                  "base0A"
                  "base0B"
                  "base0C"
                  "base0D"
                  "base0E"
                  "base0F"
                ]
                (name: colors.${name});
            };
          };
        };

        categoryDefinitions.replace = {pkgs, ...}: {
          lspsAndRuntimeDeps.general = with pkgs; [
            lua-language-server
            glsl_analyzer
            nixd
            nixpkgs-fmt
            ols
            (
              if hasZlsOverlay
              then inputs.zls-overlay.packages.${pkgs.stdenv.hostPlatform.system}.zls
              else zls
            )
            ripgrep
            fd
          ];

          lspsAndRuntimeDeps.debug = with pkgs; [
            lldb
          ];

          lspsAndRuntimeDeps.godot = with pkgs; [
            gdscript-formatter
            roslyn-ls
            netcoredbg
            csharpier
          ];

          startupPlugins.godot = with pkgs.vimPlugins; [
            roslyn-nvim
          ];

          startupPlugins.debug = with pkgs.vimPlugins; [
            nvim-dap
            nvim-dap-ui
            nvim-nio
          ];

          startupPlugins.general = with pkgs.vimPlugins; [
            telescope-nvim
            plenary-nvim
            nvim-lspconfig
            (nvim-treesitter.withPlugins (p: [
              p.lua
              p.nix
              p.zig
              p.odin
              p.bash
              p.json
              p.markdown
              p.yaml
              p.toml
              p.gdscript
              p.gdshader
              p.glsl
              p.godot_resource
              p.c_sharp
            ]))
            nvim-tree-lua
            nvim-web-devicons
            lualine-nvim
            indent-blankline-nvim
            comment-nvim
            base16-nvim
            blink-cmp
            luasnip
            friendly-snippets
            nvim-autopairs
            gitsigns-nvim
          ];
        };
      };
    });
}
