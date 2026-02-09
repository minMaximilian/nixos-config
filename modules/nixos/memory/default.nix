{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.myOptions.memory;
in {
  options.myOptions.memory = {
    enable =
      mkEnableOption "Memory management optimizations"
      // {
        default = true;
      };

    zram = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ZRAM swap for better memory pressure handling";
      };

      memoryPercent = mkOption {
        type = types.int;
        default = 50;
        description = "Percentage of RAM to use for ZRAM";
      };
    };

    oomd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd-oomd with aggressive settings";
      };
    };
  };

  config = mkIf cfg.enable {
    # ZRAM configuration
    zramSwap = mkIf cfg.zram.enable {
      enable = true;
      memoryPercent = cfg.zram.memoryPercent;
      algorithm = "zstd";
    };

    # systemd-oomd configuration
    systemd.oomd = mkIf cfg.oomd.enable {
      enable = true;
      enableRootSlice = true;
      enableSystemSlice = true;
      enableUserSlices = true;
      settings.OOM = {
        DefaultMemoryPressureDurationSec = "20s";
      };
    };

    # Set memory pressure limits for user slices
    systemd.slices."user-".sliceConfig = mkIf cfg.oomd.enable {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "80%";
    };

    # Optional: earlyoom as a backup
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      extraArgs = [
        "--prefer"
        "^(electron|vesktop|discord|firefox|chromium|steam)$"
        "--avoid"
        "^(Hyprland|waybar|mako|pipewire|wireplumber)$"
      ];
      enableNotifications = true;
    };
  };
}
