{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.steam;
  username = config.myOptions.vars.username;
  gamescopeNative = pkgs.writeShellScriptBin "gamescope-native" ''
    exec ${pkgs.gamescope}/bin/gamescope \
      -W 3440 -H 1440 \
      -w 3440 -h 1440 \
      -r 144 \
      -f -b \
      --force-grab-cursor \
      -- "$@"
  '';
in {
  options.myOptions.steam = {
    enable = mkEnableOption "Steam and gaming essentials" // {default = config.myOptions.vars.withGui;};
  };

  config = mkIf cfg.enable {
    # Load PlayStation controller driver for DualSense/DualShock Bluetooth support
    boot.kernelModules = ["hid_playstation"];
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
      };
    };
    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = true;

    hardware.steam-hardware.enable = true;

    # Additional udev rules for Bluetooth controller support
    services.udev.extraRules = ''
      # Valve HID devices over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"
      # Steam Controller udev write access
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
    '';

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      protontricks
      r2modman
      winetricks
      wineWow64Packages.stable
      lutris
      heroic
      gamemode
      gamescopeNative
    ];

    users.users.${username}.extraGroups = ["gamemode"];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
