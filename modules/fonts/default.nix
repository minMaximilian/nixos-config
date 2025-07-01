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

  cfg = config.myOptions.fonts;
in {
  options.myOptions.fonts = {
    enable =
      mkEnableOption "system fonts configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        material-symbols
        material-design-icons
        font-awesome

        inter

        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji

        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.caskaydia-cove
        nerd-fonts.hack
        nerd-fonts.ubuntu-mono
        nerd-fonts.symbols-only
      ];

      fontconfig = {
        defaultFonts = {
          serif = ["Noto Serif"];
          sansSerif = ["Noto Sans"];
          monospace = ["CaskaydiaCove Nerd Font"];
          emoji = ["Noto Color Emoji"];
        };
        enable = true;
      };
    };
  };
}
