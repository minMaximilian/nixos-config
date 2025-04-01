{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.audio;

  audioSwitcher = pkgs.writeShellScriptBin "audio-switcher" ''
    function get_sinks() {
      pactl list short sinks | cut -f 2
    }

    function get_sources() {
      pactl list short sources | cut -f 2
    }

    function switch_sink() {
      sink=$1
      pactl set-default-sink "$sink"
      pactl list short sink-inputs | cut -f 1 | while read -r stream; do
        pactl move-sink-input "$stream" "$sink"
      done
      notify-send "Audio Output" "Switched to $sink"
    }

    function switch_source() {
      source=$1
      pactl set-default-source "$source"
      pactl list short source-outputs | cut -f 1 | while read -r stream; do
        pactl move-source-output "$stream" "$source"
      done
      notify-send "Audio Input" "Switched to $source"
    }

    case "$1" in
      "output")
        selected=$(get_sinks | ${pkgs.fuzzel}/bin/fuzzel -d -p "Select output: ")
        [[ -n "$selected" ]] && switch_sink "$selected"
        ;;
      "input")
        selected=$(get_sources | ${pkgs.fuzzel}/bin/fuzzel -d -p "Select input: ")
        [[ -n "$selected" ]] && switch_source "$selected"
        ;;
      *)
        echo "Usage: audio-switcher [output|input]"
        exit 1
        ;;
    esac
  '';
in {
  options.myOptions.audio = {
    enable =
      mkEnableOption "Audio configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
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
      pamixer
      pavucontrol

      pulseaudio
      qpwgraph
      easyeffects
      helvum
      pw-volume

      audioSwitcher
    ];
  };
}
