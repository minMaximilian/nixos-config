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
    enable = mkEnableOption "Audio configuration";
  };

  config = mkIf cfg.enable {
    services.pulseaudio.enable = false;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      audio.enable = true;
      wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pavucontrol

      pulseaudio
      qpwgraph
      easyeffects
      pw-volume
    ];
  };
}
