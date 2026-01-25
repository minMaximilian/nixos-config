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
    enable = mkEnableOption "Proton Mail desktop client";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.protonmail-desktop];

    xdg.desktopEntries.protonmail-desktop = {
      name = "Mail";
      genericName = "Email Client";
      exec = "proton-mail %U";
      icon = "proton-mail";
      terminal = false;
      categories = ["Network" "Email"];
    };
  };
}
