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

  cfg = config.myOptions.discord;
in {
  options.myOptions.discord = {
    enable =
      mkEnableOption "Discord with custom configuration"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      DISCORD_SKIP_HOST_UPDATE = "1";
    };

    home.packages = [pkgs.vesktop];

    xdg.desktopEntries.vesktop = {
      name = "Discord";
      exec = "vesktop --enable-features=UseOzonePlatform,VaapiVideoDecoder,VaapiVideoEncoder --ozone-platform=wayland";
      terminal = false;
      categories = ["Network" "InstantMessaging"];
      type = "Application";
    };
  };
}
