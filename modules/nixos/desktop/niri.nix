{
  config,
  pkgs,
  lib,
  inputs ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.myOptions.niri;
  hasNiri = inputs ? niri;
in {
  imports = lib.optionals hasNiri [
    inputs.niri.nixosModules.niri
  ];

  options.myOptions.niri = {
    enable = mkEnableOption "Niri scrollable-tiling Wayland compositor";

    package = mkOption {
      type = types.package;
      default =
        if hasNiri
        then inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable
        else pkgs.niri;
      description = "Niri package to use.";
    };

    monitors = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "Niri output configuration. Bridged into home-manager.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasNiri;
        message = "myOptions.niri requires inputs.niri (sodiboo/niri-flake).";
      }
    ];

    programs.niri = {
      enable = true;
      package = cfg.package;
    };

    # niri-flake auto-imports its home-manager module via NixOS module integration.
    # Polkit + dconf + xdg-desktop-portal-gnome are pulled in automatically.

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";

      GDK_SCALE = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      NIXOS_SCALE = "1.0";
    };

    # Bridge into home-manager
    home-manager.users.${config.myOptions.vars.username}.myOptions.niri = {
      enable = true;
      monitors = cfg.monitors;
    };
  };
}
