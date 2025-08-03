{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.neovim;
  username = config.myOptions.vars.username;
in {
  options.myOptions.neovim = {
    enable =
      mkEnableOption "Neovim with nixCats"
      // {
        default = true;
      };
  };

  imports = [
    inputs.nixCats.nixosModules.default
  ];

  config = mkIf cfg.enable {
    nixCats.users.${username} = {
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
        };
      };

      categoryDefinitions.replace = {pkgs, ...}: {
        lspsAndRuntimeDeps.general = with pkgs; [
          lua-language-server
          nixpkgs-fmt
          statix
          prettier
        ];

        startupPlugins.general = with pkgs.vimPlugins; [
          lazy-nvim
          plenary-nvim
          nui-nvim
          nvim-web-devicons
          nvim-lspconfig
          none-ls-nvim
          nvim-treesitter.withAllGrammars
          tokyonight-nvim
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          luasnip
          cmp_luasnip
          friendly-snippets
        ];

        nativeBuildInputs.general = with pkgs; [];
      };
    };
  };
}
