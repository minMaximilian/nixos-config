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

  cfg = config.myOptions.protonmail;
in {
  options.myOptions.protonmail = {
    enable =
      mkEnableOption "Proton Mail desktop client"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.protonmail-desktop];

    xdg.desktopEntries.protonmail-desktop = {
      name = "Mail";
      genericName = "Email Client";
      exec = "protonmail-desktop %U";
      icon = "protonmail-desktop";
      terminal = false;
      categories = ["Network" "Email"];
    };
  };
}
