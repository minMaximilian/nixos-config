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

  cfg = config.myOptions.protonvpn;
in {
  options.myOptions.protonvpn = {
    enable = mkEnableOption "Proton VPN system-level support";
  };

  config = mkIf cfg.enable {
    # Required for Proton VPN wireguard connections
    networking.firewall.checkReversePath = false;

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };
}
