{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.fonts;
in {
  options.myOptions.fonts = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system fonts configuration";
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        material-symbols
        material-design-icons
        font-awesome

        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji

        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
      ];

      fontconfig = {
        defaultFonts = {
          serif = ["Noto Serif"];
          sansSerif = ["Noto Sans"];
          monospace = ["FiraCode Nerd Font"];
          emoji = ["Noto Color Emoji"];
        };
        enable = true;
      };
    };
  };
}
