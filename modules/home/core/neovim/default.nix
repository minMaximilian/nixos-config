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
  hasStylex = config.lib ? stylix && config.lib.stylix ? colors;
  colors =
    if hasStylex
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
        nixcats-nvim = {...}: {
          settings = {
            aliases = ["nvim" "vim" "vi"];
            wrapRc = true;
            hosts.python3.enable = true;
            hosts.node.enable = true;
          };
          categories = {
            general = true;
          };
          extra = lib.optionalAttrs hasStylex {
            colors = {
              base00 = colors.base00;
              base01 = colors.base01;
              base02 = colors.base02;
              base03 = colors.base03;
              base04 = colors.base04;
              base05 = colors.base05;
              base06 = colors.base06;
              base07 = colors.base07;
              base08 = colors.base08;
              base09 = colors.base09;
              base0A = colors.base0A;
              base0B = colors.base0B;
              base0C = colors.base0C;
              base0D = colors.base0D;
              base0E = colors.base0E;
              base0F = colors.base0F;
            };
          };
        };
      };

      categoryDefinitions.replace = {pkgs, ...}: {
        lspsAndRuntimeDeps.general = with pkgs; [
          lua-language-server
          nixd
          nixpkgs-fmt
          statix
          prettier
          zls
          ripgrep
          fd
        ];

        startupPlugins.general = with pkgs.vimPlugins; [
          telescope-nvim
          plenary-nvim
          nvim-lspconfig
          nvim-treesitter.withAllGrammars
          nvim-tree-lua
          nvim-web-devicons
          lualine-nvim
          indent-blankline-nvim
          comment-nvim
          base16-nvim
        ];
      };
    };
  };
}
