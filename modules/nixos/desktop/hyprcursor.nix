{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.hyprcursor;
  username = config.myOptions.vars.username;

  cursorTheme = config.stylix.cursor.name or "Bibata-Modern-Classic";
  cursorSize = config.stylix.cursor.size or 16;
in {
  options.myOptions.hyprcursor = {
    enable = mkEnableOption "Hyprcursor" // {default = config.myOptions.vars.withGui;};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hyprcursor
      libxml2
      dconf
    ];

    environment.etc."X11/Xresources".text = ''
      Xcursor.theme: ${cursorTheme}
      Xcursor.size: ${toString cursorSize}
    '';

    home-manager.users.${username}.myOptions.hyprcursor.enable = true;
  };
}
