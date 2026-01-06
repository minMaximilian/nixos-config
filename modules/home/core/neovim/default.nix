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
        };
      };

      categoryDefinitions.replace = {pkgs, ...}: {
        lspsAndRuntimeDeps.general = with pkgs; [
          lua-language-server
          nixd
          nixpkgs-fmt
          statix
          prettier
        ];

        startupPlugins.general = with pkgs.vimPlugins; [
          lazy-nvim
          telescope-nvim
          nvim-lspconfig
        ];

        nativeBuildInputs.general = with pkgs; [];
      };
    };
  };
}
