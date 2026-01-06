{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.steam;
  username = config.myOptions.vars.username;
in {
  options.myOptions.steam = {
    enable = mkEnableOption "Steam and gaming essentials" // {default = config.myOptions.vars.withGui;};
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [gamemode];
    };

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
        custom = {
          start = "${pkgs.procps}/bin/pkill -SIGUSR1 waybar; ${pkgs.systemd}/bin/systemctl --user stop gammastep";
          end = "${pkgs.procps}/bin/pkill -SIGUSR1 waybar; ${pkgs.systemd}/bin/systemctl --user start gammastep";
        };
      };
    };
    programs.gamescope.enable = true;

    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      protontricks
      winetricks
      wineWowPackages.stable
      lutris
      heroic
      bottles
      gamemode
    ];

    users.users.${username}.extraGroups = ["gamemode"];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
