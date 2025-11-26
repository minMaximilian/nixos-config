{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.myOptions.rofi;

  volumeScript = pkgs.writeShellScriptBin "rofi-volume" ''
    #!/usr/bin/env bash

    # Get volume information
    get_volume() {
      pamixer --get-volume
    }

    is_muted() {
      pamixer --get-mute
    }

    # Get current volume level
    VOLUME=$(get_volume)
    MUTED=$(is_muted)

    # Set volume icon based on level
    if [[ "$MUTED" == "true" ]]; then
      ICON="󰝟"
    elif [[ "$VOLUME" -le 30 ]]; then
      ICON="󰕿"
    elif [[ "$VOLUME" -le 70 ]]; then
      ICON="󰖀"
    else
      ICON="󰕾"
    fi

    # Create menu options
    VOLUME_SLIDER="Volume Slider"
    INCREASE="Increase Volume"
    DECREASE="Decrease Volume"
    TOGGLE_MUTE="Toggle Mute"
    SET_VOLUME="Set Specific Volume"
    SELECT_OUTPUT="Select Output Device"
    OPEN_MIXER="Open Volume Mixer"

    # Generate the volume bar
    generate_volume_bar() {
      local vol=$1
      local width=50
      local filled=$(($vol * $width / 100))
      local empty=$(($width - $filled))

      bar="["
      for ((i=0; i<filled; i++)); do
        bar+="▓"
      done
      for ((i=0; i<empty; i++)); do
        bar+="░"
      done
      bar+="] $vol%"
      echo "$bar"
    }

    # Show rofi menu
    choice=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s" "$VOLUME_SLIDER" "$INCREASE" "$DECREASE" "$TOGGLE_MUTE" "$SET_VOLUME" "$SELECT_OUTPUT" "$OPEN_MIXER" |
      ${pkgs.rofi}/bin/rofi -dmenu -p "$ICON Volume: $VOLUME%" -theme-str "window { width: 25%; }")

    # Handle the choice
    case "$choice" in
      "$VOLUME_SLIDER")
        # Create a temporary theme file for the slider
        TEMP_THEME=$(mktemp)

        # Write theme contents directly using echo statements
        echo "element {" > "$TEMP_THEME"
        echo "  children: [element-text, element-index];" >> "$TEMP_THEME"
        echo "}" >> "$TEMP_THEME"
        echo "element-index {" >> "$TEMP_THEME"
        echo "  padding: 0 0 0 10px;" >> "$TEMP_THEME"
        echo "  background-color: inherit;" >> "$TEMP_THEME"
        echo "  text-color: inherit;" >> "$TEMP_THEME"
        echo "}" >> "$TEMP_THEME"
        echo "listview {" >> "$TEMP_THEME"
        echo "  lines: 1;" >> "$TEMP_THEME"
        echo "  columns: 100;" >> "$TEMP_THEME"
        echo "  scrollbar: false;" >> "$TEMP_THEME"
        echo "  fixed-columns: true;" >> "$TEMP_THEME"
        echo "}" >> "$TEMP_THEME"

        # Generate numbers from 0 to 100
        numbers=""
        for i in {0..100}; do
          if [ $((i % 5)) -eq 0 ]; then
            numbers+="$i\n"
          else
            numbers+=" \n"
          fi
        done

        # Display volume bar
        VOLUME_BAR=$(generate_volume_bar $VOLUME)

        # Show slider selection
        selected=$(echo -e "$numbers" |
          ${pkgs.rofi}/bin/rofi -dmenu -p "$VOLUME_BAR" -theme-str "window { width: 90%; }" \
          -theme-str "listview { lines: 1; columns: 21; }" \
          -theme-str "element-text { horizontal-align: 0.5; }" \
          -selected-row $(($VOLUME / 5)) -theme "$TEMP_THEME" -hover-select true -me-select-entry "" -me-accept-entry MousePrimary)

        # Remove temp theme
        rm "$TEMP_THEME"

        # Set the volume if a valid value was selected
        if [[ $selected =~ ^[0-9]+$ ]]; then
          pamixer --set-volume "$selected"
          notify-send "Volume" "Set to $selected%" -h string:x-canonical-private-synchronous:volume
        fi
        ;;
      "$INCREASE")
        pamixer -i 5
        notify-send "Volume" "Increased to $(pamixer --get-volume)%" -h string:x-canonical-private-synchronous:volume
        ;;
      "$DECREASE")
        pamixer -d 5
        notify-send "Volume" "Decreased to $(pamixer --get-volume)%" -h string:x-canonical-private-synchronous:volume
        ;;
      "$TOGGLE_MUTE")
        pamixer -t
        if [[ $(pamixer --get-mute) == "true" ]]; then
          notify-send "Volume" "Muted" -h string:x-canonical-private-synchronous:volume
        else
          notify-send "Volume" "Unmuted ($(pamixer --get-volume)%)" -h string:x-canonical-private-synchronous:volume
        fi
        ;;
      "$SET_VOLUME")
        new_vol=$(${pkgs.rofi}/bin/rofi -dmenu -p "Enter volume (0-100):" -theme-str 'window { width: 25%; }')
        if [[ $new_vol =~ ^[0-9]+$ ]] && [ "$new_vol" -ge 0 ] && [ "$new_vol" -le 100 ]; then
          pamixer --set-volume "$new_vol"
          notify-send "Volume" "Set to $new_vol%" -h string:x-canonical-private-synchronous:volume
        else
          notify-send "Error" "Invalid volume level" -h string:x-canonical-private-synchronous:volume
        fi
        ;;
      "$SELECT_OUTPUT")
        ${pkgs.pulseaudio}/bin/pactl list short sinks | cut -f 2 |
        ${pkgs.rofi}/bin/rofi -dmenu -p "Select output:" | xargs -I{} sh -c '
          sink="$1"
          ${pkgs.pulseaudio}/bin/pactl set-default-sink "$sink"
          ${pkgs.pulseaudio}/bin/pactl list short sink-inputs | cut -f 1 | while read -r stream; do
            ${pkgs.pulseaudio}/bin/pactl move-sink-input "$stream" "$sink"
          done
          notify-send "Audio Output" "Switched to $sink" -h string:x-canonical-private-synchronous:volume
        ' _ {}
        ;;
      "$OPEN_MIXER")
        ${pkgs.pavucontrol}/bin/pavucontrol &
        ;;
    esac
  '';
in {
  config = mkIf cfg.enable {
    home.packages = [volumeScript];
  };
}
