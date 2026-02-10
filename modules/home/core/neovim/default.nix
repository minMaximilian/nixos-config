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
