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
  hasStylix = config.lib.theme.hasStylix or false;
  colors =
    if hasStylix
    then config.lib.stylix.colors
    else null;
in {
  options.myOptions.neovim = {
    enable = mkEnableOption "Neovim with nixCats";
  };

  imports = lib.optionals hasNixCats [
    inputs.nixCats.homeModule
  ];

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasNixCats;
        message = "myOptions.neovim requires inputs.nixCats to be available";
      }
    ];

    nixCats = lib.mkIf hasNixCats {
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
            debug = true;
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
          nixd
          nixpkgs-fmt
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
            p.bash
            p.json
            p.markdown
            p.yaml
            p.toml
          ]))
          nvim-tree-lua
          nvim-web-devicons
          lualine-nvim
          indent-blankline-nvim
          comment-nvim
          base16-nvim
          nvim-cmp
          cmp-nvim-lsp
          luasnip
          cmp_luasnip
          friendly-snippets
          cmp-buffer
          cmp-path
          gitsigns-nvim
        ];
      };
    };
  };
}
