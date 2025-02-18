{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.audio;
in {
  options.myOptions.audio = {
    enable =
      mkEnableOption "Audio configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    # Disable PulseAudio
    services.pulseaudio.enable = false;

    # Enable sound with pipewire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pamixer # CLI audio control
      pavucontrol # GUI audio control
    ];
  };
}
